ping{ c = 1, '8.8.8.8' } | sed 's/packets/schblorgies/'
cmd '/bin/echo' { n = true, 'foo' 'bar' }

(cat '/etc/resolv.conf' > 'copy')() -- copy is a file
cat 'foo' > sed -- redirect to stdin of sed
cat < 'input' -- just like cat
cat | sed | grep | awk

-- how do we implement this?
-- gcc 1>&2 
-- let's get rid of magic numbers
(gcc ~ (~stderr > ~stdout) ~ (f'myinputfile' > ~stdin))()

if (hostname | grep 'rain')() then
	print 'you have a fine hostname'
else
	print 'your hostname could use some improvement'
end

local null = (~stdin - f'/dev/null') - (~stdout - f'/dev/null')--create a standalon redirection chain

ping{ '-c', 1, '8.8.8.8' } - null
echo 'foo'
echo 'bar'