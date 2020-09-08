-- stuff that can be configured
local window_name = "sp" -- name of the window for player whispers
local window_name_auto = "sw" -- name of the window for automatic warden messages
local message_format = "<<< %02d:%02d [%s %s] [%s]: %s"
local message_format_out = ">>> %02d:%02d [%s %s] [%s]: %s"
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
    if not s then return "" end
    s = tostring(s)
    -- escape pipes
    s = s:gsub("\124", "|cFF" .. color_escape .. "\124\124|r")
    -- escape control characters
    s = s:gsub("%c", escape_char)
    return s
end

-- given the name of a sender, is this an automated or a player message?
local function get_window_name(s)
    if not s or s == "" then
        return window_name_auto
    elseif s == "l0l" then
        return window_name
    elseif string.match(s, "^%u%l+$") == nil then
        return window_name_auto
    else
        return window_name
    end
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

    -- return if there's no window to print to
    local window_index = get_window_index(get_window_name(sender))
    if not window_index then
        return
    end

    -- print it
    if channel == "WHISPER" then
        local hours, seconds = GetGameTime()
        local escaped_message = escape_str(message)
        _G["ChatFrame" .. window_index]:AddMessage(
            message_format:format(hours, seconds, channel, prefix, sender, escaped_message),
                color_message_r, color_message_g, color_message_b)
    end
end

-- sent addon msgs
hooksecurefunc("SendAddonMessage", function(prefix, message, type_, target)
    -- return if there's no window to print to
    local window_index
    if type_ == "WHISPER" then
        window_index = get_window_index(get_window_name(target))
    else
        window_index = get_window_index(window_name)
    end
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
        message_format_out:format(hours, seconds, type_, prefix, target, message),
            color_message_r, color_message_g, color_message_b)
end)

function Snoop_OnLoad()
    SnoopFrame:RegisterEvent("CHAT_MSG_ADDON")
end
