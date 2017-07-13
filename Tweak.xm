#import "Common.h"
#import <dlfcn.h>

static void FMLoader(){
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:PREF_PATH];
    id FMEnabled = dict[key];
    FMisOn = FMEnabled ? [FMEnabled boolValue] : YES;
}

static void PostNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo){
    FMLoader();
}

%ctor
{
    if (IN_SPRINGBOARD && isiOS7Up)
        return;
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, PostNotification, PreferencesNotification, NULL, CFNotificationSuspensionBehaviorCoalesce);
    FMLoader();
    if (FMisOn) {
        if (isiOS10Up)
            dlopen("/Library/Application Support/Flashorama/FlashoramaiOS10.dylib", RTLD_LAZY);
        if (isiOS9)
            dlopen("/Library/Application Support/Flashorama/FlashoramaiOS9.dylib", RTLD_LAZY);
        else if (isiOS8)
            dlopen("/Library/Application Support/Flashorama/FlashoramaiOS8.dylib", RTLD_LAZY);
        else if (isiOS7)
            dlopen("/Library/Application Support/Flashorama/FlashoramaiOS7.dylib", RTLD_LAZY);
        else
            dlopen("/Library/Application Support/Flashorama/FlashoramaiOS6.dylib", RTLD_LAZY);
    }
}
