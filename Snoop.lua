-- stuff that can be configured
local window_name = "snoop" -- name of the window, not case sensitive
local message_format = "%02d:%02d [%s %s] [%s]: %s"
local message_format_out = "%02d:%02d [%s %s] To [%s]: %s"
-- r, g and b of all messages
local color_message_r = .9
local color_message_g = .9
local color_message_b = .9
-- color in hex of all escape sequences
local color_escape = "FF5555"
-- that's the end of that

local function escape_char(c)
    -- returns the character in hex if it's non-printable (00 to 1f and 7f)
    return ("|cFF" .. color_escape .. "\\x%02x|r"):format(c:byte())
end

local function escape_str(s)
    -- escape pipes
    s = s:gsub("\124", "|cFF" .. color_escape .. "\124\124|r")
    -- escape control characters
    s = s:gsub("%c", escape_char)
    return s
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

-- received addon events.
function Snoop_OnEvent(event, ...)
    local prefix, message, channel, sender = ...

    if event ~= "CHAT_MSG_ADDON" then
        return
    end

    -- return if there's no window to print to
    local window_index = get_window_index(window_name)
    if not window_index then
        return
    end

    if channel == "GUILD" then
        -- boring spam
        return
    end

    local hours, seconds = GetGameTime()
    message = escape_str(message)

    -- print it
    _G["ChatFrame" .. window_index]:AddMessage(
        message_format:format(hours, seconds, channel, prefix, sender, message),
            color_message_r, color_message_g, color_message_b)
end

-- sent addon msgs
hooksecurefunc("SendAddonMessage", function(prefix, message, type_, target)
    if type_ ~= "WHISPER" then
        -- we only handle whispers in this function.
        return
    end

    -- return if there's no window to print to
    local window_index = get_window_index(window_name)
    if not window_index then
        return
    end

    local hours, seconds = GetGameTime()
    message = escape_str(message)
    if not target then
        target = "???"
    end

    -- print it
    _G["ChatFrame" .. window_index]:AddMessage(
        message_format_out:format(hours, seconds, "WHISPER", prefix, target, message),
            color_message_r, color_message_g, color_message_b)
end)

function Snoop_OnLoad()
    SnoopFrame:RegisterEvent("CHAT_MSG_ADDON")
end
