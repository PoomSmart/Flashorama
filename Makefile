TARGET = iphone:clang:latest:10.0
PACKAGE_VERSION = 1.7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Flashorama
$(TWEAK_NAME)_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R $(TWEAK_NAME) $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store -delete$(ECHO_END)
