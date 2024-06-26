// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPreviewSizeManager.h"
#import <ToolKit/ToolKit.h>
#define CHECK_AVAILABLE(RET)\
if (!_available) {\
    VOLogE(VOMediaLive,@"invalid state, %f, %f, %f, %f", _viewWidth, _viewHeight, _previewWidth, _previewHeight);\
    return RET;\
}

@interface VELPreviewSizeManager () {
    float               _viewWidth;
    float               _viewHeight;
    float               _previewWidth;
    float               _previewHeight;
    BOOL                _fitCenter;
    
    BOOL                _available;
    float               _widthRatio;
    float               _heightRatio;
}

@end

@implementation VELPreviewSizeManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static VELPreviewSizeManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[VELPreviewSizeManager alloc] init];
    });
    return manager;
}

- (void)updateViewWidth:(float)viewWidth viewHeight:(float)viewHeight previewWidth:(float)previewWidth previewHeight:(float)previewHeight fitCenter:(BOOL)fitCenter {
    _viewWidth = viewWidth;
    _viewHeight = viewHeight;
    _previewWidth = previewWidth;
    _previewHeight = previewHeight;
    _fitCenter = fitCenter;
    
    _widthRatio = viewWidth / previewWidth;
    _heightRatio = viewHeight / previewHeight;
    _available = viewWidth > 0 && viewHeight > 0 && previewWidth > 0 && previewHeight > 0;
}

- (float)ratio {
    return _fitCenter ? MIN(_widthRatio, _heightRatio) : MAX(_widthRatio, _heightRatio);
}

- (float)previewToViewX:(float)x {
    CHECK_AVAILABLE(0.f)
    float ratio = self.ratio;
    float offset = _previewWidth * (_widthRatio - ratio) / 2;
    return offset + x * ratio;
}

- (float)previewToViewY:(float)y {
    CHECK_AVAILABLE(0.f)
    float ratio = self.ratio;
    float offset = _previewHeight * (_heightRatio - ratio) / 2;
    return offset + y * ratio;
}

- (float)viewToPreviewX:(float)x {
    CHECK_AVAILABLE(0.f)
    float ratio = self.ratio;
    float offset = _previewWidth * (_widthRatio - ratio) / 2;
    return (x - offset) / ratio;
}

- (float)viewToPreviewY:(float)y {
    CHECK_AVAILABLE(0.f)
    float ratio = self.ratio;
    float offset = _previewHeight * (_heightRatio - ratio) / 2;
    return (y - offset) / ratio;
}

- (float)viewToPreviewXFactor:(float)x {
    CHECK_AVAILABLE(0.f)
    return [self viewToPreviewX:x] / _previewWidth;
}

- (float)viewToPreviewYFactor:(float)y {
    CHECK_AVAILABLE(0.f)
    return [self viewToPreviewY:y] / _previewHeight;
}

- (float)viewXFactor:(float)x {
    CHECK_AVAILABLE(0.f)
    float ratio = self.ratio;
    return x / ratio / _previewWidth;
}

- (float)viewYFactor:(float)y {
    CHECK_AVAILABLE(0.f)
    float ratio = self.ratio;
    return y / ratio / _previewHeight;
}
@end
