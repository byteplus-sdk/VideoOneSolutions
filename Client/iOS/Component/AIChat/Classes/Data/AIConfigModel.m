//
//  AIConfigModel.m
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import "AIConfigModel.h"


@implementation AIBaseInfo
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"name": @"name",
        @"icon": @"pic",
        @"desc": @"desc",
        @"url": @"voice",
    };
}
@end

@implementation VoiceVenderType

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"providerName": @"provider_name",
        @"providerIcon": @"pic",
        @"voiceList": @"list",
    };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{
        @"voiceList": [AIBaseInfo class]
    };
}

@end

@implementation AIConfigModel
+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"prompt": @"prompt",
        @"welcomeSpeech": @"welcome_speech",
        @"realtimeVoiceVendors": @"realtime_voice_provider_list",
        @"flexibleVoiceVendors": @"flexible_voice_provider_list",
        @"llmVendors": @"llm_provider_list",
        @"asrVendors": @"asr_provider_list",
        @"presetQuestions": @"preset_questions"
    };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{
        @"realtimeVoiceVendors": [VoiceVenderType class],
        @"flexibleVoiceVendors": [VoiceVenderType class],
        @"llmVendors": [AIBaseInfo class],
        @"asrVendors": [AIBaseInfo class]
    };
}

@end
