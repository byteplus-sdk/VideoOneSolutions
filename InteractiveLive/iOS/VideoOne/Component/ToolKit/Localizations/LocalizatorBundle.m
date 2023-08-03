// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LocalizatorBundle.h"
#import "Localizator.h"

@implementation LocalizatorBundle

+ (NSString *)localizedStringForKey:(NSString *)key bundleName:(nullable NSString *)bundleName {
    return [Localizator localizedStringForKey:key bundleName:bundleName];
}

+ (NSString *)currentLangeuage {
    return [Localizator getCurrentLanguage];
}

@end
