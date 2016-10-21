# Add license info
#
#
#

SRC_INC = argon2/include
SRC_DIR = argon2/src
GENKAT = genkat

SRC = $(SRC_DIR)/argon2.c $(SRC_DIR)/core.c $(SRC_DIR)/blake2/blake2b.c \
      $(SRC_DIR)/thread.c $(SRC_DIR)/encoding.c c_src/argon2_nif.c
SRC_GENKAT = $(SRC_DIR)/genkat.c

ERLANG_PATH = $(shell erl -eval 'io:format("~s", [lists:concat([code:root_dir(), "/erts-", erlang:system_info(version), "/include"])])' -s init stop -noshell)
CFLAGS += -std=c89 -pthread -O3 -Wall -g -I$(SRC_INC) -I$(SRC_DIR) -Ic_src -I$(ERLANG_PATH)

OPTTARGET ?= native
OPTTEST := $(shell $(CC) -I$(SRC_INC) -I$(SRC_DIR) -march=$(OPTTARGET) $(SRC_DIR)/opt.c -c \
	-o /dev/null 2>/dev/null; echo $$?)
# Detect compatible platform
ifneq ($(OPTTEST), 0)
	#$(info Building without optimizations)
	SRC += $(SRC_DIR)/ref.c
else
	#$(info Building with optimizations for $(OPTTARGET))
	CFLAGS += -march=$(OPTTARGET)
	SRC += $(SRC_DIR)/opt.c
endif

BUILD_PATH := $(shell pwd)
KERNEL_NAME := $(shell uname -s)

LIB_NAME = priv/argon2_nif
ifneq ($(CROSSCOMPILE),)
	LIB_EXT := so
	#LIB_CFLAGS := -shared -fPIC
	LIB_CFLAGS := -shared -fPIC -fvisibility=hidden -DA2_VISCTL=1
	SO_LDFLAGS := -Wl,-soname,libargon2.so.0
else
	ifeq ($(KERNEL_NAME), Linux)
	LIB_EXT := so
	#LIB_CFLAGS := -shared -fPIC
	LIB_CFLAGS := -shared -fPIC -fvisibility=hidden -DA2_VISCTL=1
	SO_LDFLAGS := -Wl,-soname,libargon2.so.0
	endif
	ifeq ($(KERNEL_NAME), Darwin)
		LIB_EXT := dylib
		LIB_CFLAGS := -dynamiclib -install_name @rpath/lib$(LIB_NAME).$(LIB_EXT)
		#LDFLAGS += -dynamiclib -undefined dynamic_lookup
	endif
	ifeq ($(KERNEL_NAME), $(filter $(KERNEL_NAME),OpenBSD FreeBSD NetBSD))
		LIB_EXT := so
		LIB_CFLAGS := -shared -fPIC
	endif
endif

LIB_SH := $(LIB_NAME).$(LIB_EXT)

all: $(LIB_SH)

$(LIB_SH): $(SRC)
	mkdir -p priv
	$(CC) $(CFLAGS) $(LIB_CFLAGS) $(LDFLAGS) $(SO_LDFLAGS) $^ -o $@

$(GENKAT): $(SRC) $(SRC_GENKAT)
	$(CC) $(CFLAGS) $^ -o $@ -DGENKAT

test: $(SRC) $(SRC_DIR)/test.c
	mkdir -p priv
	$(CC) $(CFLAGS)  -Wextra -Wno-type-limits $^ -o priv/testcase
	@sh argon2/kats/test.sh
	priv/testcase

clean:
	rm -f $(LIB_SH) kat-argon2*
	rm -f priv/testcase
	cd $(SRC_DIR) && rm -f *.o
	cd $(SRC_DIR)/blake2/ && rm -f *.o
	cd $(SRC_DIR)/kats/ &&  rm -f kat-* diff* run_* make_*

.PHONY: all test clean
