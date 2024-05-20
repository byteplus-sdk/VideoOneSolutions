// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELAlertManager.h"
#import "VELCommonDefine.h"
#import "UIViewController+VELAdd.h"
#import <UIKit/UIKit.h>
@interface VELUIAlertController : UIAlertController
@property (nonatomic, assign) NSTimeInterval hideDelay;
@property (nonatomic, strong) NSTimer *timer;
@end
@implementation VELUIAlertController

- (void)startTimer {
    if (self.hideDelay <= 0) {
        return;
    }
    [self stopTimer];
    self.timer = [NSTimer timerWithTimeInterval:self.hideDelay
                                         target:self
                                       selector:@selector(dismiss)
                                       userInfo:nil
                                        repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)dismiss {
    [self stopTimer];
    [self dismissViewControllerAnimated:YES completion:^{}];
}
@end

@interface VELAlertManager ()
@property (nonatomic, strong) NSHashTable <VELUIAlertController *>*weakHashTable;
@end

@implementation VELAlertManager

+ (VELAlertManager *)shareManager {
    static dispatch_once_t onceToken;
    static VELAlertManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [[VELAlertManager alloc] init];
        manager.weakHashTable = [NSHashTable weakObjectsHashTable];
    });
    return manager;
}

#pragma mark - Publish Action

- (void)showWithMessage:(NSString *)message {
    [self showWithMessage:message actions:nil];
}

- (void)showWithMessage:(NSString *)message actions:(NSArray<VELAlertAction *> *)actions {
    [self showWithMessage:message actions:actions hideDelay:0];
}

- (void)showWithMessage:(NSString *)message actions:(NSArray<VELAlertAction *> *)actions hideDelay:(NSTimeInterval)delay {
    VELUIAlertController *alert = [VELUIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    alert.hideDelay = delay;
    for (int i = 0; i < actions.count; i++) {
        VELAlertAction *model = actions[i];
        UIAlertAction *alertAction = [UIAlertAction actionWithTitle:model.title
                                                              style:UIAlertActionStyleDefault
                                                            handler:^(UIAlertAction *_Nonnull action) {
            if (model.alertModelClickBlock) {
                model.alertModelClickBlock(action);
            }
        }];
        [alert addAction:alertAction];
    }
    [self.weakHashTable addObject:alert];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *rootVC = [UIViewController vel_topViewController];
        [rootVC presentViewController:alert animated:YES completion:^{
            [alert startTimer];
        }];
    });
}

- (void)dismissAllAlert {
    [self.weakHashTable.allObjects enumerateObjectsUsingBlock:^(VELUIAlertController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj dismiss];
    }];
}

@end
