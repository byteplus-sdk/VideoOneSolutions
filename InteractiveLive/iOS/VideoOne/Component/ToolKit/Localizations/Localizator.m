// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "Localizator.h"

static NSString *const Chinese_Simple = @"zh-Hans";
static NSString *const English_US = @"en";
static NSString *const LocalizedFalse = @"Localized_Parsing_Failed_Key";

@interface Localizator ()

@end

@implementation Localizator

#pragma mark - Publish Action

+ (NSString *)localizedStringForKey:(NSString *)key bundleName:(NSString *)bundleName {
    // Get the Localizable.bundle path of a component
    NSString *bundlePath = @"";
    if (bundleName == nil || bundleName.length == 0) {
        bundleName = @"Localizable";
        bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    } else {
        bundlePath = [[[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"] stringByAppendingPathComponent:@"Localizable.bundle"];
    }
    // Get the path of the corresponding language in Localizable
    NSString *curLanguage = [Localizator getCurrentLanguage];
    NSString *lprojPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:curLanguage ofType:@"lproj"];
    if (IsEmptyStr(lprojPath)) {
        lprojPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:Chinese_Simple ofType:@"lproj"];
    }
    NSBundle *resourceBundle = [NSBundle bundleWithPath:lprojPath];
    // Get the value based on a given key
    NSString *valueString = NSLocalizedStringWithDefaultValue(key, @"Localizable", resourceBundle, LocalizedFalse, @"");
    // If parsing fails, search again in the ToolKit component.
    if ([valueString isEqualToString:LocalizedFalse]) {
        valueString = [Localizator localizedToolKitStringForKey:key];
    }
    return valueString;
}

+ (NSString *)getLanguageKey {
    return [Localizator localizedToolKitStringForKey:@"language_code"];
}

#pragma mark - Private Action

+ (NSString *)localizedToolKitStringForKey:(NSString *)key {
    NSString *bundlePath = [[[NSBundle mainBundle] pathForResource:@"ToolKit" ofType:@"bundle"] stringByAppendingPathComponent:@"Localizable.bundle"];
    NSString *curLanguage = [Localizator getCurrentLanguage];
    NSString *lprojPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:curLanguage ofType:@"lproj"];
    if (IsEmptyStr(lprojPath)) {
        lprojPath = [[NSBundle bundleWithPath:bundlePath] pathForResource:Chinese_Simple ofType:@"lproj"];
    }
    NSBundle *resourceBundle = [NSBundle bundleWithPath:lprojPath];
    NSString *valueString = [resourceBundle localizedStringForKey:key value:@"" table:nil];
    return valueString;
}

+ (NSString *)getCurrentLanguage {
    NSString *curLanguage = @"";
    NSString *systemLanguage = [Localizator getSystemLanguage];
    if ([systemLanguage hasPrefix:Chinese_Simple]) {
        curLanguage = Chinese_Simple;
    } else if ([systemLanguage hasPrefix:English_US]) {
        curLanguage = English_US;
    } else {
        curLanguage = English_US;
    }
    return English_US;
}

+ (NSString *)getSystemLanguage {
    NSArray *preferredLanguages = [NSLocale preferredLanguages];
    NSString *currLanguage = @"";
    if (preferredLanguages.count > 0) {
        currLanguage = preferredLanguages[0];
    }
    return currLanguage;
}

@end
