// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChorusSingingType) {
    ChorusSingingTypeSolo = 1,
    ChorusSingingTypeChorus = 2,
};
@interface ChorusWaitingSingerJoinView : UIView

@property (nonatomic, copy) void(^startSingingTypeBlock)(ChorusSingingType actionType);

- (void)updateUI;

@end

NS_ASSUME_NONNULL_END
