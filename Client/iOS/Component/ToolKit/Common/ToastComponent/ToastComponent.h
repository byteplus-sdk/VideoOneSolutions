// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "ToastView.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ToastComponent : NSObject

+ (ToastComponent *)shareToastComponent;

- (void)showWithMessage:(NSString *)message;

- (void)showWithMessage:(NSString *)message
                  block:(void (^_Nullable)(BOOL result))block;

- (void)showWithMessage:(NSString *)message
                  delay:(NSTimeInterval)delay;

- (void)showWithMessage:(NSString *)message
               describe:(NSString *)describe
                 status:(ToastViewStatus)status;

- (void)showWithMessage:(NSString *)message
               describe:(NSString *)describe
                 status:(ToastViewStatus)status
                  block:(void (^_Nullable)(BOOL result))block;

- (void)showWithMessage:(NSString *)message
               describe:(NSString *)describe
                 status:(ToastViewStatus)status
                   view:(UIView *)view
                  delay:(NSTimeInterval)delay
                  block:(void (^)(BOOL result))block;

#pragma mark - Keep Toast

- (void)showKeepMessage:(NSString *)message
                   view:(UIView *_Nullable)view;

- (void)showLoading;

- (void)showLoadingWithMessage:(NSString *)message;

- (void)showLoadingAtView:(UIView *_Nullable)view;

- (void)dismiss;

#pragma mark - Global Toast

- (void)showGlobalToast:(NSString *)message;

- (void)showGlobalToast:(NSString *)message
               describe:(NSString *)describe
                 status:(ToastViewStatus)status;

- (void)dismissGlobalToast;

@end

NS_ASSUME_NONNULL_END
