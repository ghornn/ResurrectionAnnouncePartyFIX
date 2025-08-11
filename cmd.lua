-- cmd.lua

-- Saved options (default to dynamic + debug off)
ra_options = ra_options or { chat = "0", debug = false }

-- Register slash commands
SLASH_SAYRES1 = "/sayres"
SLASH_SAYRES2 = "/sr"

SlashCmdList = SlashCmdList or {}

local function trim(s)
  if not s then return "" end
  -- Lua 5.0 safe trim
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

SlashCmdList["SAYRES"] = function(msg)
  local input = tostring(msg or "")

  -- split first token + remainder
  local cmd, opt = string.match(input, "^%s*(%S+)%s*(.*)$")
  cmd = cmd and string.lower(cmd) or ""
  opt = trim(opt and string.lower(opt) or "")

  local chatformat_cmd  = "|cFFFF8080rA |cffffff55"
  local chatformat_info = "|cFFFF8080rA |cffff0000"

  -- Accept loose
