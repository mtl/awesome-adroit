#!/usr/bin/python2

import argparse
import dbus

#----------------------------------------------------------------------------

#interface = "org.freedesktop.DBus.Properties"
#destination = "org.freedesktop.UPower"
#object_path = "/org/freedesktop/UPower/devices/battery_BAT0"
#member = "GetAll"
#args = "string:org.freedesktop.UPower.Device"


#----------------------------------------------------------------------------

parser = argparse.ArgumentParser(
	description = 'Call a DBus method and submit the results to the awesome adroit module.'
)
parser.add_argument(
	'-c', '--call-id', dest = 'call_id', action = 'store', required = True,
	help = 'unique identifier for this method call'
)
parser.add_argument(
	'-b', '--bus', dest = 'bus', action = 'store', required = True,
	choices = ( 'system', 'session' ),
	help = 'DBus bus on which to connect to the destination'
)
parser.add_argument(
	'-d', '--destination', dest = 'destination', action = 'store', required = True,
	help = 'destination of the object (see -p)'
)
parser.add_argument(
	'-p', '--path', dest = 'path', action = 'store', required = True,
	help = 'path of the object on which the method will be called'
)
parser.add_argument(
	'-i', '--interface', dest = 'interface', action = 'store', required = True,
	help = 'interface of the method to be called'
)
parser.add_argument(
	'-m', '--method', '--member', dest = 'member', action = 'store', required = True,
	help = 'member (i.e., method) to be called'
)
parser.add_argument(
	'arguments', metavar = 'arg', nargs = '+',
	help = 'Arguments for the method call'
)

args = parser.parse_args()
#print(args.accumulate(args.integers))


#----------------------------------------------------------------------------

def main( args ):
	#print( "Calling..." )
	result = call_method( args )
	#print( "Result: " )
	#print( result )
	#print( "Returning..." )
	result = call_awesome_with_result( args, result )
	#print( "Received: " )
	#print( result )


#----------------------------------------------------------------------------

def call_awesome_with_result( args, result ):

	dbus_bus = dbus.SessionBus()
	try:
		dbus_object = dbus_bus.get_object(
			"org.naquadah.awesome.adroit", "/"
		)
		return dbus_object.MethodCallResult(
			args.call_id, result,
			dbus_interface = "org.naquadah.awesome.adroit.dbus"
		)
	except dbus.exceptions.DBusException:
		print( "Could not connect to awesome+adroit." )


#----------------------------------------------------------------------------

def call_method( args ):

	# Get the requested bus:
	if args.bus == 'system':
		dbus_bus = dbus.SystemBus()
	else:
		dbus_bus = dbus.SessionBus()

	# Get a DBus proxy object:
	dbus_object = dbus_bus.get_object( args.destination, args.path )

	# Invoke the method and store its result:
	result = getattr( dbus_object, args.member )(
		"org.freedesktop.UPower.Device", dbus_interface = args.interface
	)

	# Convert doubles to strings, since awesome doesn't handle doubles:
	return fix_doubles( result )


#----------------------------------------------------------------------------

def fix_doubles( value ):
	vtype = type( value )

	if vtype == dbus.Dictionary:
		for key, val in value.iteritems():
			if type( val ) == dbus.Double:
				value[ key ] = str( val )

	elif vtype == dbus.Array:
		for i in range( len( value ) ):
			val = value[ i ]
			if type( val ) == dbus.Double:
				value[ i ] = str( val )
	
	elif vtype == dbus.Struct:
		value = list( value )
		for i in range( len( value ) ):
			val = value[ i ]
			if type( val ) == dbus.Double:
				value[ i ] = str( val )
		value = tuple( value )

	elif vtype == dbus.Double:
		value = str( value )

	return value
	

#----------------------------------------------------------------------------

main( args )


#----------------------------------------------------------------------------

#introspection_interface = dbus.Interface(
	#dbus_object,
	#dbus.INTROSPECTABLE_IFACE,
#)
#interface = introspection_interface.Introspect()
#print interface

# vim: filetype=python:noexpandtab:shiftwidth=4:tabstop=8:softtabstop=4
