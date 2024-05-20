// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELUILabel : UILabel
@property (nonatomic, assign) CGFloat lineHeight;
// NSFontAttributeName : [UIFont systemFontOfSize:14],
// NSForegroundColorAttributeName : UIColor.blackColor
// };
@property(nullable, nonatomic, copy) NSDictionary <NSAttributedStringKey, id> *textAttributes;
@property(nonatomic,assign) BOOL canCopy;
@property(nonatomic, copy, nullable) void (^didCopyBlock)(VELUILabel *label, NSString *stringCopied);

@end

NS_ASSUME_NONNULL_END
