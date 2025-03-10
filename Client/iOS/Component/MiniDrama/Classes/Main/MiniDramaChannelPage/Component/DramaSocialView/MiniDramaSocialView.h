// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MiniDramaBaseVideoModel.h"
#import "MDInterfaceElementDescription.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaSocialView : UIStackView <MDInterfaceCustomView>

@property (nonatomic, strong) MiniDramaBaseVideoModel *videoModel;

- (void)handleDoubleClick:(CGPoint)location;

- (void)handleDoubleClick:(CGPoint)location inView:(__kindof UIView *)view;

@end

NS_ASSUME_NONNULL_END
