// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

#define LocalizedStringFromBundle(key, bundle) \
        [LocalizatorBundle localizedStringForKey:(key) bundleName:bundle]

NS_ASSUME_NONNULL_BEGIN

@interface LocalizatorBundle : NSObject

+ (NSString *)localizedStringForKey:(NSString *)key bundleName:(nullable NSString *)bundleName;

+ (NSString *)currentLangeuage;
@end

NS_ASSUME_NONNULL_END
