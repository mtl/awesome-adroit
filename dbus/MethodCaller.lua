-----------------------------------------------------------------------------
-- Class MethodCaller
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.Object", adroit.seeall )
_M.__index = _M -- This module is a class.

adroit.require( "adroit.dbus.Message" )
adroit.require( "adroit.dbus.Monitor" )


-----------------------------------------------------------------------------

local callers = {}
local dbus_name = "org.naquadah.awesome.adroit"
local dbus_monitor = nil
local next_call_id = 0
local registered = false


-----------------------------------------------------------------------------

function receive( monitor, message, call_id, result )

    call_id = tonumber( call_id )
    caller = callers[ call_id ]
    --print( "Looked up call_id: " .. call_id .. " " .. tostring( caller == nil ) )

    if caller ~= nil then
        callers[ call_id ] = nil

        local o = caller.callback_object
        if o == nil then
            caller.callback_function( message, result )
        else
            caller.callback_function( o, message, result )
        end
    else
        --adroit.alert( "BAD CALLER ID!" )
        return "s", "Invalid call id: " .. tostring( call_id )
    end

    return "s", "Message received." 
end


-----------------------------------------------------------------------------

function register()

    dbus.request_name( "session", dbus_name )
    dbus_monitor = adroit.dbus.Monitor:new(
        dbus_name .. ".dbus",
        {
            member = "MethodCallResult",
            type = "method_call",
        }
    )
    dbus_monitor.receive = receive
    dbus_monitor:activate()
    registered = true
end


-----------------------------------------------------------------------------

function set_dbus_name( name )
    dbus_name = name
end

-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize(
    bus, destination, path, interface, method, arguments,
    callback_function, callback_object
)
    __super.initialize( self )
    self.arguments = arguments
    self.bus = bus
    self.callback_function = callback_function
    self.callback_object = callback_object
    self.destination = destination
    self.interface = interface
    self.member = method
    self.path = path
end


-----------------------------------------------------------------------------

-- Invoke the method.
function _M:invoke( method, arguments )

    -- Ensure the class has been initialized:
    if not registered then
        register()
    end

    -- Get the call id:
    local call_id = next_call_id
    next_call_id = call_id + 1
    callers[ call_id ] = self

    -- Construct the command:
    local command = (
        adroit.location .. "/dbus/MethodCaller.py" ..
        " -c " .. call_id ..
        " -r " .. dbus_name ..
        " -b " .. self.bus ..
        " -d " .. self.destination ..
        " -p " .. self.path ..
        " -i " .. self.interface ..
        " -m " .. ( method or self.member )
    )

    arguments = arguments or self.arguments
    if arguments ~= nil then
        for i, arg in ipairs( arguments ) do
            command = command .. " " .. arg
        end
    end

    --print( "Executing: " .. command )

    -- Invoke the method:
    awful.util.spawn( command, false )
end


-----------------------------------------------------------------------------

-- vi: set filetype=lua shiftwidth=4 tabstop=4 expandtab:
