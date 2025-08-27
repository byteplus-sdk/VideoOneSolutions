//
//  AITextSettingViewController.h
//  AIChat
//
//  Created by ByteDance on 2025/3/19.
//

#import <UIKit/UIKit.h>
#import "AISettingManager.h"
#import "AISettingTableCellView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AITextSettingViewController : UIViewController

- (instancetype)initWithType:(AITableSettingViewControllerType)type;

@property (nonatomic, copy) void (^saveBlock)(void);


@end

NS_ASSUME_NONNULL_END
