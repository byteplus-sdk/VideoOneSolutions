// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;
#import "VESettingModel.h"

@interface MDAdSettingManager : NSObject

+ (MDAdSettingManager *)universalManager;
- (NSArray *)settingSections;
- (NSDictionary *)settings;
- (NSString *)sectionKeyLocalized:(NSString *)key;
- (BOOL)prerollEnabled;
- (BOOL)midrollEnabled;
- (BOOL)postrollEnabled;

@end
