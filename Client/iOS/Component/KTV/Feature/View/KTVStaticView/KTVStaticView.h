//
//  KTVStaticView.h
//  veRTC_Demo
//
//  Created by on 2021/11/29.
//  
//

#import <UIKit/UIKit.h>
@class KTVRoomModel;
@class KTVRoomParamInfoModel;

NS_ASSUME_NONNULL_BEGIN

@interface KTVStaticView : UIView

@property (nonatomic, strong) KTVRoomModel *roomModel;

@property (nonatomic, copy) void (^clickEndBlock)(void);

- (void)updatePeopleNum:(NSInteger)count;

- (void)updateParamInfoModel:(KTVRoomParamInfoModel *)paramInfoModel;

@end

NS_ASSUME_NONNULL_END
