// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
#import "ToastView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ToastComponent : NSObject

+ (ToastComponent *)shareToastComponent;

- (void)showWithMessage:(NSString *)message;

- (void)showWithMessage:(NSString *)message block:(void (^)(BOOL result))block;

- (void)showWithMessage:(NSString *)message delay:(CGFloat)delay;

- (void)showWithMessage:(NSString *)message view:(UIView *)windowView;

- (void)showWithMessage:(NSString *)message view:(UIView *)windowView block:(void (^)(BOOL result))block;

- (void)showWithMessage:(NSString *)message view:(UIView *)windowView keep:(BOOL)isKeep block:(void (^)(BOOL result))block;

- (void)showWithMessage:(NSString *)message describe:(NSString *)describe status:(ToastViewStatus)status;

- (void)showLoading;

- (void)showLoadingAtView:(UIView *)windowView;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
