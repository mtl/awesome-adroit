-----------------------------------------------------------------------------
-- Class Widget
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.Object", adroit.seeall )
_M.__index = _M -- This module is a class.

adroit.require( "adroit.widget.poller.Nop" )


-----------------------------------------------------------------------------

-- Track data sources via polling and event listeners
--   Have different polling strategies (e.g., fixed interval, exponential, etc.)
-- When data sources update, refresh the widget UI
--   Also refresh upon request
-- Support multiple instances (e.g., one per screen)
-- Support pause, unpause, and remove/delete


--function disable() end -- Disable all polling, event listeners, and any further UI updating
--function enable() end -- Enable polling, event listeners, and UI updating
--function get_ui() end -- return a new instance in the form of awesome widgets
--function notify() end -- Receive an event notification
--function poll.now() end -- Force a poll now
--function poll.pause() end -- Pause polling
--function poll.resume() end -- Resume polling
--function refresh() end -- Reset all widget UIs
--function update() end -- Update all widget UIs as needed


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize()
    __super.initialize( self )
    self.interfaces = {}
    self.poll = adroit.widget.poller.Nop:new()
end


-----------------------------------------------------------------------------

-- Disable all polling, event listeners, and any further UI updating.
function _M:disable()
end


-----------------------------------------------------------------------------

-- Enable polling, event listeners, and UI updating.
function _M:enable()
    if self.poll ~= nil then
        self.poll.resume()
    end
end


-----------------------------------------------------------------------------

-- Return a new instance in the form of awesome widgets.
function _M:get_ui()
end


-----------------------------------------------------------------------------

-- Receive an event notification.
function _M:notify()
end


-----------------------------------------------------------------------------

-- Reset all widget UIs.
function _M:refresh()
    self.update()
end


-----------------------------------------------------------------------------

-- Update all widget UIs as needed.
function _M:update()
end


-----------------------------------------------------------------------------

-- vi: set filetype=lua shiftwidth=4 tabstop=4 expandtab:
