#### crowsnest - A webcam Service for multiple Cams and Stream Services.
####
#### Written by Stephan Wendel aka KwadFan <me@stephanwe.de>
#### Copyright 2021
#### https://github.com/mainsail-crew/crowsnest
####
#### This File is distributed under GPLv3
####
#### This Makefile is intended to streamline the build of depending binaries.

#### DO NOT MODIFY AT ALL! ####

# Setup
.PHONY: all clean ustreamer-bin cstreamer-bin update

# Paths
USTREAMER_PATH = ustreamer
USTREAMER_REPO = https://github.com/pikvm/ustreamer.git
CSTREAMER_PATH = camera-streamer
CSTREAMER_REPO = https://github.com/ayufan-research/camera-streamer.git
ARCH = $(shell uname -m)

# Custom Flags
MAKEFLAGS += -j$(shell nproc)

# Ustreamer cloned?
USTREAMER_EXIST = $(shell [ -d ustreamer ] > /dev/null && echo 1 || echo 0)

# Camera-Streamer cloned?
CSTREAMER_EXIST = $(shell [ -d camera-streamer ] > /dev/null && echo 1 || echo 0)

all:
	$(MAKE) cstreamer-bin
	$(MAKE) ustreamer-bin

# Build ustreamer
ustreamer-bin:
ifeq ($(USTREAMER_EXIST), 0)
	$(info INFO: ustreamer not found, cloning repository.)
	$(shell git clone $(USTREAMER_REPO) $(USTREAMER_PATH))
else
	$(info INFO: ustreamer found.)
endif
	$(info INFO: Compiling ustreamer)
	$(MAKE) -C $(USTREAMER_PATH)

cstreamer-bin:
ifeq ($(CSTREAMER_EXIST), 0)
	$(info INFO: camera-streamer not found, cloning repository.)
	@git clone $(CSTREAMER_REPO) --recursive
else
	$(info INFO: camera-streamer found.)
endif
	$(info INFO: Compiling camera-streamer)
	$(MAKE) -C $(CSTREAMER_PATH)

clean:
	$(MAKE) -C $(CSTREAMER_PATH) clean
	$(MAKE) -C $(USTREAMER_PATH) clean

update:
	$(MAKE) clean
	$(MAKE) all
