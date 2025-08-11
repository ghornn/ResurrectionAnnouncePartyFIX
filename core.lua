-- Saved options, default chat mode is dynamic (0)
ra_options = ra_options or { chat = "0" }

local rahealcomm = CreateFrame("Frame")
rahealcomm:RegisterEvent("CHAT_MSG_ADDON")

-- Event handler
rahealcomm:SetScript("OnEvent", function(self, event, prefix, msg, channel, sender)
  if event ~= "CHAT_MSG_ADDON" then return end
  if prefix ~= "HealComm" then return end
  self:ParseChatMessage(sender, msg or "")
end)

-- Parse incoming addon message
function rahealcomm:ParseChatMessage(sender, msg)
  -- Example expected format: Resurrection/<TargetName>/start
  -- Target can have letters, numbers, spaces, dashes, apostrophes
  local target = msg:match("^Resurrection[/ ]([%w%s%-%']+)[/ ]start$")
  if target then
    self:Ress(sender, target)
  end
end

-- Check functions for raid/party
local function InRaid()  return (GetNumRaidMembers and GetNumRaidMembers() or 0) > 0 end
local function InParty() return (GetNumPartyMembers and GetNumPartyMembers() or 0) > 0 end

-- Announce resurrection
function rahealcomm:Ress(sender, target)
  local me = UnitName("player")
  if sender ~= me then return end
  if target == me then return end

  local msg = "Resurrecting " .. target

  if ra_options.chat == "0" then
    -- Dynamic: RAID > PARTY > SAY
    if InRaid() then
      SendChatMessage(msg, "RAID")
    elseif InParty() then
      SendChatMessage(msg, "PARTY")
    else
      SendChatMessage(msg, "SAY")
    end

  elseif ra_options.chat == "1" then
    -- Raid only
    if InRaid() then
      SendChatMessage(msg, "RAID")
    end

  elseif ra_options.chat == "2" then
    -- Say only
    SendChatMessage(msg, "SAY")
  else
    -- Fallback to dynamic if value is unknown
    if InRaid() then
      SendChatMessage(msg, "RAID")
    elseif InParty() then
      SendChatMessage(msg, "PARTY")
    else
      SendChatMessage(msg, "SAY")
    end
  end
end
