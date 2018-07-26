PACKAGE_VERSION = 1.6.2

include $(THEOS)/makefiles/common.mk

AGGREGATE_NAME = FlashoramaTweak
SUBPROJECTS = FlashoramaiOS6 FlashoramaiOS7 FlashoramaiOS8 FlashoramaiOS9 FlashoramaiOSAB FlashoramaLoader

include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp -R Flashorama $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
