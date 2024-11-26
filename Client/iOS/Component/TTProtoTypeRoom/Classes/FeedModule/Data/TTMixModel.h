//
//  TTMixModel.h
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>
#import "TTVideoModel.h"
#import "TTLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    TTModelTypeVideo = 1,
    TTModelTypeLive
} TTModelType;

typedef enum : NSUInteger {
    TTUsesrStatusOffline = 1,
    TTUsesrStatusLiving,
} TTUsesrStatus;

@interface TTMixModel : NSObject <YYModel>

@property (nonatomic, assign) TTModelType modelType;

@property (nonatomic, assign) TTUsesrStatus userStatus;

@property (nonatomic, strong) TTVideoModel *videoModel;

@property (nonatomic, strong) TTLiveModel *liveModel;

@end

NS_ASSUME_NONNULL_END
