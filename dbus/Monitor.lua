-----------------------------------------------------------------------------
-- Class Monitor
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.Object", adroit.seeall )
_M.__index = _M -- This module is a class.

adroit.require( "adroit.dbus.Message" )


-----------------------------------------------------------------------------

-- Map from interfaces to monitors:
interfaces = {}


-----------------------------------------------------------------------------

function activate_monitor( bus, monitor )

	-- Do nothing if the monitor is already active on the requested bus:
	if monitor.active_busses[ bus ] then
		return
	end

	-- Add this monitor to the list of monitors for its interface:
	local interface = monitor.match_arguments.interface
	local active_monitors = interfaces[ interface ]
	if active_monitors == nil then
		--active_monitors = interfaces[ interface ] = {}
		active_monitors = {}
		interfaces[ interface ] = active_monitors
	end
	if #monitor.active_busses == 0 then
		active_monitors[ #active_monitors + 1 ] = monitor
	end

	-- Register to receive messages for this interface:
	if #active_monitors == 1 then
		dbus.add_signal( interface, process_message )
	end
	dbus.add_match( bus, monitor:get_match_rule() )

	-- Indicate that the monitor is active on this bus:
	monitor.active_busses[ bus ] = true
end


-----------------------------------------------------------------------------

function process_message( msg, ... )

	-- Convert the raw message into a Message object:
	local message = adroit.dbus.Message:new( msg )

	-- Validate the message interface:
	local interface = message.interface
	if interface == nil or interface == "" then
		naughty.notify( {
			preset = naughty.config.presets.critical,
			title = adroit.dbus.Monitor,
			text = "Expected message to have an interface property."
		} )
		return
	end

	-- Ensure we were listening for that message:
	local active_monitors = interfaces[ message.interface ]
	if active_monitors == nil then
		naughty.notify( {
			preset = naughty.config.presets.critical,
			title = adroit.dbus.Monitor,
			text = "Unexpected message for interface: '" .. interface .. "'"
		} )
		return
	end

	-- Notify all monitors.  Note, we don't match rule arguments here.  A
	-- full solution for that would require handling of wildcards, etc.
	for key, monitor in pairs( active_monitors ) do
		monitor:receive( message, ... )
	end
end


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize( interface, rule )
	__super.initialize( self )

	self.active_busses = {}
	self.match_arguments = {
		interface = interface
	}
	if rule ~= nil then
		self:set_match_rule( rule )
	end
end


-----------------------------------------------------------------------------

-- Activate the monitor.
function _M:activate( bus )

	if bus == nil then
		activate_monitor( "session", self )
		activate_monitor( "system", self )
	else
		activate_monitor( bus, self )
	end
end


-----------------------------------------------------------------------------

-- Compile a match rule from key/value pairs in self.match_arguments:
function _M:get_match_rule( bus )

	-- Build the watch expression:
	local match_rule = ""
	for key, value in pairs( self.match_arguments ) do
		if value ~= nil then
			value = tostring( value )
			if value ~= "" then
				local separator = ""
				if match_rule ~= "" then
					separator = ","
				end
				match_rule = match_rule .. separator .. key .. "='" .. value .. "'"
			end
		end
	end

	return match_rule
end


-----------------------------------------------------------------------------

-- Check if the monitor is active (or active on a specified bus).
function _M:is_active( bus )

	if bus == nil then
		return #active_busses > 0
	else
		return #active_busses[ bus ] > 0
	end
end


-----------------------------------------------------------------------------

-- Called when a new message has been received.
function _M:receive( message )
	naughty.notify( {
		preset = naughty.config.presets.normal,
		title = adroit.dbus.Monitor,
		text = "Message received but no handler defined for interface:\n" .. message.interface
	} )
end


-----------------------------------------------------------------------------

-- Set message match rule.
function _M:set_match_rule( rule )
	rule.interface = self.match_arguments.interface
	self.match_arguments = rule
end


-----------------------------------------------------------------------------

