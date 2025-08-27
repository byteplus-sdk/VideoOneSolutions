//
//  AIRoomViewController.h
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import <UIKit/UIKit.h>
#import "AIRoomInfoModel.h"
#import "AIRTCManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface AIRoomViewController : UIViewController

- (instancetype)initWithRTCManager:(AIRTCManager* )rtcManager;

@end

NS_ASSUME_NONNULL_END
