#import "../Common.h"

static void fm_torch(BOOL on, PLCameraController *self) {
    if ([self.currentDevice hasTorch]) {
        if ([self _lockCurrentDeviceForConfiguration]) {
            self.currentDevice.torchMode = on ? AVCaptureTorchModeOn : AVCaptureTorchModeOff;
            [self _unlockCurrentDeviceForConfiguration];
        }
    }
}

%hook PLCameraController

- (void)stopPanoramaCapture {
    if (autoOff)
        fm_torch(NO, self);
    %orig;
}

- (void)startPanoramaCapture {
    if (autoOff)
        fm_torch(YES, self);
    %orig;
}

%end

%hook PLCameraView

- (NSInteger)_glyphOrientationForCameraOrientation:(NSInteger)orientation {
    return self.cameraMode == 2 ? 1 : %orig;
}

- (BOOL)_flashButtonShouldBeHidden {
    return self.cameraMode == 2 ? NO : %orig;
}

- (void)cameraControllerWillStopPanoramaCapture:(id)cameraController {
    %orig;
    if (autoOff)
        MSHookIvar<PLCameraFlashButton *>(self, "_flashButton").userInteractionEnabled = YES;
}

- (void)cameraControllerDidStartPanoramaCapture:(id)cameraController {
    %orig;
    if (autoOff)
        MSHookIvar<PLCameraFlashButton *>(self, "_flashButton").userInteractionEnabled = NO;
}

%end

%hook PLCameraFlashButton

- (void)setFlashMode: (NSInteger)mode notifyDelegate:(BOOL)delegate {
    %orig;
    if (((PLCameraView *)(self.delegate)).cameraMode == 2) {
        autoOff = (mode == 0);
        fm_torch(mode == 1, (PLCameraController *)[%c(PLCameraController) sharedInstance]);
    }
}

%end

%ctor {
    %init;
}
