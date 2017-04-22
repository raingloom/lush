---Provides some utilities for working with OOP.
local M = {}


---Iterates the superclasses of `class`.
function M.superclasses( class )
	return function()
		if class then
			class = class._super
		end
		return class
	end
end


---An alternative for `Object:isSubclassOf`.
--see: Object:isSubclassOf
function M.isSubclassOf( class )
	for sup in M.superclasses( class ) do
		if sup == class then
			return true
		end
	end
	return false
end


function M.properName( class )
	local buf, i = { class._name }, 2
	for sup in M.superclasses( class ) do
		buf[ i ], i = sup._name, i + 1
	end
	for j = 1, i//2 do
		i = i - 1
		buf[j], buf[i] = buf[i], buf[j]
	end
	return table.concat( buf, '.' )
end


function M.doesImplement( class, ... )
	for _, mixin in table.pack(...) do
		for k, v in pairs( mixin ) do
			if class[k] ~= v then
				return false
			end
		end
	end
	return true
end


function M.cautioslyImplement( class, ... )
	local blacklist = {}
end


--[[--
	Propagates _every_ value found in superclass tables to `class`. Useful if you want to make variable access faster or make the class tamper-free.
	param: class the class to operate on
	param: overwrite whether to overwrite existing values
]]
function M.copyUp( class, overwrite )
	local sup, i = {}, 1
	for s in M.superclasses( class ) do
		sup[i], i = s, i+1
	end
	for i = i-1, 1 do
		for k, v in pairs( sup[ i ] ) do
			--TODO: maybe optimize this? is that even needed?
			if overwrite then
				if class[ k ] == nil then
					class[ k ] = v
				end
			else
				class[ k ] = v
			end
		end
	end
end


return M