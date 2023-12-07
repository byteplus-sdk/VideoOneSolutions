//
//  BaseLoadingView.h
//  ToolKit
//
//  Created by bytedance on 2023/10/25.
//

#import <UIKit/UIKit.h>



@interface BaseLoadingView : UIView

+ (instancetype)sharedInstance;

- (void)startLoadingIn:(UIView *)view;
- (void)stopLoading;

@end

