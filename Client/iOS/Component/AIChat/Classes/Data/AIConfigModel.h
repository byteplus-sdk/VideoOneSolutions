//
//  AIConfigModel.h
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface AIBaseInfo :NSObject <YYModel>
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *icon;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *url;
@end

@interface VoiceVenderType:NSObject <YYModel>
@property (nonatomic, copy) NSString *providerName;
@property (nonatomic, copy) NSString *providerIcon;
@property (nonatomic, strong) NSArray<AIBaseInfo *> *voiceList;
@end

@interface AIConfigModel:NSObject <YYModel>

@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, copy) NSString *welcomeSpeech;
@property (nonatomic, strong) NSArray<VoiceVenderType *> *realtimeVoiceVendors;
@property (nonatomic, strong) NSArray<VoiceVenderType *> *flexibleVoiceVendors;
@property (nonatomic, strong) NSArray<AIBaseInfo *> *llmVendors;
@property (nonatomic, strong) NSArray<AIBaseInfo *> *asrVendors;
@property (nonatomic, strong) NSArray<NSString *> *presetQuestions;

@end

NS_ASSUME_NONNULL_END
