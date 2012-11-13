-----------------------------------------------------------------------------
-- Class Battery
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.widget.Widget", adroit.seeall )
_M.__index = _M -- This module is a class.

adroit.require( "adroit.dbus.MethodCaller" )
adroit.require( "adroit.dbus.Monitor" )


-----------------------------------------------------------------------------

-- Also saw this message when on AC power:
--signal sender=:1.88 -> dest=(null destination) serial=2953 path=/org/freedesktop/UPower; interface=org.freedesktop.UPower; member=DeviceChanged
--   string "/org/freedesktop/UPower/devices/battery_BAT0"


-----------------------------------------------------------------------------

image_prefix = adroit.location .. "/themes/Faenza/64/gpm-battery-"
image_suffix = ".png"

-- More-or-less arbitrary thresholds for the various icons:
status_thresholds = {
	[ 00 ] = "000",
	[ 08 ] = "020",
	[ 30 ] = "040",
	[ 55 ] = "060",
	[ 80 ] = "080",
	[ 90 ] = "100",
}


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize( device )
	__super.initialize( self )

	self.device = device or "BAT0"
	self.icon_name = ""

	-- Create dbus monitor:
	local path = "/org/freedesktop/UPower/devices/battery_" .. self.device
	self.dbus_monitor = adroit.dbus.Monitor:new(
		"org.freedesktop.UPower.Device", {
			member = "Changed",
			path = path,
			sender = "org.freedesktop.UPower",
			type = "signal",
		}
	)
	self.dbus_monitor.receive = function ( message )
		self:notify( message )
	end

	self.dbus_method_caller = adroit.dbus.MethodCaller:new(
		"system", "org.freedesktop.UPower", path,
		"org.freedesktop.DBus.Properties", "GetAll",
		"org.freedesktop.UPower.Device",
		self.receive_poll, self
	)

end


-----------------------------------------------------------------------------

-- Disable all polling, event listeners, and any further UI updating.
--function _M:disable()
--end


-----------------------------------------------------------------------------

-- Enable polling, event listeners, and UI updating.
function _M:enable()
	__super.enable( self )

	self.dbus_monitor:activate( "system" )
	self.poll:set_poll_function( send_poll, self )
end


-----------------------------------------------------------------------------

-- Return a new instance in the form of awesome widgets.
function _M:get_ui()
	local w = widget( { type = "imagebox" } )
	self.interfaces[ #self.interfaces + 1 ] = w

	if self.icon_name == "" then
		self.poll:now()
	end

	--w.image = image( image_prefix .. self.icon_name .. image_suffix )

	return w
end


-----------------------------------------------------------------------------

-- Receive an event notification.
function _M:notify( message )
	self.poll:now()
end


-----------------------------------------------------------------------------

-- Reset all widget UIs.
--function _M:refresh()
--end


-----------------------------------------------------------------------------

-- Update all widget UIs as needed.
function _M:update( state, percentage )

	local level = 0
	local level_string = "000"

	for threshold, ls in pairs( status_thresholds ) do
		if percentage >= threshold and level < threshold then
			level_string = ls
			level = threshold
		end
	end

	local charging = ""
	if state == 1 then
		charging = "-charging"
	end

	-- Check if the icon we're using should change:
	local icon_name = level_string .. charging 
	if self.icon_name ~= icon_name then
		self.icon_name = icon_name

		-- Update the icons for all interfaces:
		for i, widget in pairs( self.interfaces ) do
			widget.image = image(
				image_prefix .. icon_name .. image_suffix
			)
		end
	end
end


-----------------------------------------------------------------------------

-- Process battery status update.
function _M:receive_poll( message, status )

-- IsRechargeable = boolean
-- EnergyRate = string
-- Vendor = string
-- Online = boolean
-- RecallNotice = boolean
-- PowerSupply = boolean
-- HasStatistics = boolean
-- RecallUrl = string
-- EnergyFull = string
-- EnergyEmpty = string
-- TimeToFull = number
-- TimeToEmpty = number
-- Type = number
-- IsPresent = boolean
-- UpdateTime = number
-- Capacity = string
-- Percentage = string
-- HasHistory = boolean
-- EnergyFullDesign = string
-- State = number
-- NativePath = string
-- RecallVendor = string
-- Model = string
-- Technology = number
-- Energy = string
-- Serial = string
-- Voltage = strin




	--t = ""
	--for key, value in pairs( status ) do
		--t = t .. key .. "=" .. type( value ) .. "\n"
	--end
	--print( "Status: " .. t .. "FIN" )

	-- If icon changes, then update UIs
	self:update( status.State, tonumber( status.Percentage ) )
end


-----------------------------------------------------------------------------

-- Query battery status.
function _M:send_poll()

	self.dbus_method_caller:invoke()
end


-----------------------------------------------------------------------------


