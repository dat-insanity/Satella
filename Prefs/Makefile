ARCHS = arm64 arm64e

BUNDLE_NAME = SatellaPrefs
$(BUNDLE_NAME)_FILES = \
	Sources/Bridge/SatellaPrefsRootless.m \
	$(shell find Sources/SatellaPrefs -name '*.swift')
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc
$(BUNDLE_NAME)_SWIFTFLAGS = -swift-version 5 -import-objc-header Sources/Bridge/SatellaPrefs-Bridging-Header.h
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	@$(PRINT_FORMAT_MAKING) "Installing the PreferenceLoader entry"
	$(ECHO_NOTHING)mkdir -p "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences"$(ECHO_END)
	$(ECHO_NOTHING)cp Resources/entry.plist "$(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/$(BUNDLE_NAME).plist"$(ECHO_END)
