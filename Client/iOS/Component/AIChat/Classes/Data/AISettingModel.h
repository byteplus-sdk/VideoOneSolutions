//
//  AISettingModel.h
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import <Foundation/Foundation.h>
#import "AIConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, AIModelType) {
    AIModelTypeRealTime,
    AIModelTypeFlexible
};

@interface AISettingModel : NSObject

@property (nonatomic, assign) AIModelType type;
@property (nonatomic, copy) NSString *realTimeVoiceRoleName;
@property (nonatomic, copy) NSString *flexibleVoiceRoleName;
@property (nonatomic, copy) NSString *currentVoiceRoleName;

@property (nonatomic, copy) NSString *realTimeVoiceProviderName;
@property (nonatomic, copy) NSString *flexibleVoiceProviderName;
@property (nonatomic, copy) NSString *currentVoiceProviderName;

@property (nonatomic, copy) NSString *currentLLMVendorName;
@property (nonatomic, copy) NSString *currentASRVendorName;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, copy) NSString *welcomeSpeech;
@property (nonatomic, strong) NSArray<NSString *> *presetQuestions;

@end

NS_ASSUME_NONNULL_END
