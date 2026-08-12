ARCHS = arm64

TWEAK_NAME = Satella
$(TWEAK_NAME)_FILES = \
	Sources/load.s \
	Sources/Bridge/SatellaHookBridge.m \
	Sources/Satella/Tweak.swift \
	Sources/Satella/Helpers/Delegate.swift \
	Sources/Satella/Helpers/Observer.swift \
	Sources/Satella/Helpers/Preferences.swift \
	$(shell find Sources/Satella/Receipt -name '*.swift')
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_SWIFTFLAGS = -swift-version 5 -import-objc-header Sources/Bridge/Satella-Bridging-Header.h
$(TWEAK_NAME)_FRAMEWORKS = Foundation StoreKit
$(TWEAK_NAME)_LIBRARIES = substrate

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk
