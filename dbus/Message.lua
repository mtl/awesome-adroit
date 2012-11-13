-----------------------------------------------------------------------------
-- Class Message
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.Object", adroit.seeall )
_M.__index = _M -- This module is a class.


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize( message )
    --message = {
        --type = "signal",
        --bus = "system",
        --member = "Changed",
        --path = "/org/freedesktop/UPower/devices/battery_BAT0",
        --interface = "org.freedesktop.UPower.Device",
    --}
    __super.initialize( self )
    for key, value in pairs( message ) do
        -- Hope none of these mask object properties or methods!
        self[ key ] = value
    end
end


-----------------------------------------------------------------------------

-- vi: set filetype=lua shiftwidth=4 tabstop=4 expandtab:
