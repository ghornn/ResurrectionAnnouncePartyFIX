-- cmd.lua

-- Saved options (ensure table exists if files load out-of-order)
ra_options = ra_options or { chat = "0", debug = false }

SlashCmdList = SlashCmdList or {}

-- Unique token to avoid collisions with other addons
SLASH_RA_TURTLE1 = "/sayres"
SLASH_RA_TURTLE2 = "/sr"

local function trim(s)
  if not s then return "" end
  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  return s
end

local function label_for_chat(v)
  if v == "0" then return "Dynamic (Raid > Party > Say)" end
  if v == "1" then return "Raid only" end
  if v == "2" then return "Say only" end
  return "Unknown"
end

SlashCmdList["RA_TURTLE"] = function(msg)
  local input = tostring(msg or "")
  local cmd, opt = string.match(input, "^%s*(%S+)%s*(.*)$")
  cmd = cmd and string.lower(cmd) or ""
  opt = trim(opt and string.lower(opt) or "")

  local chatformat_cmd  = "|cFFFF8080rA |cffffff55"
  local chatformat_info = "|cFFFF8080rA |cffff0000"

  -- Normalize loose forms:
  --   /sr dynamic|raid|say|0|1|2  → chat <mapped>
  --   /sr chat 0 | /sr chat=1 | /sr chat1
  if cmd == "chat" and opt == "" then
    opt = string.match(input, "%s[=: ]%s*(%d)") or string.match(input, "chat(%d)") or ""
  elseif (cmd == "dynamic" or cmd == "raid" or cmd == "say"
       or cmd == "0" or cmd == "1" or cmd == "2") then
    opt, cmd = cmd, "chat"
  end

  -- HELP (default)
  if cmd == "" or cmd == "help" then
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."About:|cffffff55 Announces your resurrection casts to RAID/PARTY/SAY")
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Usage:|cffffff55 /sr chat {0|1|2}  |  /sr {dynamic|raid|say}  |  /sr status  |  /sr debug {on|off}")
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Modes:|cffffff55 0=Dynamic (Raid>Party>Say), 1=Raid only, 2=Say only")
    return
  end

  -- STATUS
  if cmd == "status" then
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_cmd.."Mode: |cffffff55"..label_for_chat(ra_options.chat).."|r ("..tostring(ra_options.chat)..")")
    DEFAULT_CHAT_FRAME:AddMessage(chatformat_cmd.."Debug: |cffffff55"..(ra_options.debug and "ON" or "OFF"))
    return
  end

  -- DEBUG
  if cmd == "debug" then
    if opt == "on" or opt == "1" then
      ra_options.debug = true
      DEFAULT_CHAT_FRAME:AddMessage(chatformat_cmd.."Debug: |cffffff55ON")
    elseif opt == "off" or opt == "0" then
      ra_options.debug = false
      DEFAULT_CHAT_FRAME:AddMessage(chatformat_cmd.."Debug: |cffffff55OFF")
    else
      DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Usage:|cffffff55 /sr debug {on|off}")
    end
    return
  end

  -- CHAT MODE
  if cmd == "chat" then
    local map = { dynamic = "0", raid = "1", say = "2" }
    if map[opt] then opt = map[opt] end

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

  -- Unknown
  DEFAULT_CHAT_FRAME:AddMessage(chatformat_info.."Unknown Command. Type |cffffff55/sr help|r")
end
