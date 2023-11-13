// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "ToastComponent.h"
#import "DeviceInforTool.h"
#import "Masonry.h"

@interface ToastComponent ()

@property (nonatomic, weak) ToastView *keepToastView;
@property (nonatomic, strong) UIWindow *toastWindow;

@end

@implementation ToastComponent

+ (ToastComponent *)shareToastComponent {
    static dispatch_once_t onceToken;
    static ToastComponent *toastComponent = nil;
    dispatch_once(&onceToken, ^{
        toastComponent = [[self alloc] init];
    });
    return toastComponent;
}

#pragma mark - Normal Toast

- (void)showWithMessage:(NSString *)message {
    [self _showWithMessage:message describe:@"" status:ToastViewStatusNone view:nil keep:NO delay:0 block:nil];
}

- (void)showWithMessage:(NSString *)message block:(void (^)(BOOL result))block {
    [self _showWithMessage:message describe:@"" status:ToastViewStatusNone view:nil keep:NO delay:0 block:block];
}

- (void)showWithMessage:(NSString *)message delay:(NSTimeInterval)delay {
    [self _showWithMessage:message describe:@"" status:ToastViewStatusNone view:nil keep:NO delay:delay block:nil];
}

- (void)showWithMessage:(NSString *)message describe:(NSString *)describe status:(ToastViewStatus)status {
    [self _showWithMessage:message describe:describe status:status view:nil keep:NO delay:0 block:nil];
}

- (void)showWithMessage:(NSString *)message describe:(NSString *)describe status:(ToastViewStatus)status block:(void (^)(BOOL))block {
    [self _showWithMessage:message describe:describe status:status view:nil keep:NO delay:0 block:block];
}

- (void)showWithMessage:(NSString *)message describe:(NSString *)describe status:(ToastViewStatus)status view:(UIView *)view delay:(NSTimeInterval)delay block:(void (^)(BOOL))block {
    [self _showWithMessage:message describe:describe status:status view:view keep:NO delay:delay block:block];
}

- (void)_showWithMessage:(NSString *)message
                describe:(NSString *)describe
                  status:(ToastViewStatus)status
                    view:(UIView *)view
                    keep:(BOOL)isKeep
                   delay:(NSTimeInterval)delay
                   block:(void (^)(BOOL result))block {
    dispatch_block_t showBlock = ^() {
        if (self.keepToastView) {
            [self dismiss];
        }

        UIView *windowView = view;
        if (!windowView) {
            windowView = [DeviceInforTool topViewController].view;
        }
        ToastView *toastView = [[ToastView alloc] init];
        [toastView updateMessage:message describe:describe stauts:status];
        [windowView addSubview:toastView];
        [toastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(windowView);
        }];

        if (isKeep) {
            self.keepToastView = toastView;
            return;
        }

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [toastView removeFromSuperview];
            if (block) {
                block(YES);
            }
        });
    };

    if (delay > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), showBlock);
    } else {
        dispatch_queue_async_safe(dispatch_get_main_queue(), showBlock);
    }
}

#pragma mark - Keep Toast

- (void)showKeepMessage:(NSString *)message view:(UIView *)view {
    [self _showWithMessage:message describe:@"" status:ToastViewStatusNone view:view keep:YES delay:0 block:nil];
}

- (void)showLoading {
    [self showLoadingAtView:nil];
}

- (void)showLoadingAtView:(UIView *)view {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (self.keepToastView) {
            [self dismiss];
        }

        UIView *windowView = view;
        if (!windowView) {
            windowView = [DeviceInforTool topViewController].view;
        }
        ToastView *toastView = [[ToastView alloc] initWithFrame:windowView.bounds];
        [toastView startLoading];
        [windowView addSubview:toastView];
        [toastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(windowView);
        }];
        self.keepToastView = toastView;
    });
}

- (void)dismiss {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        [self.keepToastView stopLoaidng];
        [self.keepToastView removeFromSuperview];
        self.keepToastView = nil;
    });
}

#pragma mark - Global Toast

- (void)showGlobalToast:(NSString *)message {
    [self showGlobalToast:message describe:@"" status:ToastViewStatusNone];
}

- (void)showGlobalToast:(NSString *)message describe:(NSString *)describe status:(ToastViewStatus)status {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if (self.toastWindow) {
            [self dismissGlobalToast];
        }

        ToastView *toastView = [[ToastView alloc] init];
        [toastView updateMessage:message describe:describe stauts:status];
        UIWindow *toastWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [toastWindow addSubview:toastView];
        toastWindow.hidden = NO;
        toastWindow.userInteractionEnabled = NO;
        [toastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(toastWindow);
        }];
        self.toastWindow = toastWindow;
    });
}

- (void)dismissGlobalToast {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        self.toastWindow.hidden = YES;
        if (@available(iOS 13.0, *)) {
            self.toastWindow.windowScene = nil;
        }
        self.toastWindow = nil;
    });
}

@end
