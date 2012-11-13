-----------------------------------------------------------------------------
-- Class Poller
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.Object", adroit.seeall )
_M.__index = _M -- This module is a class.


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize( poll_function, poll_object )
    __super.initialize( self )

    self.enabled = false
    self:set_poll_function( poll_function, poll_object )
end


-----------------------------------------------------------------------------

-- Force a poll now.
function _M:now()
    if self._poll_function ~= nil then
        self._poll_function( self._poll_object )
    end
end


-----------------------------------------------------------------------------

-- Pause polling.
function _M:pause()
end


-----------------------------------------------------------------------------

-- Set the poll function.
function _M:set_poll_function( poll_function, poll_object )
    self._poll_function = poll_function
    self._poll_object = poll_object
end


-----------------------------------------------------------------------------

-- Resume polling.
function _M:resume()
end


-----------------------------------------------------------------------------

-- vi: set filetype=lua shiftwidth=4 tabstop=4 expandtab:
