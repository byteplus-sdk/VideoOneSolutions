// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ToastViewStatus) {
    ToastViewStatusNone = 0,
    ToastViewStatusSucceed,
    ToastViewStatusWarning,
    ToastViewStatusFailed,
};

typedef NS_ENUM(NSInteger, ToastViewContentType) {
    ToastViewContentTypeNone,
    ToastViewContentTypeMeesage,
    ToastViewContentTypeActivityIndicator,
};

@interface ToastView : UIView

@property (nonatomic, assign) ToastViewContentType contentType;

- (void)updateMessage:(NSString *)message
             describe:(NSString *)describe
               stauts:(ToastViewStatus)status;

- (void)startLoading;

- (void)stopLoaidng;

@end

NS_ASSUME_NONNULL_END
