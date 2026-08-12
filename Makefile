# Satella 2 is a rootless-only tweak for Dopamine/ElleKit.

export TARGET = iphone:clang:latest:15.0
export THEOS_PACKAGE_SCHEME = rootless
export FINALPACKAGE = 1
export DEBUG = 0
export THEOS_LEAN_AND_MEAN = 1

SUBPROJECTS += Prefs Tweak

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
