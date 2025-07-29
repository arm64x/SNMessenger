INSTALL_TARGET_PROCESSES = Messenger
PACKAGE_VERSION = 2.0.0
ARCHS = arm64 arm64e

TWEAK_NAME = SNMessenger
$(TWEAK_NAME)_FILES = $(wildcard SNMessenger.xm Settings/*.mm)
$(TWEAK_NAME)_CCFLAGS = -std=c++17
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

ifeq ($(SIDELOAD), 1)
    $(TWEAK_NAME)_FILES += fishhook/fishhook.c SideloadedFixes.xm
    $(TWEAK_NAME)_CFLAGS += -DSIDELOAD=1
endif

ifeq ($(ROOTLESS), 1)
    THEOS_PACKAGE_SCHEME = rootless
    TARGET = iphone:clang:latest:15.0
else
    TARGET = iphone:clang:latest:12.4
endif

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
