// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    VEDataCacheKeyPlayLoop = 0,
    
} VEDataCacheKey;

@interface VEDataPersistance : NSObject

+ (BOOL)boolValueFor:(VEDataCacheKey)key defaultValue:(BOOL)defaultValue;
+ (NSString *)stringValueFor:(VEDataCacheKey)key defaultValue:(NSString *)defaultValue;

+ (void)setBoolValue:(BOOL)value forKey:(VEDataCacheKey)key;
+ (void)setStringValue:(NSString *)value forKey:(VEDataCacheKey)key;

@end


