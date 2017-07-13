#import "../Common.h"

static void fm_torch(BOOL on, CAMCaptureController *self){
    if ([self.currentDevice hasTorch]) {
        if ([self _lockCurrentDeviceForConfiguration]) {
            self.currentDevice.torchMode = on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
            [self _unlockCurrentDeviceForConfiguration];
        }
    }
}

%hook CAMCaptureController

- (void)stopPanoramaCapture
{
    if (autoOff)
        fm_torch(NO, self);
    %orig;
}

- (void)_setFlashMode:(NSInteger)mode force:(BOOL)force {
    if (MSHookIvar<NSInteger>(self, "_cameraMode") == 3) {
        MSHookIvar<NSInteger>(self, "_cameraMode") = 1;
        %orig;
        MSHookIvar<NSInteger>(self, "_cameraMode") = 3;
    } else
        %orig;
}

%end

%hook CAMCameraView

- (NSInteger)_glyphOrientationForCameraOrientation: (NSInteger)orientation
{
    return [self cameraMode] == 3 ? 1 : %orig;
}

- (NSInteger)_currentFlashMode {
    CAMCaptureController *cont = (CAMCaptureController *)[%c(CAMCaptureController) sharedInstance];
    if (cont) {
        NSInteger origMode = MSHookIvar<NSInteger>(cont, "_cameraMode");
        if (origMode == 3) {
            MSHookIvar<NSInteger>(cont, "_cameraMode") = 1;
            NSInteger orig = %orig;
            MSHookIvar<NSInteger>(cont, "_cameraMode") = 3;
            return orig;
        }
    }
    return %orig;
}

- (NSInteger)_topBarBackgroundStyleForMode:(NSInteger)mode {
    return mode == 3 ? 3 : %orig;
}

- (void)_setFlashMode:(NSInteger)mode {
    CAMCaptureController *cont = (CAMCaptureController *)[%c(CAMCaptureController) sharedInstance];
    if (cont) {
        NSInteger origMode = MSHookIvar<NSInteger>(cont, "_cameraMode");
        if (origMode == 3) {
            MSHookIvar<NSInteger>(cont, "_cameraMode") = 1;
            %orig;
            MSHookIvar<NSInteger>(cont, "_cameraMode") = 3;
            return;
        }
    }
    %orig;
}

- (BOOL)_shouldEnableFlashButton {
    if (MSHookIvar<BOOL>(self, "__capturing") && [self cameraMode] == 3) {
        MSHookIvar<BOOL>(self, "__capturing") = NO;
        BOOL orig = %orig;
        MSHookIvar<BOOL>(self, "__capturing") = YES;
        return orig;
    }
    return %orig;
}

- (BOOL)_shouldHideFlashButtonForMode:(NSInteger)mode {
    if (mode == 3) {
        BOOL isCapturing = MSHookIvar<BOOL>(self, "__capturing");
        BOOL orig;
        if (isCapturing) {
            MSHookIvar<BOOL>(self, "__capturing") = NO;
            orig = %orig(1);
            MSHookIvar<BOOL>(self, "__capturing") = YES;
        } else
            orig = %orig(1);
        return orig;
    }
    return %orig;
}

- (BOOL)_shouldHideFlashBadgeForMode:(NSInteger)mode {
    return mode == 3 ? YES : %orig;
}

- (BOOL)_shouldHideTopBarForMode:(NSInteger)mode {
    return %orig(mode == 3 && FMisOn ? 1 : mode);
}

- (void)_capturePanorama {
    if (autoOff)
        fm_torch(YES, (CAMCaptureController *)[%c(CAMCaptureController) sharedInstance]);
    %orig;
}

%new
- (void)cameraControllerWillStopPanoramaCapture: (id)cameraController
{
    if (autoOff)
        [self _flashButton].userInteractionEnabled = YES;
}

%new
- (void)cameraControllerDidStartPanoramaCapture: (id)cameraController
{
    if (autoOff)
        [self _flashButton].userInteractionEnabled = NO;
}

%end

%hook CAMFlashButton

- (void)setFlashMode: (NSInteger)mode
{
    %orig;
    autoOff = mode == 0;
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
    %init;
}
