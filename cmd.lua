-- Saved options (default to dynamic = 0)
ra_options = ra_options or { chat = "0" }

-- Register slash commands
SLASH_SAYRES1 = "/sayres"
SLASH_SAYRES2 = "/sr"

SlashCmdList = SlashCmdList or {}
SlashCmdList["SAYRES"] = function(msg)
  local function trim(s) return (s and s:gsub("^%s+",""):gsub("%s+$","")) or "" end

  local raw = msg or ""
  local cmd, opt = raw:match("^%s*(%S+)%s*(.*)$")
  cmd = (cmd and cmd:lower()) or ""
  opt = trim((opt and opt:lower()) or "")

  local chatformat_cmd  = "|cFFFF8080rA |cffffff55"
  local chatformat_info = "|cFFFF8080rA |cffff0000"

  -- Allow loose formats:
  --  /sr dynamic  -> chat 0
  --  /sr raid     -> chat 1
  --  /sr say      -> chat 2
  --  /sr chat 0   / /sr chat=1 / /sr chat1 etc.
  if cmd == "chat" and opt == "" then
    opt = raw:match("%s[=: ]%s*(%d)") or raw:match("chat(%d)") or ""
  elseif cmd == "dynamic" or cmd == "raid" or cmd == "say"
     or cmd == "0" or cmd == "1" or cmd == "2" then
    opt, cmd = cmd, "chat"
  end

  if cmd == "" or cmd == "help" then
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."About:|cffffff55 Announces res casts to RAID/PARTY/SAY")
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Usage:|cffffff55 /sr chat {0|1|2}  or  /sr {dynamic|raid|say}")
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Options:|cffffff55 0=Dynamic (Raid>Party>Say), 1=Raid only, 2=Say only")
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Extras:|cffffff55 /sr status")
    return
  end

  if cmd == "status" then
    local label = (ra_options.chat == "0" and "Dynamic")
               or (ra_options.chat == "1" and "Raid")
               or (ra_options.chat == "2" and "Say") or "Unknown"
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_cmd.."Current chat mode: |cffffff55"..label.."|r ("..tostring(ra_options.chat)..")")
    return
  end

  if cmd == "chat" then
    local map = { dynamic = "0", raid = "1", say = "2" }
    opt = map[opt] or opt  -- keep numeric if passed

    if opt == "0" then
      ra_options.chat = "0"
      DEFAULT_CHAT_FRAME:AddMessage(chatformat_cmd.."Chat Output set to: |cff00ff00DYNAMIC|r")
    elseif opt == "1" then
      ra_options.chat = "1"
      DEFAULT_CHAT_FRAME:AddMessage(chatformat_cmd.."Chat Output set to: |cffff7d00RAID|r")
    elseif opt == "2" then
      ra_options.chat = "2"
      DEFAULT_CHAT_FRAME:AddMessage(chatformat_cmd.."Chat Output set to: |rSAY")
    else
      DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Unknown Chat Option. Use 0/1/2 or dynamic/raid/say.")
    end
    return
  end

  DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Unknown Command. Type |cffffff55/sr help|r")
end
