//
//  AISettingModel.m
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import "AISettingModel.h"

@implementation AISettingModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = AIModelTypeRealTime;
    }
    return self;
}

- (NSString *)currentVoiceRoleName {
    if (self.type == AIModelTypeRealTime) {
        return self.realTimeVoiceRoleName;
    } else {
        return self.flexibleVoiceRoleName;
    }
}

- (void)setCurrentVoiceRoleName:(NSString *)currentVoiceRoleName {
    if (self.type == AIModelTypeRealTime) {
        _realTimeVoiceRoleName = currentVoiceRoleName;
    } else {
        _flexibleVoiceRoleName = currentVoiceRoleName;
    }
}

- (NSString *)currentVoiceProviderName {
    if (self.type == AIModelTypeRealTime) {
        return self.realTimeVoiceProviderName;
    } else {
        return self.flexibleVoiceProviderName;
    }
}

- (void)setCurrentVoiceProviderName:(NSString *)currentVoiceProviderName {
    if (self.type == AIModelTypeRealTime) {
        _realTimeVoiceProviderName = currentVoiceProviderName;
    } else {
        _flexibleVoiceProviderName = currentVoiceProviderName;
    }
}

@end
