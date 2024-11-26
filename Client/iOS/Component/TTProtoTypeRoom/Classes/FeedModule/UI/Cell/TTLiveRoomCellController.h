//
//  TTLiveRoomCellController.h
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/11.
//

#import "TTPageViewController.h"
#import "TTLivePlayerManager.h"
#import "TTLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTLiveRoomCellController : UIViewController  <TTPageItem, TTLiveCellProtocol>

@property (nonatomic, strong) TTLiveModel *liveModel;

@property (nonatomic, strong, readonly) UIView *renderView;

@end

NS_ASSUME_NONNULL_END
