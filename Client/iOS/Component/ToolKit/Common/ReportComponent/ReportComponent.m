// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "ReportComponent.h"
#import "DeviceInforTool.h"
#import "Localizator.h"
#import "NetworkingManager+Report.h"
#import "ToastComponent.h"

@interface ReportComponent ()

@property (nonatomic, strong) NSMutableSet<NSString *> *blockedSet;

@end

@implementation ReportComponent

+ (instancetype)shared {
    static ReportComponent *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });

    return _instance;
}

+ (void)blockAndReportUser:(NSString *)userID {
    [self blockAndReport:userID
                   title:LocalizedStringFromBundle(@"user_sheet_title", ToolKitBundleName)
           cancelHandler:nil
         blockCompletion:nil
        reportCompletion:nil];
}

+ (void)blockAndReport:(NSString *)key
                 title:(NSString *)title
         cancelHandler:(void (^)(void))cancelHandler
       blockCompletion:(void (^)(void))blockCompletion
      reportCompletion:(void (^)(void))reportCompletion {
    [self showBlockAndReportSheet:key
                            title:title
                    cancelHandler:cancelHandler
                     blockHandler:^{
                         [[ToastComponent shareToastComponent] showLoading];
                         [NetworkingManager blockWithKey:key block:^(NetworkingResponse *_Nonnull response) {
                             [[ToastComponent shareToastComponent] dismiss];
                             NSString *message = LocalizedStringFromBundle(@"block_toast_message", ToolKitBundleName);
                             [[ToastComponent shareToastComponent] showWithMessage:message];
                             [self setBlockedKey:key];
                             if (blockCompletion) {
                                 blockCompletion();
                             }
                         }];
                     }
                 reportCompletion:reportCompletion];
}

+ (void)showBlockAndReportSheet:(NSString *)key
                          title:(NSString *)title
                  cancelHandler:(void (^)(void))cancelHandler
                   blockHandler:(void (^)(void))blockHandler
               reportCompletion:(void (^)(void))reportCompletion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:LocalizedStringFromBundle(@"sheet_cancel_button", ToolKitBundleName)
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       if (cancelHandler) {
                                                           cancelHandler();
                                                       }
                                                   }];
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:LocalizedStringFromBundle(@"sheet_report_button", ToolKitBundleName)
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *_Nonnull action) {
                                                             [self report:key cancelHandler:cancelHandler completion:reportCompletion];
                                                         }];

    UIAlertAction *blockAction = [UIAlertAction actionWithTitle:LocalizedStringFromBundle(@"sheet_block_button", ToolKitBundleName)
                                                          style:UIAlertActionStyleDefault
                                                        handler:^(UIAlertAction *_Nonnull action) {
                                                            if (blockHandler) {
                                                                blockHandler();
                                                            }
                                                        }];

    [alertController addAction:cancel];
    [alertController addAction:blockAction];
    [alertController addAction:reportAction];
    [[DeviceInforTool topViewController] presentViewController:alertController animated:YES completion:nil];
}

+ (void)report:(NSString *)key cancelHandler:(void (^)(void))cancelHandler completion:(void (^)(void))completion {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:LocalizedStringFromBundle(@"report_list_sheet_title", ToolKitBundleName)
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:LocalizedStringFromBundle(@"sheet_cancel_button", ToolKitBundleName)
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *_Nonnull action) {
                                                       if (cancelHandler) {
                                                           cancelHandler();
                                                       }
                                                   }];
    [alertController addAction:cancel];
    for (int i = 0; i < 8; i++) {
        NSString *reportMessage = [self getReportMessage:i];
        UIAlertAction *action = [UIAlertAction actionWithTitle:reportMessage
                                                         style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction *_Nonnull action) {
                                                           [[ToastComponent shareToastComponent] showLoading];
                                                           [NetworkingManager reportWithKey:key message:reportMessage block:^(NetworkingResponse *_Nonnull response) {
                                                               [[ToastComponent shareToastComponent] dismiss];
                                                               [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"report_toast_message", ToolKitBundleName)];
                                                               if (completion) {
                                                                   completion();
                                                               }
                                                           }];
                                                       }];
        [alertController addAction:action];
    }
    [[DeviceInforTool topViewController] presentViewController:alertController animated:YES completion:nil];
}

+ (void)setBlockedKey:(NSString *)blockedKey {
    if (IsEmptyStr(blockedKey)) {
        return;
    }
    [[[self shared] blockedSet] addObject:blockedKey];
}

+ (BOOL)containsBlockedKey:(NSString *)blockedKey {
    if (IsEmptyStr(blockedKey)) {
        return NO;
    }
    return [[[self shared] blockedSet] containsObject:blockedKey];
}

#pragma mark - Private Action

+ (NSString *)getReportMessage:(NSInteger)index {
    NSString *message = @"";
    switch (index) {
        case 0:
            message = LocalizedStringFromBundle(@"report_message_1", ToolKitBundleName);
            break;
        case 1:
            message = LocalizedStringFromBundle(@"report_message_2", ToolKitBundleName);
            break;
        case 2:
            message = LocalizedStringFromBundle(@"report_message_3", ToolKitBundleName);
            break;
        case 3:
            message = LocalizedStringFromBundle(@"report_message_4", ToolKitBundleName);
            break;
        case 4:
            message = LocalizedStringFromBundle(@"report_message_5", ToolKitBundleName);
            break;
        case 5:
            message = LocalizedStringFromBundle(@"report_message_6", ToolKitBundleName);
            break;
        case 6:
            message = LocalizedStringFromBundle(@"report_message_7", ToolKitBundleName);
            break;
        case 7:
            message = LocalizedStringFromBundle(@"report_message_8", ToolKitBundleName);
            break;

        default:
            break;
    }
    return message;
}

- (NSMutableSet<NSString *> *)blockedSet {
    if (!_blockedSet) {
        _blockedSet = [NSMutableSet set];
    }
    return _blockedSet;
}

@end
