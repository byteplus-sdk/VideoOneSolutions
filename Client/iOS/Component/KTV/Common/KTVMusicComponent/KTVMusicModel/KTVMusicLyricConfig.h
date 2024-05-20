// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KTVMusicLrcFormat) {
    KTVMusicLrcFormatKRC,
    KTVMusicLrcFormatLRC,
};

@interface KTVMusicLyricConfig : NSObject

@property (nonatomic, strong) UIColor *playingColor;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIFont *playingFont;
@property (nonatomic, assign) KTVMusicLrcFormat lrcFormat;

@end

NS_ASSUME_NONNULL_END
