//
//  LivePlayerManager.h
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TTLiveModel.h"

NS_ASSUME_NONNULL_BEGIN

@class TTLivePlayerController;

@protocol TTLiveCellProtocol <NSObject>

- (TTLiveModel *)getLiveModel;

- (UIView *)getRenderView;

@end

@interface TTLivePlayerManager : NSObject

+ (instancetype)sharedLiveManager;

@property (nonatomic, strong, nullable) TTLivePlayerController *reusePlayer;

- (TTLivePlayerController *)createLivePlayer;

- (void)recoveryAllPlayerWithException:(nullable TTLivePlayerController *)player;

- (void)recoveryPlayer:(TTLivePlayerController *)player;

- (void)cleanCache;

@end

NS_ASSUME_NONNULL_END
