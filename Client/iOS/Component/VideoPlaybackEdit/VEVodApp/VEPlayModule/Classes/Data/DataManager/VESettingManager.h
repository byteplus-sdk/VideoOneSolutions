// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;
#import "VESettingModel.h"

@interface VESettingManager : NSObject

+ (VESettingManager *)universalManager;
- (NSArray *)settingSections;
- (NSDictionary *)settings;

- (VESettingModel *)settingForKey:(VESettingKey)key;

- (NSString *)sectionKeyLocalized:(NSString *)key;

@end
