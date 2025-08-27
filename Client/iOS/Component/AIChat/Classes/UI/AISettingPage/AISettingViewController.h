//
//  AISettingViewController.h
//  AIChat-AIChat
//
//  Created by ByteDance on 2025/3/11.
//

#import <UIKit/UIKit.h>
#import "AIRTCManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface AISettingViewController : UIViewController

@property (nonatomic, copy) void(^onBackBlock)(void);

- (instancetype)initWithRTCManager:(AIRTCManager *)rtcManager;

@end

NS_ASSUME_NONNULL_END
