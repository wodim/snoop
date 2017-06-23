-- stuff that can be configured
local window_name = "snoop" -- name of the window, not case sensitive
local message_format = "%02d:%02d [%s %s] [%s]: %s"
-- r, g and b of all messages
local color_message_r = .9
local color_message_g = .9
local color_message_b = .9
-- color in hex of all escape sequences
local color_escape = "FF5555"
-- that's the end of that

local function escape_char(c)
    -- returns the character in hex if it's non-printable (00 to 1f and 7f)
    return ("|cFF"..color_escape.."\\x%02x|r"):format(c:byte())
end

local function get_window_index(wn)
    -- iterate through all open windows and find the one with the required name
    for i = 1, NUM_CHAT_WINDOWS do
        local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i)
        if name:lower() == wn:lower() then
            return i
        end
    end
end

function Snoop_OnEvent(event, ...)
    -- return if this event is not an addon msg
    if event ~= "CHAT_MSG_ADDON" then
        return
    end

    -- return if there's no window to print to
    local window_index = get_window_index(window_name)
    if not window_index then
        return
    end

    local prefix, message, channel, sender = ...
    local hours, seconds = GetGameTime()
    -- escape pipes
    message = message:gsub("\124", "|cFF"..color_escape.."\124\124|r")
    -- escape control characters
    message = message:gsub("%c", escape_char)

    -- print it
    _G["ChatFrame"..window_index]:AddMessage(
        message_format:format(hours, seconds, prefix, channel, sender, message),
            color_message_r, color_message_g, color_message_b)
end

function Snoop_OnLoad()
    SnoopFrame:RegisterEvent("CHAT_MSG_ADDON")
end
