//
//  AISettingManager.m
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import "AISettingManager.h"

@interface AISettingManager ()

@property(nonatomic, strong) AISettingModel *settingModel;

@property(nonatomic, strong) AIConfigModel *configModel;

@end

@implementation AISettingManager

+ (instancetype)sharedInstance {
    static AISettingManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AISettingManager alloc] init];
    });
    return instance;
}

- (void)initSettingModel:(AIConfigModel *)configModel {
    _configModel = configModel;
    if (!_settingModel) {
        _settingModel = [[AISettingModel alloc] init];
        _settingModel.type = AIModelTypeRealTime;
        _settingModel.welcomeSpeech = configModel.welcomeSpeech;
        _settingModel.prompt = configModel.prompt;
        _settingModel.presetQuestions = configModel.presetQuestions;
        if (configModel.llmVendors.count > 0) {
            _settingModel.currentLLMVendorName = configModel.llmVendors.firstObject.name;
        }
        if (configModel.asrVendors.count > 0) {
            _settingModel.currentASRVendorName =  configModel.asrVendors.firstObject.name;
        }
        if (configModel.realtimeVoiceVendors.count > 0) {
            VoiceVenderType *firstVoiceVendor = configModel.realtimeVoiceVendors.firstObject;
            _settingModel.realTimeVoiceRoleName = firstVoiceVendor.voiceList.firstObject.name;
            if (firstVoiceVendor.voiceList.count > 0) {
                _settingModel.realTimeVoiceRoleName = firstVoiceVendor.voiceList.firstObject.name;
                _settingModel.realTimeVoiceProviderName = firstVoiceVendor.providerName;
            }
        }
        if (configModel.flexibleVoiceVendors.count > 0) {
            VoiceVenderType *firstVoiceVendor = configModel.flexibleVoiceVendors.firstObject;
            _settingModel.flexibleVoiceRoleName = firstVoiceVendor.voiceList.firstObject.name;
            if (firstVoiceVendor.voiceList.count > 0) {
                _settingModel.flexibleVoiceRoleName = firstVoiceVendor.voiceList.firstObject.name;
                _settingModel.flexibleVoiceProviderName = firstVoiceVendor.providerName;
            }
        }
    }
}

- (void)updateSetting:(AISettingModel *)settingModel {
    _settingModel = settingModel;
}
@end
