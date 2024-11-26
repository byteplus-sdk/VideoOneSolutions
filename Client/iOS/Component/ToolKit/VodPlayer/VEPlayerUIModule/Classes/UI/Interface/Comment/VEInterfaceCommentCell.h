//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const VEInterfaceCommentCelLightID;

extern NSString *const VEInterfaceCommentCelDarkID;

@class VECommentModel;
@interface VEInterfaceCommentCell : UITableViewCell

@property (nonatomic, strong) VECommentModel *comment;

@property (nonatomic, nonnull, copy) void (^deleteComment)(VECommentModel *comment);

@property (nonatomic, nonnull, copy) void (^longPressComment)(VECommentModel *comment);

@end

NS_ASSUME_NONNULL_END
