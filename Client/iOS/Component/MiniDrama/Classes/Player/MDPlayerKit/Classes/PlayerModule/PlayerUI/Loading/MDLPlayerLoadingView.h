// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

@protocol MDPlayerLoadingViewDataSource <NSObject>
- (NSString *)netWorkSpeedInfo;
@end


@protocol MDPlayerLoadingViewProtocol <NSObject>

- (void)startLoading;
- (void)stopLoading;

@optional
@property (nonatomic) BOOL isLoading;
@property (nonatomic , assign) BOOL isFullScreen;
@property (nonatomic, assign) BOOL showNetSpeedTip;
@property (nonatomic, assign) NSTimeInterval refreshNetSpeedTipTimeInternal;
@property (nonatomic, weak) id<MDPlayerLoadingViewDataSource> dataSource;
/// @param text text
- (void)setLoadingText:(NSString *)text;

- (void)layoutOffsetCenterY:(CGFloat)y;

@end

@interface MDLPlayerLoadingView : UIView<MDPlayerLoadingViewProtocol>

@property (nonatomic) BOOL isLoading;

/// show net speed tip
@property (nonatomic, assign) BOOL showNetSpeedTip;

@end



