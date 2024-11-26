//
//  TTLiveCellController.h
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/9.
//

#import <Foundation/Foundation.h>
#import "TTPageViewController.h"
#import "TTLivePlayerManager.h"

@class TTMixModel;
@class TTLiveCellController;

NS_ASSUME_NONNULL_BEGIN

@interface TTLiveCellController : UIViewController <TTPageItem, TTLiveCellProtocol>

@property (nonatomic, strong) TTMixModel *mixModel;


@end

NS_ASSUME_NONNULL_END
