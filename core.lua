-- Saved options (default to dynamic)
ra_options = ra_options or { chat = "0", debug = false }

local f = CreateFrame("Frame")
f:RegisterEvent("CHAT_MSG_ADDON")    -- HealComm path (preferred)
f:RegisterEvent("SPELLCAST_START")   -- Fallback path (your own cast)
-- Optional: if you want to see failures, also watch SPELLCAST_FAILED/INTERRUPTED
-- f:RegisterEvent("SPELLCAST_FAILED")
-- f:RegisterEvent("SPELLCAST_INTERRUPTED")

-- Simple helpers
local function InRaid()  return (GetNumRaidMembers and GetNumRaidMembers() or 0) > 0 end
local function InParty() return (GetNumPartyMembers and GetNumPartyMembers() or 0) > 0 end
local function Announce(msg)
  if ra_options.chat == "1" then
    if InRaid() then SendChatMessage(msg, "RAID") end
    return
  elseif ra_options.chat == "2" then
    SendChatMessage(msg, "SAY")
    return
  end
  -- dynamic
  if InRaid() then
    SendChatMessage(msg, "RAID")
  elseif InParty() then
    SendChatMessage(msg, "PARTY")
  else
    SendChatMessage(msg, "SAY")
  end
end

-- Match common res spell names (enUS). Add others if your client is localized.
local RES_SPELLS = {
  ["Resurrection"] = true,     -- Priest
  ["Redemption"] = true,       -- Paladin
  ["Ancestral Spirit"] = true, -- Shaman
  ["Rebirth"] = true,          -- Druid (battle rez)
}

-- Try to extract target from various HealComm payload styles
local function ParseHealCommTarget(msg)
  -- Try a few common patterns:
  -- "Resurrection/<Target>/start"
  local t = string.match(msg or "", "^Resurrection[/ ]([%w%s%-%']+)[/ ]start/?$")
  if t then return t end
  -- "<Spell>:<Target>:start"
  t = string.match(msg or "", "^[Rr]es%w*%s*[:/]%s*([%w%s%-%']+)%s*[:/]%s*start")
  if t then return t end
  -- "start/<Target>/Resurrection" (try generic)
  t = string.match(msg or "", "start[/ ]([%w%s%-%']+)[/ ]")
  return t
end

-- Event handler
f:SetScript("OnEvent", function(self, event, ...)
  local a1, a2, a3, a4, a5 = ...
  if event == "CHAT_MSG_ADDON" then
    local prefix, msg, channel, sender = a1, a2, a3, a4
    if ra_options.debug then
      DEFAULT_CHAT_FRAME:AddMessage(("[rA DBG] prefix=%s sender=%s msg=%q"):format(tostring(prefix), tostring(sender), tostring(msg)))
    end
    if prefix == "HealComm" or prefix == "LunaUnitFrames" or prefix == "HealComm-1.0" then
      -- Only announce if YOU are the caster (sender is you)
      local me = UnitName("player")
      if sender ~= me then return end
      local target = ParseHealCommTarget(msg or "")
      if target and target ~= me then
        Announce("Resurrecting " .. target)
      end
    end

  elseif event == "SPELLCAST_START" then
    local spellName = a1 -- in 1.12, arg1 is spell name
    if not spellName or not RES_SPELLS[spellName] then return end

    -- Use current target's name; works for normal res. (Battle rez on a friendly corpse also uses target)
    local target = UnitName("target")
    -- If no target (e.g., mouseover cast via macro), try mouseover unit if available
    if not target and UnitExists and UnitExists("mouseover") then
      if UnitIsFriend("player", "mouseover") then
        target = UnitName("mouseover")
      end
    end
    if not target then return end
    if target == UnitName("player") then return end

    Announce("Resurrecting " .. target)
  end
end)
