-- core.lua

-- Saved options (defaults)
ra_options = ra_options or { chat = "0", debug = false }

local function dbg(fmt, ...)
  if ra_options.debug then
    DEFAULT_CHAT_FRAME:AddMessage(("[rA DBG] " .. fmt):format(...))
  end
end

-- 1.12-safe raid/party checks
local function InRaid()  return (GetNumRaidMembers and GetNumRaidMembers() or 0) > 0 end
local function InParty() return (GetNumPartyMembers and GetNumPartyMembers() or 0) > 0 end

local function AnnounceRes(target)
  if not target or target == "" then return end
  local msg = "Resurrecting " .. target

  -- Mode 1 = raid only, Mode 2 = say only, else dynamic
  if ra_options.chat == "1" then
    if InRaid() then SendChatMessage(msg, "RAID") end
    return
  elseif ra_options.chat == "2" then
    SendChatMessage(msg, "SAY")
    return
  end

  -- dynamic: RAID > PARTY > SAY
  if InRaid() then
    SendChatMessage(msg, "RAID")
  elseif InParty() then
    SendChatMessage(msg, "PARTY")
  else
    SendChatMessage(msg, "SAY")
  end
end

-- Try to extract target from common HealComm payload formats
local function ParseHealCommTarget(payload)
  if not payload then return nil end
  -- "Resurrection/<Target>/start"
  local t = string.match(payload, "^Resurrection[/ ]([%w%s%-%']+)[/ ]start/?$")
  if t then return t end
  -- "<Spell>:<Target>:start" or "<Spell>|<Target>|start"
  t = string.match(payload, "^[Rr]es%w*%s*[:|/]%s*([%w%s%-%']+)%s*[:|/]%s*start$")
  if t then return t end
  -- Generic rescue: "... start/<Target>/ ..."
  t = string.match(payload, "start[/ ]([%w%s%-%']+)[/ ]")
  return t
end

-- Known resurrection spell names (enUS)
local RES_SPELLS = {
  ["Resurrection"] = true,      -- Priest
  ["Redemption"] = true,        -- Paladin
  ["Ancestral Spirit"] = true,  -- Shaman
  ["Rebirth"] = true,           -- Druid (battle rez)
}

-- Frame + events
local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")   -- preferred: HealComm/Luna
f:RegisterEvent("SPELLCAST_START")  -- fallback: your own cast
-- Optional extra diagnostics:
-- f:RegisterEvent("SPELLCAST_FAILED")
-- f:RegisterEvent("SPELLCAST_INTERRUPTED")

f:SetScript("OnEvent", function(self, event, ...)
  local a1, a2, a3, a4 = ...

  if event == "CHAT_MSG_ADDON" then
    local prefix, msg, channel, sender = a1, a2, a3, a4
    if ra_options.debug then
      DEFAULT_CHAT_FRAME:AddMessage(("[rA DBG] prefix=%s sender=%s msg=%q"):format(
        tostring(prefix), tostring(sender), tostring(msg)))
    end

    -- HealComm-style prefixes vary by pack
    if prefix == "HealComm" or prefix == "HealComm-1.0" or prefix == "LunaUnitFrames" then
      local me = UnitName("player")
      if sender ~= me then return end
      local target = ParseHealCommTarget(msg or "")
      if target and target ~= me then
        AnnounceRes(target)
      end
    end

  elseif event == "SPELLCAST_START" then
    -- Vanilla: arg1 = spellName
    local spellName = a1
    if not spellName or not RES_SPELLS[spellName] then return end

    -- Use current friendly target; try mouseover as a backup
    local me = UnitName("player")
    local target = UnitName("target")
    if (not target) and UnitExists and UnitExists("mouseover") and UnitIsFriend("player", "mouseover") then
      target = UnitName("mouseover")
    end
    if not target or target == me then return end

    if ra_options.debug then
      DEFAULT_CHAT_FRAME:AddMessage(("[rA DBG] SPELLCAST_START %q -> %s"):format(spellName, target))
    end

    AnnounceRes(target)
  end
end)

-- Tiny manual test command to verify output channels:
SLASH_RAANN1 = "/ratest"
SlashCmdList.RAANN = function(msg)
  local who = (msg and msg ~= "" and msg) or "Testtarget"
  AnnounceRes(who)
end
