.PHONY: api_documentation llscheck luacheck stylua test

llscheck:
	VIMRUNTIME=`nvim -l scripts/print_vimruntime_environment_variable.lua` llscheck --configpath .luarc.json .

luacheck:
	luacheck lua plugin scripts spec

stylua:
	stylua lua plugin scripts spec

test:
	busted --helper spec/minimal_init.lua .
