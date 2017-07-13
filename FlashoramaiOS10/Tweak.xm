#import "../Common.h"

%hook CAMViewfinderViewController

- (BOOL)_isFlashOrTorchSupportedForGraphConfiguration: (CAMCaptureGraphConfiguration *)configuration {
    return configuration.mode == 3 ? YES : %orig;
}

- (BOOL)_shouldRotateTopBarForGraphConfiguration:(CAMCaptureGraphConfiguration *)configuration {
    return configuration.mode == 3 ? NO : %orig;
}

- (NSInteger)_topBarBackgroundStyleForMode:(NSInteger)mode {
    return %orig(mode == 3 ? 1 : mode);
}

- (void)_startCapturingPanoramaWithRequest:(id)arg1 {
    %orig;
    if (self._flashButton.flashMode == 2) {
        autoOff = YES;
        self._flashButton.flashMode = 1;
        [self _flashButtonDidChangeFlashMode:self._flashButton];
        self._flashButton.userInteractionEnabled = NO;
    }
}

- (void)_stopCapturingPanorama {
    %orig;
    if (self._flashButton.flashMode == 1 && autoOff) {
        self._flashButton.flashMode = 0;
        [self _flashButtonDidChangeFlashMode:self._flashButton];
        self._flashButton.userInteractionEnabled = YES;
        self._flashButton.flashMode = 2;
        [self _flashButtonDidChangeFlashMode:self._flashButton];
        autoOff = NO;
    }
}

- (void)_updateFlashButtonForMode:(NSInteger)mode {
    %orig(mode == 3 ? 1 : mode);
}

- (void)_updateTorchModeOnControllerIfNecessaryForMode:(NSInteger)mode {
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

%end

%hook CAMTopBar

- (NSMutableArray *)_allowedControlsForPanoramaMode
{
    return [self _allowedControlsForVideoMode];
}

%end

%ctor
{
    openCamera10();
    %init;
}
