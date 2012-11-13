-----------------------------------------------------------------------------
-- Package adroit
-----------------------------------------------------------------------------

local _G = _G

module( ... )


-----------------------------------------------------------------------------

location = _G.awful.util.getdir("config") .. "/adroit"


-----------------------------------------------------------------------------

-- From: http://lua-users.org/wiki/ModuleDefinition

-- Adaption of "Take #1" of cleanmodule by Ulrik Sverdrup.
--
-- The first example, with inspiration from #4 to split module and seeall
-- into orthogonal functions.  Here, we use one single table for the module
-- namespace, to avoid all sync issues with the double system.  The private
-- module environment is an empty proxy table, with a custom-defined lookup
-- routine (_M[k] or _G[k], that's it).  The indirections in private lookups
-- assume that module lookups are more important to be fast externally than
-- internally (you can use locals internally).

-- Declare module cleanly:
--  module is registered in package.loaded,
--  but not inserted in the global namespace
local function _module( _m, modname, ... )

    -- Define for partial compatibility with module():
    _m._M = _m
    _m._NAME = modname
    _m._PACKAGE = modname:gsub( "[^.]*$", "" )

	-- Define an environment for the module:
    local environment = {}
    _G.setmetatable( environment, {

		__index = function( table, key )
			return _m[ key ] or pollution[ key ]
		end,

		__newindex = _m
    } )
    _G.setfenv( 3, environment ) -- Note: This must come before decorators are applied.

    -- Apply decorators to the module:
    if ... then
		for _, func in _G.ipairs( { ... } ) do
			func( _m )
		end
    end

    _G.package.loaded[ modname ] = _m
	return _m
end

function module( modname, ... )
    return _module( {}, modname, ... )
end


-----------------------------------------------------------------------------

-- Called as adroit.module(..., adroit.seeall).  Use a private proxy environment for
-- the module, so that the module can access global variables.
--  * Global assignments inside module get placed in the module.
--  * Lookups in the private module environment query first the module,
--    then the global namespace.
function seeall( _m )
	_G.getmetatable( _G.getfenv( 4 ) ).__index = function( table, key )
		return _m[ key ] or pollution[ key ] or _G[ key ]
	end
end


-----------------------------------------------------------------------------

-- Require module, but store module only in private namespace of caller (not
-- public namespace).  Note: Elided is a recommended rawset version of:
-- http://lua-users.org/wiki/SetVariablesAndTablesWithFunction
local function _require( name )
    --_G.print( "Requiring '" .. name .. "'..." )
    --local current_modname = _G.getfenv( 3 )._NAME
    --if current_modname ~= nil then
		--name = current_modname .. "." .. name
		--_G.print( "Expanding to '" .. name .. "'." )
    --end
    local result = _G.require( name )
    _G.rawset( _G.getfenv( 3 ), name, result )
    return result
end

function require( name )
    return _require( name )
end


-----------------------------------------------------------------------------

function module_extends( modname, parent, ... )

	-- Convert parent name to module:
    parent = _require( parent )

	-- Create the new module:
    local _m = _module( create_object( parent ), modname, ... )
	_m.__super = parent

	-- Define useful properties in the scope chain:
	local environment = _G.getfenv( 2 )
end


-----------------------------------------------------------------------------

-- Object generator.
function create_object( _M )
	local o = {}
	_G.setmetatable( o, _M )
	return o
end


-----------------------------------------------------------------------------

-- Instance initializer.
function alert( text, title )
	_G.naughty.notify( {
		preset = _G.naughty.config.presets.normal,
		title = title or "adroit alert",
		text = text
	} )
end


-----------------------------------------------------------------------------

-- Properties to add to module search space:
pollution = {
	adroit = _M,
	alert = alert,
	--__create_object = create_object,
}


-----------------------------------------------------------------------------
-- Require sub-modules:

dbus = require( 'adroit.dbus' )
--util = require( 'adroit.util' )
widget = require( 'adroit.widget' )


-----------------------------------------------------------------------------

-- vim: filetype=lua:noexpandtab:shiftwidth=4:tabstop=8:softtabstop=4
