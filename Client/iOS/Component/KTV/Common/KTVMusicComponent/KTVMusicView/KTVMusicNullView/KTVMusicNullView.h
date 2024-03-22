//
//  KTVMusicNullView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <UIKit/UIKit.h>
#import "KTVUserModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicNullView : UIView

@property (nonatomic, strong) KTVUserModel *loginUserModel;

@property (nonatomic, copy) void (^clickPlayMusicBlock)(void);

@end

NS_ASSUME_NONNULL_END
