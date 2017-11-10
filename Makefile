# Argon2 password hashing algorithm for use with Elixir
# Makefile
#
# Copyright 2016-2017 David Whitlock
#
# This is licensed under the Apache Public License 2.0
#
# The license and copyright information for the reference implementation
# is detailed below:
#
# Argon2 reference source code package - reference C implementations
#
# Copyright 2015
# Daniel Dinu, Dmitry Khovratovich, Jean-Philippe Aumasson, and Samuel Neves
#
# You may use this work under the terms of a Creative Commons CC0 1.0
# License/Waiver or the Apache Public License 2.0, at your option. The terms of
# these licenses can be found at:
#
# - CC0 1.0 Universal : http://creativecommons.org/publicdomain/zero/1.0
# - Apache 2.0        : http://www.apache.org/licenses/LICENSE-2.0
#
# You should have received a copy of both of these licenses along with this
# software. If not, they may be obtained at the above URLs.
#

SRC_INC = argon2/include
SRC_DIR = argon2/src

SRC = $(SRC_DIR)/argon2.c $(SRC_DIR)/core.c $(SRC_DIR)/blake2/blake2b.c\
      $(SRC_DIR)/thread.c $(SRC_DIR)/encoding.c $(SRC_DIR)/ref.c\
      c_src/argon2_nif.c

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -pthread -O3 -Wall -g -I$(SRC_INC) -I$(SRC_DIR) -Ic_src -I$(ERLANG_PATH)
#CFLAGS += -std=c89 -pedantic -pthread -O3 -Wall -g -I$(SRC_INC) -I$(SRC_DIR) -Ic_src -I$(ERLANG_PATH)

KERNEL_NAME := $(shell uname -s)

LIB_NAME = priv/argon2_nif.so
ifneq ($(CROSSCOMPILE),)
	LIB_CFLAGS := -shared -fPIC -fvisibility=hidden
	SO_LDFLAGS := -Wl,-soname,libargon2.so.0
else
	ifeq ($(KERNEL_NAME), Linux)
		LIB_CFLAGS := -shared -fPIC -fvisibility=hidden
		SO_LDFLAGS := -Wl,-soname,libargon2.so.0
	endif
	ifeq ($(KERNEL_NAME), Darwin)
		LIB_CFLAGS := -dynamiclib -undefined dynamic_lookup
	endif
	ifeq ($(KERNEL_NAME), $(filter $(KERNEL_NAME),OpenBSD FreeBSD NetBSD))
		LIB_CFLAGS := -shared -fPIC
	endif
endif

all: $(LIB_NAME)

$(LIB_NAME): $(SRC)
	mkdir -p priv
	$(CC) $(CFLAGS) $(LIB_CFLAGS) $(SO_LDFLAGS) $^ -o $@

clean:
	rm -f $(LIB_NAME)

.PHONY: all clean
