-----------------------------------------------------------------------------
-- Class WicdQuery
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.widget.Widget", adroit.seeall )
_M.__index = _M -- This module is a class.

adroit.require( "adroit.dbus.MethodCaller" )


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize( name, method, arguments, callback_function, callback_object )
    __super.initialize( self )

	self.callback_function = callback_function
	self.callback_object = callback_object
	self.name = name

	self.gwp = false
	if method == "GetWirelessProperty" then
		self.gwp = true
	end

    self.dbus_method_caller = adroit.dbus.MethodCaller:new(
        "system", "org.wicd.daemon", "/org/wicd/daemon/wireless",
        "org.wicd.daemon.wireless", method, arguments,
        notify, self
    )

end


-----------------------------------------------------------------------------

function _M:send( network_no )

	local arguments = nil

	if self.gwp then

		-- Do nothing if network number is unknown:
		if network_no == nil then
			return
		end

		arguments = { "i:" .. network_no, "s:" .. self.name }
	end

    self.dbus_method_caller:invoke( nil, arguments )
end


-----------------------------------------------------------------------------

-- Receive an event notification.
function _M:notify( message, status )
    self.callback_function( self.callback_object, message, self.name, status )
end


-----------------------------------------------------------------------------

-- vi: set filetype=lua shiftwidth=4 tabstop=4 expandtab:
