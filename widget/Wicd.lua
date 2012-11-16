-----------------------------------------------------------------------------
-- Class Wicd
-----------------------------------------------------------------------------

adroit.module_extends( ..., "adroit.widget.Widget", adroit.seeall )
_M.__index = _M -- This module is a class.

adroit.require( "adroit.dbus.MethodCaller" )
adroit.require( "adroit.dbus.Monitor" )
adroit.require( "adroit.widget.WicdQuery" )


-----------------------------------------------------------------------------
-- signal sender=:1.3 -> dest=(null destination) serial=1192836 path=/org/wicd/daemon; interface=org.wicd.daemon; member=ConnectResultsSent
--    string "success"

-- signal sender=:1.3 -> dest=(null destination) serial=1077935 path=/org/wicd/daemon; interface=org.wicd.daemon; member=StatusChanged
--    uint32 2
--    array [
--       variant          string "10.0.1.45"
--       variant          string "DeepSearch"
--       variant          string "97" -- signal strength
--       variant          string "0" -- current network id (index into scanned ssids)
--       variant          string "54 Mb/s" -- current bitrate
--    ]

-- state:

--            state = 
--                NOT_CONNECTED = 0
--                CONNECTING = 1
--                WIRELESS = 2
--                WIRED = 3
--                SUSPENDED = 4
--            info = [
--                str(wifi_ip),
--                wireless.GetCurrentNetwork(iwconfig),
--                str( self._get_printable_sig_strength() ),
--                str(wireless.GetCurrentNetworkID(iwconfig)),
--                wireless.GetCurrentBitrate(iwconfig)
--            ]

-----------------------------------------------------------------------------

--image_prefix = adroit.location .. "/themes/Faenza/64/gnome-netstatus-"
--image_states = {
--    disconnected = "disconn",
--    idle = "idle",
--    transmitting = "tx",
--    receiving = "rx",
--    duplex = "txrx",
--}
-- More-or-less arbitrary thresholds for the various icons:
--status_thresholds = {
--    [ 00 ] = "0-24",
--    [ 25 ] = "25-49",
--    [ 50 ] = "50-74",
--    [ 75 ] = "75-100",
--}

image_prefix = adroit.location .. "/themes/Faenza/64/notification-network-wireless-"
image_states = {
    disconnected = "disconnected",
}
-- More-or-less arbitrary thresholds for the various icons:
status_thresholds = {
    [ 00 ] = "none",
    [ 06 ] = "low",
    [ 40 ] = "medium",
    [ 70 ] = "high",
    [ 85 ] = "full",
}

image_suffix = ".png"


-----------------------------------------------------------------------------

-- Instance initializer.
function _M:initialize( device )
    __super.initialize( self )

    self.device = device or "wlan0"
    self.icon_name = ""

    -- Create dbus monitor for status updates:
    self.dbus_monitor = adroit.dbus.Monitor:new(
        "org.wicd.daemon", {
            member = "StatusChanged",
            path = "/org/wicd/daemon",
            --sender = "org.wicd.daemon",
            type = "signal",
        }
    )
    self.dbus_monitor.receive = function ( ... )
        self:notify( ... )
    end

    -- Initialize queries:
    cb = receive_poll
    sarg = { "s:" }
    WicdQuery = adroit.widget.WicdQuery
    self.queries = {}
    for i, query in ipairs( {
        WicdQuery:new( "bitrate", "GetCurrentBitrate", sarg, cb, self ),
        WicdQuery:new( "bssid", "GetApBssid", nil, cb, self ),
        WicdQuery:new( "channel", "GetWirelessProperty", nil, cb, self ),
        WicdQuery:new( "connecting", "CheckIfWirelessConnecting", nil, cb, self ),
        WicdQuery:new( "connecting_status", "CheckWirelessConnectingStatus", nil, cb, self ),
        WicdQuery:new( "connection_up", "IsWirelessUp", nil, cb, self ),
        WicdQuery:new( "encryption", "GetWirelessProperty", nil, cb, self ),
        WicdQuery:new( "encryption_method", "GetWirelessProperty", nil, cb, self ),
        WicdQuery:new( "essid", "GetCurrentNetwork", sarg, cb, self ),
        WicdQuery:new( "hidden", "GetWirelessProperty", nil, cb, self ),
        WicdQuery:new( "ip_address", "GetWirelessIP", sarg, cb, self ),
        WicdQuery:new( "mode", "GetWirelessProperty", nil, cb, self ),
        WicdQuery:new( "network_no", "GetCurrentNetworkID", sarg, receive_id, self ),
        WicdQuery:new( "quality", "GetWirelessProperty", nil, cb, self ),
        WicdQuery:new( "strength", "GetWirelessProperty", nil, cb, self ),
    } ) do
        self.queries[ query.name ] = query
    end

    self.status = {}
    self.tooltip = awful.tooltip( {} )
    self.tooltip:set_text( "No data yet." )
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
    self.poll:now()
