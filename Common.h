#define UNRESTRICTED_AVAILABILITY
#import "../PS.h"

static BOOL FMisOn;
static BOOL autoOff;
static BOOL isPanorama;

NSString *const PREF_PATH = @"/var/mobile/Library/Preferences/com.PS.Flashorama.plist";
CFStringRef const PreferencesNotification = CFSTR("com.PS.Flashorama.settingschanged");
NSString *const key = @"FMEnabled";
