//
//  AIRTCManager.h
//  AFNetworking
//
//  Created by ByteDance on 2025/3/13.
//

#import "BaseRTCManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AIRTCManagerDelegate <NSObject>

@optional

- (void)onJoinRoomSuccess:(BOOL)res;

- (void)onLocalUserSpeaking;

- (void)onActiveSpeakerChange:(BOOL)isLocalUser;

- (void)onAISpeaking;

- (void)onAIReady;

@end

@interface AIRTCManager : BaseRTCManager

- (void)joinRoom:(NSString *)token
          roomId:(NSString *)roomId
          userId:(NSString *)userId
           block:(void (^__nullable)(int res ))block;

- (void)leaveRoom;

- (void)startPublishAudio;

- (void)stopPublishAudio;

- (void)startAudioCapture;

- (void)stopAudioCapture;

- (ByteRTCMediaPlayer *)getMediaPlayer;

@property (nonatomic, weak) id<AIRTCManagerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
