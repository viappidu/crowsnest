#### webcamd - A webcam Service for multiple Cams and Stream Services.
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
.PHONY: all clean ustreamer rtsp webrtc update

# Paths
USTREAMER_PATH = ustreamer
ARCH = $(shell uname -m | cut -c '-5' | sed 's/x86_6/amd64/')
WEBRTC_PATH = webrtc-streamer
WEBRTC_VERSION = $(shell cat $(WEBRTC_PATH)/version)
DL_WEBRTC = https://github.com/mpromonet/webrtc-streamer/releases/download/$(WEBRTC_VERSION)/
WEBRTC_ARCHIVE = webrtc-streamer-$(WEBRTC_VERSION)-Linux-$(ARCH)l-Release.tar.gz
RTSP_PATH = rtsp-simple-server
RTSP_VERSION = $(shell cat $(RTSP_PATH)/version)
DL_RTSP = https://github.com/aler9/rtsp-simple-server/releases/download/$(RTSP_VERSION)/
RTSP_ARCHIVE = rtsp-simple-server_$(RTSP_VERSION)_linux_$(ARCH).tar.gz

# Custom Flags
MAKEFLAGS += -j$(shell nproc)

# OpenMAX IL Support
OMX_SUPPORT = $(shell [ -d /opt/vc/include ] && echo 1 || echo 0)

all:
	$(MAKE) ustreamer
	$(MAKE) rtsp
	$(MAKE) webrtc

# Build ustreamer
ustreamer:
ifeq ($(OMX_SUPPORT), 1)
	$(info Compiling ustreamer with OMX Support.)
	WITH_OMX=1 $(MAKE) -C $(USTREAMER_PATH)
else
	$(info Compiling ustreamer without OMX Support.)
	$(MAKE) -C $(USTREAMER_PATH)
endif

# Download rtsp-simple-server
rtsp:
	$(info Download $(RTSP_ARCHIVE) from $(DL_RTSP))
	$(shell curl -JLo $(RTSP_PATH)/$(RTSP_ARCHIVE) $(DL_RTSP)$(RTSP_ARCHIVE))
	$(shell tar -C $(RTSP_PATH) -xf $(RTSP_PATH)/$(RTSP_ARCHIVE))
	$(shell rm -f $(RTSP_PATH)/$(RTSP_ARCHIVE))
	$(info Finished.)
# Dirty Hack needed to prevent "make: Nothing to be done for 'rtsp'." message
	@echo > /dev/null

webrtc:
	$(info Download $(WEBRTC_ARCHIVE) from $(DL_WEBRTC))
	$(shell curl -JLo $(WEBRTC_PATH)/$(WEBRTC_ARCHIVE) $(DL_WEBRTC)$(WEBRTC_ARCHIVE))
	$(shell tar -C $(WEBRTC_PATH) -xf $(WEBRTC_PATH)/$(WEBRTC_ARCHIVE))
	$(shell rm -f $(WEBRTC_PATH)/$(WEBRTC_ARCHIVE))
	$(shell cp -r $(WEBRTC_PATH)/webrtc-streamer-$(WEBRTC_VERSION)-Linux-$(ARCH)l-Release/* $(WEBRTC_PATH))
	$(shell rm -rf $(WEBRTC_PATH)/webrtc-streamer-$(WEBRTC_VERSION)-Linux-$(ARCH)l-Release)
	$(info Finished.)
# Dirty Hack needed to prevent "make: Nothing to be done for 'rtsp'." message
	@echo > /dev/null

clean:
	$(MAKE) -C $(USTREAMER_PATH) clean
	$(info Clean rtsp-simple-server)
	$(shell rm -rf $(RTSP_PATH)/rtsp*)
	$(info Clean RTSPtoWebRTC)
	$(shell cd $(WEBRTC_PATH) && go clean -r)
	$(shell rm -f $(WEBRTC_PATH)/rtsp2webrtc)

update:
	$(MAKE) clean
	$(MAKE) all
