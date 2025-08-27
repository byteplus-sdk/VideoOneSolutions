//
//  AIBaseSettingPage.h
//  AIChat
//
//  Created by ByteDance on 2025/3/19.
//

#import <UIKit/UIKit.h>
#import "AISettingManager.h"
#import "AISettingTableCellView.h"
#import "AIRTCManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface AITableSettingViewController : UIViewController

- (instancetype)initWithType:(AITableSettingViewControllerType)type rtcManager:(AIRTCManager *)rtcManager;

@property (nonatomic, copy) void (^saveBlock)(void);

@end

NS_ASSUME_NONNULL_END
