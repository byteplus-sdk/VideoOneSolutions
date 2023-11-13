// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AlertActionManager.h"
#import "AlertActionViewController.h"
#import "DeviceInforTool.h"

@interface AlertActionManager ()

@property (nonatomic, weak) AlertActionViewController *currentAlertVC;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation AlertActionManager

+ (AlertActionManager *)shareAlertActionManager {
    static dispatch_once_t onceToken;
    static AlertActionManager *alertActionManager;
    dispatch_once(&onceToken, ^{
        alertActionManager = [[AlertActionManager alloc] init];
    });
    return alertActionManager;
}

#pragma mark - Publish Action

- (void)showWithMessage:(NSString *)message {
    [self showWithMessage:message actions:nil];
}

- (void)showWithMessage:(NSString *)message actions:(NSArray<AlertActionModel *> *)actions {
    [self showWithMessage:message actions:actions hideDelay:0];
}

- (void)showWithMessage:(NSString *)message
                actions:(NSArray<AlertActionModel *> *)actions
              hideDelay:(NSTimeInterval)delay {
    [self presentAlertWithTitle:message message:@"" actions:actions hideDelay:delay alertUserModel:nil];
}

- (void)showWithTitle:(NSString *)title
              message:(NSString *)message
              actions:(NSArray<AlertActionModel *> *)actions
            hideDelay:(NSTimeInterval)delay {
    [self presentAlertWithTitle:title message:message actions:actions hideDelay:delay alertUserModel:nil];
}

- (void)showWithTitle:(NSString *)title
              message:(NSString *)message
              actions:(NSArray<AlertActionModel *> *)actions
       alertUserModel:(AlertUserModel *)alertUserModel {
    [self presentAlertWithTitle:title message:message actions:actions hideDelay:0 alertUserModel:alertUserModel];
}

- (void)dismiss:(void (^)(void))completion {
    if (self.currentAlertVC) {
        [self stopTimer];
        [self.currentAlertVC dismissViewControllerAnimated:NO completion:^{
            if (completion) {
                completion();
            }
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

- (void)dismiss {
    [self dismiss:^{

    }];
}

#pragma mark - Private Action

- (void)presentAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                      actions:(NSArray<AlertActionModel *> *)actions
                    hideDelay:(NSTimeInterval)delay
               alertUserModel:(AlertUserModel *)alertUserModel {
    if (self.currentAlertVC != nil || actions.count < 1) {
        return;
    }
    NSUInteger len = MIN(actions.count, 2);
    actions = [actions subarrayWithRange:NSMakeRange(0, len)];
    AlertActionViewController *alertVC = [[AlertActionViewController alloc] initWithTitle:title describe:message];
    for (int i = 0; i < actions.count; i++) {
        [alertVC addAction:actions[i]];
    }
    [alertVC addAlertUser:alertUserModel];
    __weak __typeof(self) wself = self;
    alertVC.clickButtonBlock = ^{
        [wself dismiss];
    };
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [DeviceInforTool topViewController];
        alertVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
        [rootVC presentViewController:alertVC
                             animated:NO
                           completion:nil];
        wself.currentAlertVC = alertVC;
        [wself startTimer:delay];
    });
}

- (void)startTimer:(NSTimeInterval)interval {
    [self stopTimer];
    if (interval <= 0) {
        return;
    }
    self.timer = [NSTimer timerWithTimeInterval:interval target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
