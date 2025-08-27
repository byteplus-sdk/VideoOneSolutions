// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define LocalizedString(key) \
    [Localizator localizedStringForKey:(key) bundleName:HomeBundleName]

#define LocalizedStringFromBundle(key, bundle) \
    [Localizator localizedStringForKey:(key) bundleName:bundle]

@interface Localizator : NSObject

+ (NSString *)localizedStringForKey:(NSString *)key bundleName:(nullable NSString *)bundleName;

+ (NSString *)getLanguageKey;

+ (NSString *)getCurrentLanguage;

+ (BOOL)isChinese;

@end

NS_ASSUME_NONNULL_END
