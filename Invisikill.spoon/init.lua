--- === Invisikill ===
---
--- detects and removing invisible spaces and other gremlins from strings when you copy them
---
--- Download: [https://github.com/alazoral/invisikill](https://github.com/alazoral/invisikill)

local obj={}
obj.__index = obj

-- Metadata
obj.name = "Invisikill"
obj.version = "0.1"
obj.author = "Leon Spencer"
obj.homepage = "https://github.com/alazoral/invisikill"
obj.license = "MIT - https://opensource.org/licenses/MIT"

--- Invisikill.logger
--- Variable
--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('Invisikill')

--- Invisikill.kill_list
--- Variable
--- A table of regular expression strings to match and remove
obj.kill_list = {
    "[^\x00-\x7F]"
}

--- Invisikill:init()
--- Method
--- Set up warning notification
function obj:init()
    self.warningNotification = hs.notify.new(self:currySelf(self.handleNotificationAction))
    self.warningNotification:title("Hidden Characters Detected")
    self.warningNotification:informativeText("Potentially disasterous characters were detected in your clipboard")
    self.warningNotification:actionButtonTitle("Remove")
    self.warningNotification:hasActionButton(true)
    self.warningNotification:autoWithdraw(false)
end

--- Invisikill:start()
--- Method
--- Start watching the clipboard
function obj:start()
    self.ikWatcher = hs.pasteboard.watcher.new(self:currySelf(self.handleClipboardEvent))
end

--- Invisikill:currySelf()
--- Method
--- A convenience method for wrapping callbacks with self
function obj:currySelf(fn)
    return function(...)
        return fn(self, ...)
    end
end

--- Invisikill:currySelf()
--- Method
--- Add patterns to the kill list
---
--- Parameters:
---  * patterns - A table of pattern strings to add
function obj:addKillList(list)
    for _, v in pairs(list) do
        table.insert(self.kill_list, v)
    end
end

--- Invisikill:handleNotificationAction()
--- Method
--- Strips characters if the user has clicked the action button, and withdraws the notification
---
--- Parameters:
---  * notification - the notify object
function obj:handleNotificationAction(notification)
    if notification:activationType() == hs.notify.activationTypes.actionButtonClicked then
        hs.pasteboard.setContents(self:stripKillChars(hs.pasteboard.readString()))
    end
    notification:withdraw()
end

--- Invisikill:stringContainsKillChars()
--- Method
--- Checks if the provided value contains any patterns defined by the kill list
---
--- Returns:
---  * a boolean, true if the string matches any kill patterns, otherwise false
function obj:stringContainsKillChars(value)
    for _, regex in ipairs(self.kill_list) do
        if string.match(value, regex) then
            return true
        end
    end
    return false
end

--- Invisikill:stringContainsKillChars()
--- Method
--- Removes all instances of matching kill patterns from the provided value
---
--- Returns:
---  * the string with all matching kill patterns removed
function obj:stripKillChars(value)
    for _, regex in ipairs(self.kill_list) do
        value = string.gsub(value, regex, "")
    end
    return value
end

--- Invisikill:handleClipboardEvent()
--- Method
--- Checks if the clipboard contains any kill patterns, and if so, displays a warning notification
---
--- Parameters:
---  * value - the string value of the clipboard, or nil
function obj:handleClipboardEvent(value)
    if (value == nil) then
        return
    end
    if self:stringContainsKillChars(value) then
        self.warningNotification:send()
    else
        if hs.notify.delivered then
            log:d("withdrawing")
            self.warningNotification:withdraw()
        end
    end
end

return obj