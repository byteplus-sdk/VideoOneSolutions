// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ChorusMusicLyricWordModel : NSObject

@property (nonatomic, assign) NSInteger offset;

@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, copy) NSString *word;

@end

@interface ChorusMusicLyricLineModel : NSObject

@property (nonatomic, assign) NSInteger beginTime;

@property (nonatomic, assign) NSInteger duration;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, strong) NSArray<ChorusMusicLyricWordModel *> *words;

- (CGFloat)calculateContentWidth:(UIFont *)font 
                         content:(NSString *)content;

- (CGFloat)calculateContentHeight:(UIFont *)font
                          content:(NSString *)content
                         maxWidth:(CGFloat)maxWidth;

- (CGFloat)calculateCurrentLrcProgress:(NSInteger)currentTime;

@end

@interface ChorusMusicLyricModel : NSObject

@property (nonatomic, strong) NSArray<ChorusMusicLyricLineModel *> *lines;

@end

NS_ASSUME_NONNULL_END
