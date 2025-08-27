//
//  AIRoomInfoModel.h
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import <Foundation/Foundation.h>
#import "AISettingModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NetworkQuality) {
    NetworkQuality_Unknown = 0,
    NetworkQuality_Excellent,
    NetworkQuality_Good,
    NetworkQuality_Poor,
    NetworkQuality_Bad
};

@interface AIRoomInfoModel : NSObject

@property (nonatomic, copy) NSString *roomId;
@property (nonatomic, copy) NSString *userId;
@property (nonatomic, assign) BOOL isAIReady;
@property (nonatomic, assign) BOOL isAITalking;
@property (nonatomic, assign) BOOL isUserTalking;
@property (nonatomic, assign) NetworkQuality networtQuality;

@end

NS_ASSUME_NONNULL_END
