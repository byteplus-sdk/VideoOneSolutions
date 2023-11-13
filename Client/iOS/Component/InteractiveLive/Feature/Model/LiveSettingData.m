// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveSettingData.h"

@implementation LiveSettingData

#pragma mark - Getter
+ (BOOL)rtmPullStreaming {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:[NSString stringWithFormat:@"LiveSettingTypeOf%ld", (long)LiveSettingRTMPullStreaming]];
}

+ (BOOL)rtmPushStreaming {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:[NSString stringWithFormat:@"LiveSettingTypeOf%ld", (long)LiveSettingRTMPushStreaming]];
}

+ (BOOL)abr {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:[NSString stringWithFormat:@"LiveSettingTypeOf%ld", (long)LiveSettingABR]];
}

#pragma mark - Setter

+ (void)setRtmPullStreaming:(BOOL)rtmPullStreaming {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:rtmPullStreaming forKey:[NSString stringWithFormat:@"LiveSettingTypeOf%ld", (long)LiveSettingRTMPullStreaming]];
    [defaults synchronize];
}

+ (void)setRtmPushStreaming:(BOOL)rtmPushStreaming {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:rtmPushStreaming forKey:[NSString stringWithFormat:@"LiveSettingTypeOf%ld", (long)LiveSettingRTMPushStreaming]];
    [defaults synchronize];
}

+ (void)setAbr:(BOOL)abr {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:abr forKey:[NSString stringWithFormat:@"LiveSettingTypeOf%ld", (long)LiveSettingABR]];
    [defaults synchronize];
}

+ (BOOL)boolValueForKey:(LiveSettingCellType)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:[NSString stringWithFormat:@"LiveSettingTypeOf%ld", (long)key]];
}

@end
