#define UNRESTRICTED_AVAILABILITY
#import "../PSHeader/Availability.h"
#import "../PSHeader/CameraMacros.h"
#import "../PSHeader/CameraApp/CameraApp.h"

BOOL autoOff;

static void flashDidChange(CAMViewfinderViewController *self, NSInteger mode) {
    if ([self respondsToSelector:@selector(_handleUserChangedToFlashMode:)])
        [self _handleUserChangedToFlashMode:mode];
    else
        [self _flashButtonDidChangeFlashMode:self._flashButton];
}

%hook CAMCaptureCapabilities

- (BOOL)isTorchSupportedForMode:(NSInteger)mode devicePosition:(NSInteger)devicePosition {
    return %orig(mode == 3 ? 1 : mode, devicePosition);
}

%end

%hook CAMViewfinderViewController

- (BOOL)_isFlashOrTorchSupportedForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration {
    return configuration.mode == 3 ? YES : %orig;
}

- (BOOL)_shouldRotateTopBarForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration {
    return configuration.mode == 3 ? NO : %orig;
}

- (BOOL)_shouldHideTopBarForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration {
    return configuration.mode == 3 ? NO : %orig;
}

- (BOOL)_shouldShowIndicatorOfType:(NSUInteger)type forGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration {
    return type == 0 && configuration.mode == 3 && [self._captureController isCapturingVideo] && [self._captureController isCapturingPanorama] ? YES : %orig;
}

- (NSInteger)_topBarBackgroundStyleForMode:(NSInteger)mode {
    return %orig(mode == 3 ? 1 : mode);
}

- (void)_startCapturingPanoramaWithRequest:(id)arg1 {
    %orig;
    if (self._flashButton.flashMode == 2) {
        autoOff = YES;
        self._flashButton.flashMode = 1;
        flashDidChange(self, 1);
        self._flashButton.userInteractionEnabled = NO;
    } else
        self._flashButton.allowsAutomaticFlash = NO;
}

- (void)_stopCapturingPanorama {
    %orig;
    if (self._flashButton.flashMode == 1 && autoOff) {
        self._flashButton.flashMode = 0;
        flashDidChange(self, 0);
        self._flashButton.userInteractionEnabled = YES;
        self._flashButton.flashMode = 2;
        flashDidChange(self, 2);
        autoOff = NO;
    }
    self._flashButton.allowsAutomaticFlash = YES;
}

- (void)_updateFlashButtonForMode:(NSInteger)mode {
    %orig(mode == 3 ? 1 : mode);
}

- (void)_updateFlashButtonForMode:(NSInteger)mode animated:(BOOL)animated {
    %orig(mode == 3 ? 1 : mode, animated);
}

- (void)_updateTorchModeOnControllerIfNecessaryForMode:(NSInteger)mode {
    %orig(mode == 3 ? 1 : mode);
}

- (void)_updateTorchModeOnControllerForMode:(NSInteger)mode {
    %orig(mode == 3 ? 1 : mode);
}

- (void)captureController:(id)arg1 didOutputFlashAvailability:(BOOL)arg2 {
    if (self._currentMode == 3) {
        MSHookIvar<NSInteger>(self._currentGraphConfiguration, "_mode") = 1;
        %orig;
        MSHookIvar<NSInteger>(self._currentGraphConfiguration, "_mode") = 3;
    } else
        %orig;
}

- (void)captureController:(id)arg1 didOutputTorchAvailability:(BOOL)arg2 {
    if (self._currentMode == 3) {
        MSHookIvar<NSInteger>(self._currentGraphConfiguration, "_mode") = 1;
        %orig;
        MSHookIvar<NSInteger>(self._currentGraphConfiguration, "_mode") = 3;
    } else
        %orig;
}

- (void)_flashButtonDidChangeFlashMode:(id)arg {
    if (self._currentMode == 3) {
        MSHookIvar<NSInteger>(self._currentGraphConfiguration, "_mode") = 1;
        %orig;
        MSHookIvar<NSInteger>(self._currentGraphConfiguration, "_mode") = 3;
    } else
        %orig;
}

- (void)_handleUserChangedToFlashMode:(NSInteger)mode {
    if (mode == 3) {
        MSHookIvar<NSInteger>(self._currentGraphConfiguration, "_mode") = 1;
        %orig;
        MSHookIvar<NSInteger>(self._currentGraphConfiguration, "_mode") = 3;
    } else
        %orig;
}

- (NSInteger)_displayedFlashModeForMode:(NSInteger)mode flashActive:(BOOL *)flashActive {
    return %orig(mode == 3 ? 1 : mode, flashActive);
}

%end

%hook CAMTopBar

- (NSMutableArray *)_allowedControlsForPanoramaMode {
    return [self _allowedControlsForVideoMode];
}

%end
