local inspect = require 'inspect'
local Lush = require 'lush'

local function dump( x, ... )
	print( inspect( x, ... ))
	return x
end

local print, loadstring = print, loadstring
local function printenv()
	print( loadstring'return _ENV'() )
end

printenv()
do
	local _ENV = {}
	printenv()
end

--[[
local result
do
	local _ENV = Lush.Env:new( _ENV or _G )
	cmd '1' '2'
	cmd '2'
	cmd '3'
end
--]]