end


-----------------------------------------------------------------------------

-- Return a new instance in the form of awesome widgets.
function _M:get_ui()
    local w = widget( { type = "imagebox" } )
    self.interfaces[ #self.interfaces + 1 ] = w

    --if self.icon_name == "" then
        --self.poll:now()
    --end

    self.tooltip:add_to_object( w )

    return w
end


-----------------------------------------------------------------------------

-- Receive an event notification.
function _M:notify( match_info, message, state, info )

-- match_info (key->type)
--     match_arguments=table
--     receive=function
--     active_busses=table
-- 
-- message (key->type)
--     bus=string
--     type=string
--     member=string
--     path=string
--     interface=string

    -- Update state:
    status = self.status
    if state == 0 then -- NOT_CONNECTED
        status.connecting = false
        status.connection_up = false
        status.connecting_status = "Not connecting"
    elseif state == 1 then -- CONNECTING
        status.connecting = true
        status.connection_up = false
        status.connecting_status = "Connecting"
    elseif state == 2 then -- WIRELESS
        status.connecting = false
        status.connection_up = true
        status.connecting_status = "Connected"
    --elseif state == 3 then -- WIRED
    elseif state == 4 then -- SUSPENDED
        status.connecting = false
        status.connection_up = false
        status.connecting_status = "Suspended"
    end

    -- Update other status properties:
    status.ip_address = info[ 1 ]
    status.essid = info[ 2 ]
    status.quality = info[ 3 ]
    status.network_no = info[ 4 ]
    status.bitrate = info[ 5 ]

    self:update()

    -- If we need to update more status, do so now:
    if true then
        self:receive_id( nil, "network_no", status.network_no )
    end
end


-----------------------------------------------------------------------------

-- Reset all widget UIs.
--function _M:refresh()
--end


-----------------------------------------------------------------------------

-- Query battery status.
function _M:receive_id( message, name, network_no )

    --adroit.alert( name .. ": '" .. tostring( network_no ) .. "'", "receive_id" )

    self.status.network_no = network_no

    -- Query remaining properties:
    for name, query in pairs( self.queries ) do
        if name ~= "network_no" then
            query:send( network_no )
        end
    end
end


-----------------------------------------------------------------------------

-- Process query response.
function _M:receive_poll( message, name, status )

    --print(
        --"Received: Name='" .. name .. "', " ..
        --"Type: " .. type( status ) .. ", " ..
        --"Value: " .. tostring( status )
    --)

    self.status[ name ] = status
    self:update()
end


-----------------------------------------------------------------------------

-- Query status properties.
function _M:send_poll()

    -- Start by getting the current network number:
    self.queries.network_no:send()
end


-----------------------------------------------------------------------------

-- Update all widget UIs as needed.
function _M:update()

--    image_states = {
--        disconnected = "disconn",
--        idle = "idle",
--        transmitting = "tx",
--        receiving = "rx",
--        duplex = "txrx",
--    }

    local icon_name = ""
    local status = self.status

    local quality = tonumber( status.quality )
    if status.connection_up then
        if quality ~= nil then

            local level = 0
            icon_name = status_thresholds[ 0 ]
            for threshold, name in pairs( status_thresholds ) do
                if quality >= threshold and level < threshold then
                    icon_name = name 
                    level = threshold
                end
            end
        end
    else
        icon_name = image_states.disconnected
    end

    -- Check if the icon we're using should change:
    if self.icon_name ~= icon_name then
        self.icon_name = icon_name
        
        -- Update the icons for all interfaces:
        for i, widget in pairs( self.interfaces ) do
            widget.image = image(
                image_prefix .. icon_name .. image_suffix
            )
        end
    end

    self:update_tooltip()
end


-----------------------------------------------------------------------------

function _M:update_tooltip()

    local s = self.status
    local u = "Unknown"
    self.tooltip:set_text(
        "Device: " .. self.device .. "\n" ..
        "Connected to: " .. ( s.essid or u ) .. "\n" ..
        "IP address: " .. ( s.ip_address or u ) .. "\n" ..
        "BSSID: " .. ( s.bssid or u ) .. "\n" ..
        "Encryption: " .. ( s.encryption_method or u ) .. "\n" ..
        "Signal: " .. ( s.quality or u ) .. "%\n" ..
        "Bitrate: " .. ( s.bitrate or u )
    )

end


-----------------------------------------------------------------------------

-- vi: set filetype=lua shiftwidth=4 tabstop=4 expandtab:
