.PHONY: all install

all: install

install:
	NVIM_APPNAME=$(NVIM_APPNAME) nvim --headless --noplugin -u NONE -c 'luafile build.lua' +qa
