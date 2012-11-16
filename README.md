awesome-adroit
==============

Lua modules to support configuration of the awesome window manager.


Philosophy
--------------

Keep widgets fast:
- Use event handlers instead of polling wherever doing so will reduce
computational overhead (e.g., don't wake unless status has changed).
- Use asynchronous calls when polling for status info wherever possible, to
avoid hanging awesome.
- Use only one widget "engine" for mutiple UI instances.  E.g., if
the same widget appears on multiple screens, use a single status
monitoring process to refresh widget UI instances across all screens.


Implemented widgets
--------------

Barely implemented:
- Battery
- Wicd


Example
--------------

```lua
require( "adroit" )

battery_widget = adroit.widget.Battery:new( "BAT0" )
battery_widget.poll = adroit.widget.poller.Demand:new()
battery_widget:enable()

wicd_widget = adroit.widget.Wicd:new( "wlan0" )
wicd_widget.poll = adroit.widget.poller.Demand:new()
wicd_widget:enable()

for s = 1, screen.count() do
	
    mywibox[ s ].widgets = {
        battery_widget:get_ui(),
        wicd_widget:get_ui(),
        layout = awful.widget.layout.horizontal.rightleft
    }
end
```

