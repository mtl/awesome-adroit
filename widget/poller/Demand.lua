-----------------------------------------------------------------------------
-- Class Demand
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.widget.poller.Poller", adroit.seeall )
_M.__index = _M -- This module is a class.


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize( poll_function )
    __super.initialize( self, poll_function )
end


-----------------------------------------------------------------------------

-- Force a poll now.
--function _M:now()
--end


-----------------------------------------------------------------------------

-- Pause polling.
--function _M:pause()
--end


-----------------------------------------------------------------------------

-- Resume polling.
--function _M:resume()
--end


-----------------------------------------------------------------------------

-- vi: set filetype=lua shiftwidth=4 tabstop=4 expandtab:
