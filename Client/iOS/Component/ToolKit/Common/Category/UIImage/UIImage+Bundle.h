// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Bundle)

+ (nullable UIImage *)imageNamed:(NSString *)name
                      bundleName:(NSString *_Nullable)bundle;

+ (nullable UIImage *)imageNamed:(NSString *)name
                      bundleName:(NSString *)bundle
                   subBundleName:(NSString *)subBundleName;

+ (UIImage *)avatarImageForUid:(NSString *)uid;

@end

NS_ASSUME_NONNULL_END
