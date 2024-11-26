// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MGPGLabel.h"
#import "TTVideoEngine.h"
#import <UIKit/UIKit.h>

@class SubtitleidType, TTVideoEngine;

NS_ASSUME_NONNULL_BEGIN

@interface SmartSubtitleManager : NSObject

@property (nonatomic, strong) NSArray<SubtitleidType *> *subtitleList;

@property (nonatomic, assign, readonly) NSInteger currentSubtitleId;

@property (nonatomic, nullable, readonly) NSString *currentLanguangeName;

@property (nonatomic, strong) MGPGLabel *subTitleLabel;

@property (nonatomic, strong) TTVideoEngine *videoEngine;

@property (nonatomic, copy) void (^openSubtitleBlock)(BOOL result, NSString *_Nullable defaulLanguage);

- (void)openSubtitle:(NSString *)subtitleAuthToken;

- (void)switchSubtitle:(NSInteger)subtitleId withBlock:(void (^_Nullable)(BOOL result))block;

+ (NSString *)getLanguangeNameWithId:(NSInteger)languangeId;

@end

NS_ASSUME_NONNULL_END
