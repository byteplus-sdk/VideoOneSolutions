// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface VELPreviewSizeManager : NSObject

+ (instancetype)shareInstance;
- (void)updateViewWidth:(float)viewWidth viewHeight:(float)viewHeight previewWidth:(float)previewWidth previewHeight:(float)previewHeight fitCenter:(BOOL)fitCenter;
- (float)ratio;
- (float)previewToViewX:(float)x;
- (float)previewToViewY:(float)y;
- (float)viewToPreviewX:(float)x;
- (float)viewToPreviewY:(float)y;
- (float)viewToPreviewXFactor:(float)x;
- (float)viewToPreviewYFactor:(float)y;
- (float)viewXFactor:(float)x;
- (float)viewYFactor:(float)y;
@end

NS_ASSUME_NONNULL_END
