//
//  AISettingManager.h
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import "AISettingModel.h"
#import "AIConfigModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AISettingManager : NSObject

+ (instancetype)sharedInstance;

- (void)updateSetting:(AISettingModel *)settingModel;

- (void)initSettingModel:(AIConfigModel *)configModel;

@property(nonatomic, strong, readonly) AIConfigModel *configModel;

@property(nonatomic, strong, readonly) AISettingModel *settingModel;

@end

NS_ASSUME_NONNULL_END
