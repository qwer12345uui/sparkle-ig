TARGET := iphone:clang:16.2:15.0
INSTALL_TARGET_PROCESSES = Instagram
ARCHS = arm64

ifneq ($(DEV),1)
DEBUG = 0
FINALPACKAGE = 1
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Sparkle

$(TWEAK_NAME)_FILES = $(shell find src -type f \( -iname \*.x -o -iname \*.xm -o -iname \*.m -o -iname \*.swift \)) modules/SPKSideloadFix/fishhook/fishhook.c
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation CoreGraphics Photos CoreServices SystemConfiguration SafariServices Security QuartzCore AVFoundation AVKit CoreData LocalAuthentication ImageIO UniformTypeIdentifiers Accelerate VisionKit UserNotifications
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(TWEAK_NAME)_LIBRARIES = sqlite3
$(TWEAK_NAME)_CFLAGS = -fobjc-arc -Wno-unsupported-availability-guard -Wno-unused-value -Wno-deprecated-declarations -Wno-nullability-completeness -Wno-unused-function -Wno-incompatible-pointer-types
$(TWEAK_NAME)_LOGOSFLAGS = --c warnings=none

STARTUP_PROFILING ?= 0
$(TWEAK_NAME)_CFLAGS += -DSTARTUP_PROFILING=$(STARTUP_PROFILING)

ifneq ($(DEV),1)
$(TWEAK_NAME)_CFLAGS += -O2 -DNDEBUG
$(TWEAK_NAME)_LDFLAGS += -Wl,-S
else
$(TWEAK_NAME)_CFLAGS += -DSPK_DEV=1
endif

$(TWEAK_NAME)_CXXFLAGS += -std=c++11

# Resource bundle (staged automatically by Theos for rootless packages).
# FFmpeg frameworks are intentionally NOT bundled in this no-FFmpeg build.
$(TWEAK_NAME)_BUNDLE_NAME = Sparkle
$(TWEAK_NAME)_BUNDLE_INSTALL_PATH = /Library/Application Support
$(TWEAK_NAME)_BUNDLE_RESOURCE_DIRS = resources/Sparkle.bundle

include $(THEOS_MAKE_PATH)/tweak.mk
