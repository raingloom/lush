local Object = require 'eject'

local Lush = Object:extend 'Lush'
Lush:include( require 'eject.mixins.SubclassIsSubtable' )
--[[do
	function Lush:getenv()
		local env = _ENV or _G
		if self.Env:isInstanceOf( env ) then
			return env
		else
			return nil
		end
	end
	
	function Lush:commit()
		local env = self:getenv()
		if env then
			env:commit()
		end
	end
	
	function Lush:begin( cmd )
		local env = self:getenv()
		if env then
			env:push()
		end
	end
end--]]

local Exception = Lush:extend 'Exception'
do
	function Exception:initialize( name )
		self.name = name
	end
	
	function Exception:__tostring()
		return self.name and self.name..'\n'..debug.traceback() or self
	end
end
Exception:extend 'StdioName'


local Redirection = Lush:extend 'Redirection'
local RedirectionStep = Redirection:extend 'Step'
local RedirectionChain = Redirection:extend 'Chain'
do
	function RedirectionStep:initialize( from, to, append )
		self.from = from
		self.to = to
		self.append = not not append
	end
	
	function RedirectionStep:chain( other )
		return Lush.Redirection.Chain:new( self, other )
	end
	
	function RedirectionChain:initialize( ... )
		self.steps = { ... }
	end
	
	function RedirectionChain:chain( other )
		error 'TODO'
	end
end


local AbstractFileDesc = Lush:extend 'AbstractFileDesc'
do
	function AbstractFileDesc:appendTo( other )
		return Lush.Redirection.Step:new( self, other, true )
	end
	
	function AbstractFileDesc:writeTo( other )
		return Lush.Redirection.Step:new( self, other, false )
	end
	
	AbstractFileDesc.__bxor = AbstractFileDesc.appendTo
	AbstractFileDesc.__sub = AbstractFileDesc.writeTo
end


AbstractFileDesc:extend 'FileDesc'
local StdioDesc = AbstractFileDesc:extend 'StdioDesc'
do
	function StdioDesc:initialize( name )
		local what = name:match '^std(%a+)$'
		if what == 'in' or what == 'out' or what == 'err' then
			self.name = name
		else
			error( Lush.Exception.StdioName:new( 'invalid standard io name, should be one of std{in|out|err}' ))
		end
	end
end


local Command = Lush:extend 'Command'
do
	function Command:initialize( name )
		local currentenv = loadstring( 'return _ENV' )()
		--[[ugh, so, this is necessary because even though _ENV is global variable,
		it is actually an upvalue, that gets bound at function definition time,
		so we get around that by creating a function in the current env]]
		Lush:commit()
		Lush:begin( self )
		self.name = name
		self.redirections = {}
	end
	
	function Command:redirect( redirection )
		table.insert( self.redirections, redirection )
		return self
	end
	Command.__bxor = Command.redirect
	
	function Command:evaluate()
		error 'TODO'
	end
	
	function Command:addArgs( ... )
		print'TODO: addArgs'
		return self
	end
	
	function Command:__call( ... )
		local x = ...
		if x ~= nil then
			self:addArgs( ... )
			return self
		else
			return self:evaluate()
		end
	end
end


local Name = Lush:extend 'Name'
do
	function Name:initialize( name )
		self.name = name
	end

	function Name:__bnot()
		return StdioDesc:new( self.name )
	end
	
	for method in ('__bxor,__call,redirect'):gmatch( '[^,]+' ) do
		Name[ method ] = function( self, ... )
			local cmd = Command:new( self.name )
			return cmd[ method ]( cmd, ... )
		end
	end
end


local Env = Lush:extend 'Env'
do
	function Env:initialize( super )
		self.superenv = super--needs to be non-nil, otherwise we'd get a stack overflow in the __index metamethod
		self.inprogress = {}
	end
	
	local rawget, type = rawget, type
	function Env:__index( name )
		local classthing = self._class[ name ]
		if classthing ~= nil then
			return classthing
		end
		local superenv = rawget( self, 'superenv' )
		local superthing = type( superenv ) == 'table' and superenv[ name ]
		if superthing ~= nil then
			return superthing
		else
			return Name:new( name )
		end
	end
	
	function Env:begin( cmd )
		table.insert( self.inprogress, cmd )
	end
	
	function Env:commit()
		for _, cmd in ipairs( self.inprogress ) do
			cmd:evaluate()
		end
		self.inprogress = {}
	end
	
	--used to coerce string into file descriptors
	function Env:f( ... )
		return Lush.AbstractFileDesc.FileDesc:new( ... )
	end
end


return Lush