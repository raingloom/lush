---Highly dynamic OOP implementation.
local Object = { _id = 1, _name = 'Object', _includes = {} }
Object.__index = Object


function Object:new( ... )
	local ret = self:allocate( ... )
	ret:initialize( ... )
	return ret
end


function Object:allocate( ... )
	--local id = self._id
	--self._id = id + 1
	return setmetatable( { _class = self, --[[_id = id]] }, self )
end


function Object:initialize( ... )
end


--[=[
--[[
	Copy the object instance or the class. This is a deep copy.
	@param t the table to copy into (optional)
	@return deep copy
]]
function Object:copy( t )
	t = t or {}
	for k, v in pairs( self ) do
		t[ k ] = v
	end
	return t
end
]=]


--[[function Object:__tostring()
	return self._class._name..'<'..self._id..'>'
end]]


--[[--
	Form a new subclass that extends the current class. This is the standard way of creating new classes. Metamethods are copied over _(anything that starts with "\_\_" is considered one)_.
	param: name an optional name, defaults to AnonymousClass
	usage: local Animal = require'Object':extend'Animal'
]]
function Object:extend( name )
	local ret = {}
	for k, v in pairs( self ) do
		if k:sub( 1, 2 ) == '__' then
			ret[ k ] = v
		end
	end
	ret.__index = ret
	ret._name = name or 'AnonymousClass('..tostring( ret )..')'
	ret._super = self
	--ret._id = 1
	ret._includes = { table.unpack( self._includes ) }
	return setmetatable( ret, { __index = self } )
end


--[[--
	Check if the `object` is a member of `self`
	param: object the object to test
]]
function Object:isInstanceOf( object )
	local cls = object._class
	if cls == nil then
		return cls == self
	else
		return getmetatable( cls ) == self
	end
end


--[[--
	Check if `self` is an instance of `class`
	param: class the class to check against
]]
function Object:amInstanceOf( class )
	local cls = self._class
	if cls == nil then
		return cls == class
	else
		return getmetatable( cls ) == class
	end
end


--[[--
	Infects the class with a mixin. This is either done by simply doing a shallow copy of each mixin into the class or by calling the special `_included` function.
	param: ... mixins to be included
	see: Object.Memoized:_included
]]
function Object:include( ... )
	local includes = self._includes
	local len = #includes
	for i, mixin in ipairs{...} do
		if mixin._included then
			mixin:_included( self )
		else
			for k, v in pairs( mixin ) do
				self[ k ] = v
			end
		end
		includes[ len+i ] = mixin
	end
end


---Checks if the class is a subclass of another. Uses a simple upwards iteration on `_super` fields.
--param: class alleged parent class
--return: true if `class` was found, false otherwise
function Object:isSubclassOf( class )
	while self._super do
		if self._super == class then
			return true
		end
		self = self._super
	end
	return false
end


return Object