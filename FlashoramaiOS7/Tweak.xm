#import "../Common.h"

static void fm_torch(BOOL on, PLCameraController *self){
    if ([self.currentDevice hasTorch]) {
        if ([self _lockCurrentDeviceForConfiguration]) {
            self.currentDevice.torchMode = on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
            [self _unlockCurrentDeviceForConfiguration];
        }
    }
}

%hook PLCameraController

- (void)stopPanoramaCapture
{
    if (autoOff)
        fm_torch(NO, self);
    %orig;
}

- (void)startPanoramaCapture {
    if (autoOff)
        fm_torch(YES, self);
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

%hook PLCameraView

- (NSInteger)_glyphOrientationForCameraOrientation: (NSInteger)orientation
{
    return self.cameraMode == 3 ? 1 : %orig;
}

- (BOOL)_flashButtonShouldBeHidden {
    return self.cameraMode == 3 ? NO : %orig;
}

- (void)cameraControllerWillStopPanoramaCapture:(id)cameraController {
    %orig;
    if (autoOff)
        self._flashButton.userInteractionEnabled = YES;
}

- (void)cameraControllerDidStartPanoramaCapture:(id)cameraController {
    %orig;
    if (autoOff)
        self._flashButton.userInteractionEnabled = NO;
}

- (NSInteger)_currentFlashMode {
    PLCameraController *cont = (PLCameraController *)[%c(PLCameraController) sharedInstance];
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

- (BOOL)_shouldEnableFlashButton {
    if (MSHookIvar<BOOL>(self, "__capturing") && self.cameraMode == 3) {
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
    return %orig(mode == 3 ? 1 : mode);
}

- (void)flashButtonModeDidChange:(CAMFlashButton *)change {
    PLCameraController *cont = (PLCameraController *)[%c(PLCameraController) sharedInstance];
    if (cont) {
        if (MSHookIvar<NSInteger>(cont, "_cameraMode") != 3) {
            %orig;
            return;
        }
        MSHookIvar<NSInteger>(cont, "_cameraMode") = 1;
        %orig;
        MSHookIvar<NSInteger>(cont, "_cameraMode") = 3;
    } else
        %orig;
}

%end

%hook CAMFlashButton

- (void)setFlashMode: (NSInteger)mode notifyDelegate: (BOOL)arg2
{
    %orig;
    autoOff = (mode == 0);
}

%end

%ctor
{
    %init;
}
