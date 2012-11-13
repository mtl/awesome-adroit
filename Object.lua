-----------------------------------------------------------------------------
-- Class Object
-----------------------------------------------------------------------------

adroit.module( ..., adroit.seeall )
_M.__index = _M

-----------------------------------------------------------------------------

-- Constructor.
function new( _m, ... )
    local o = adroit.create_object( _m )
    o:initialize( ... )
    return o
end


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize()
end


-----------------------------------------------------------------------------

-- vi: set filetype=lua shiftwidth=4 tabstop=4 expandtab:
