//
//  AIAlertViewController.h
//  AIChat
//
//  Created by ByteDance on 2025/3/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AIAlertViewControllerDelegate <NSObject>

- (void)onConfirmJumpToSettingVC;

@end

@interface AIAlertViewController : UIViewController

@property (nonatomic, weak) id<AIAlertViewControllerDelegate> delegate;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
