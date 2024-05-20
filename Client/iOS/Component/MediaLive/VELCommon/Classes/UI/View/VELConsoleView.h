// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VELConsoleView : UIView
@property (nonatomic, copy) NSString *title;
@property (atomic, assign) BOOL showDate;
@property (nonatomic, copy) NSString *dateFormat;
- (void)updateInfo:(NSString *)info append:(BOOL)append;
- (void)updateInfo:(NSString *)info append:(BOOL)append date:(NSDate *)date;
@end

NS_ASSUME_NONNULL_END
