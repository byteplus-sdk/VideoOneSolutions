//
//  LiveFeedViewController.h
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/11.
//

#import "TTViewController.h"
#import "TTLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface LiveFeedViewController : TTViewController

- (instancetype)initWithLiveModel:(TTLiveModel *)liveModel;

@end

NS_ASSUME_NONNULL_END
