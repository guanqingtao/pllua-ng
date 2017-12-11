# Makefile for PL/Lua

PG_CONFIG ?= pg_config

# Lua specific

# General
LUA_INCDIR ?= /usr/local/include/lua53
LUALIB ?= -L/usr/local/lib -llua-5.3

# LuaJIT
#LUA_INCDIR = /usr/local/include/luajit-2.0
#LUALIB = -L/usr/local/lib -lluajit-5.1

# Debian/Ubuntu
#LUA_INCDIR = /usr/include/lua5.1
#LUALIB = -llua5.1

# Fink
#LUA_INCDIR = /sw/include -I/sw/include/postgresql
#LUALIB = -L/sw/lib -llua

# Lua for Windows
#LUA_INCDIR = C:/PROGRA~1/Lua/5.1/include
#LUALIB = -LC:/PROGRA~1/Lua/5.1/lib -llua5.1

# no need to edit below here
MODULE_big = pllua_ng
EXTENSION = pllua_ng
DATA = pllua_ng--1.0.sql

REGRESS = pllua pllua_old arrays numerics types

OBJS =	compile.o datum.o elog.o error.o exec.o globals.o init.o \
	numeric.o objects.o pllua.o spi.o trigger.o trusted.o

EXTRA_CLEAN = pllua_functable.h

PG_CPPFLAGS = -I$(LUA_INCDIR) #-DPLLUA_DEBUG
SHLIB_LINK = $(LUALIB)

PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

$(OBJS): pllua.h

init.o: pllua_functable.h

pllua_functable.h: $(OBJS:.o=.c)
	cat $(OBJS:.o=.c) | perl -lne '/(pllua_pushcfunction|pllua_cpcall|pllua_initial_protected_call)\(\s*(\w+)\s*,\s*(pllua_\w+)\s*/ and print "PLLUA_DECL_CFUNC($$3)"' | sort -u >pllua_functable.h
