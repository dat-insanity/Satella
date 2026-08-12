# Dopamine/ElleKit rootless build for iOS 15.0 through 17.3.1.
export TARGET = iphone:clang:16.5:15.0
export THEOS_PACKAGE_SCHEME = rootless
export FINALPACKAGE = 1
export DEBUG = 0
export THEOS_LEAN_AND_MEAN = 1

SUBPROJECTS += Prefs Tweak

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
