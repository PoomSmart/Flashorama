TARGET = iphone:clang:latest:10.0
PACKAGE_VERSION = 1.7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Flashorama
$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/tweak.mk
