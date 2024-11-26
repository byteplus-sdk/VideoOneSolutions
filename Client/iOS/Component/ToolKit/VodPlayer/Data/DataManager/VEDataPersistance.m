// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEDataPersistance.h"

@implementation VEDataPersistance

+ (NSString *)castKeyFor:(VEDataCacheKey)cacheKey {
    switch (cacheKey) {
        case VEDataCacheKeyPlayLoop:
            return @"play_loop_mode";
            break;
        default:
            NSAssert(NO, @"key has not been impl.");
    }
}


+ (BOOL)boolValueFor:(VEDataCacheKey)key defaultValue:(BOOL)defaultValue {
    id v = [[NSUserDefaults standardUserDefaults] valueForKey:[VEDataPersistance castKeyFor:key]];
    if (v && [v isKindOfClass:[NSNumber class]]) {
        NSNumber *cast = (NSNumber *)v;
        return cast.boolValue;
    }
    return defaultValue;
}

+ (NSString *)stringValueFor:(VEDataCacheKey)key defaultValue:(NSString *)defaultValue {
    id v = [[NSUserDefaults standardUserDefaults] valueForKey:[VEDataPersistance castKeyFor:key]];
    if (v && [v isKindOfClass:[NSString class]]) {
        return v;
    }
    return defaultValue;
}


+ (void)setBoolValue:(BOOL)value forKey:(VEDataCacheKey)key {
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:value] forKey:[VEDataPersistance castKeyFor:key]];
}

+ (void)setStringValue:(NSString *)value forKey:(VEDataCacheKey)key {
    [[NSUserDefaults standardUserDefaults] setValue:value ?: @"" forKey:[VEDataPersistance castKeyFor:key]];
}

@end
