return {
	_included = function( mixin, class )
		local extend = class.extend
		function class:extend( name )
			local ret = extend( self, name )
			self[ name ~= nil and name or #self + 1 ] = ret
			ret:include( mixin )
			return ret
		end
	end
}