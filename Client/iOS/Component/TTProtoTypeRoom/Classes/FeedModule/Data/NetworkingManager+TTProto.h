//
//  NetworkingManager+TTProto.h
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import <Foundation/Foundation.h>
#import "NetworkingManager.h"
#import "LiveMessageModel.h"
#import "TTMixModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NetworkingManager (TTProto)
+ (void)dataForMixFeedData:(NSRange)range
            userId:(NSString *)userId
             success:(void (^__nullable)(NSArray<TTMixModel *> *mixModels))success
             failure:(void (^__nullable)(NSString *errorMessage))failure;
+ (void)dataForLiveFeedData:(NSRange)range
                     userId:(NSString *)userId
                     roomId: (NSString *)roomId
                    success:(void (^__nullable)(NSArray<TTLiveModel *> *liveModels))success
                    failure:(void (^__nullable)(NSString *errorMessage))failure;

+ (void)liveSwitchFeedRoom:(NSString *)oldRoomId
                 newRoomId:(NSString *)newRoomId
                    userId:(NSString *)userID
                   success:(void (^__nullable)(NSInteger audienceCount))success
                   failure:(void (^__nullable)(NSString *errorMessage))failure;

+ (void)sendMessageInLiveRoom:(NSString *)roomId 
                       userId:(NSString *)userId
                 messageModel:(LiveMessageModel *)messageModel  success:(void (^__nullable)(void))success
                      failure:(void (^__nullable)(NSString *errorMessage))failure;
@end

NS_ASSUME_NONNULL_END
