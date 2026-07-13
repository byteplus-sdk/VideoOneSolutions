//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRTCMixer.h"
#import "LiveRTCInteractUtils.h"
#import "LiveSettingVideoConfig.h"

static NSString *kMixedStreamTaskId = @"pushCDNtaskId_001";

@interface LiveRTCMixer () <BaseRTCManagerMixedStreamDelegate>

@property (nonatomic, strong) ByteRTCEngine *rtcEngineKit;

// Mix streaming status
@property (nonatomic, assign) RTCMixStatus mixStatus;

// Mix streaming config
@property (nonatomic, strong) ByteRTCMixedStreamConfig *mixedStreamConfig;
@property (nonatomic, strong) ByteRTCMixedStreamPushTargetConfig *mixedStreamPushConfig;

@end

@implementation LiveRTCMixer

- (instancetype)initWithRTCEngine:(ByteRTCEngine *)rtcEngine {
    if (self = [super init]) {
        _rtcEngineKit = rtcEngine;
        // Confluence retweet Setting
        _mixedStreamConfig = [ByteRTCMixedStreamConfig defaultMixedStreamConfig];
        _mixedStreamPushConfig = [ByteRTCMixedStreamPushTargetConfig new];
        [LiveRTCManager shareRtc].mixedStreamDelegate = self;
    }
    return self;
}

- (void)startPushMixStreamToCDN {
    LivePushStreamParams *params = [self.delegate pushStreamConfigForMixer];
    NSAssert(params, @"push stream params for transocder is nil");
    NSString *rtmpUrl = [LiveRTCInteractUtils setPriorityForUrl:params.pushUrl];

    self.mixedStreamPushConfig.pushTargetType = ByteRTCMixedStreamPushTargetTypeToCDN;
    self.mixedStreamPushConfig.pushCDNURL = rtmpUrl;
    
    self.mixedStreamConfig.pushTargetType = ByteRTCMixedStreamPushTargetTypeToCDN;
    ByteRTCMixedStreamVideoConfig *videoConfig = [ByteRTCMixedStreamVideoConfig new];
    videoConfig.videoCodec = kCMVideoCodecType_H264;
    videoConfig.width = params.width;
    videoConfig.height = params.height;
    videoConfig.fps = params.fps;
    videoConfig.gop = params.gop;
    self.mixedStreamConfig.videoConfig = videoConfig;

    ByteRTCMixedStreamAudioConfig *audioConfig = [ByteRTCMixedStreamAudioConfig new];
    audioConfig.audioCodec = ByteRTCMixedStreamAudioCodecTypeAAC;
    audioConfig.sampleRate = 44100;
    audioConfig.channels = 2;
    audioConfig.bitrate = 64;
    
    self.mixedStreamConfig.audioConfig = audioConfig;
    self.mixedStreamConfig.pushURL = rtmpUrl;
    self.mixedStreamConfig.roomID = params.rtcRoomId;
    self.mixedStreamConfig.userID = [LocalUserComponent userModel].uid;
    self.mixedStreamConfig.backgroundColor = @"#0D0B53";
    // Set mix SEI
    NSString *json = [self getSEIJsonWithMixStatus:RTCMixStatusSingleLive];
    self.mixedStreamConfig.userConfigExtraInfo = json;
    // Set mix Regions
    LiveUserModel *host = params.host;
    if (!host || host.uid.length == 0) {
        VOLogE(VOInteractiveLive, @"startPushMixStreamToCDN: host is nil/invalid. roomID=%@ currentUID=%@",
               params.rtcRoomId ?: @"", [LocalUserComponent userModel].uid ?: @"");
        return;
    }

    NSArray *regions = [self getRegionWithUserList:@[host]
                                         mixStatus:RTCMixStatusSingleLive
                                         rtcRoomId:params.rtcRoomId
                                             width:params.width
                                            height:params.height];
    self.mixedStreamConfig.regions = regions;
    self.mixedStreamConfig.layoutMode = ByteRTCStreamLayoutModeCustom;
    [self.rtcEngineKit startPushMixedStream:kMixedStreamTaskId withPushTargetConfig:self.mixedStreamPushConfig withMixedConfig:self.mixedStreamConfig];
}

- (void)updatePushMixedStreamToCDN:(NSArray<LiveUserModel *> *)userList
                         mixStatus:(RTCMixStatus)mixStatus
                         rtcRoomId:(NSString *)rtcRoomId {
    VOLogI(VOInteractiveLive,@"aaa updateTranscodingLayout %ld status %ld", userList.count, mixStatus);
    if (!userList.count) {
        return;
    }
    // Update the merge layout
    // Set mix SEI
    NSString *json = [self getSEIJsonWithMixStatus:mixStatus];
    self.mixedStreamConfig.userConfigExtraInfo = json;
    self.mixedStreamConfig.regions = [self getRegionWithUserList:userList
                                                                    mixStatus:mixStatus
                                                                    rtcRoomId:rtcRoomId
                                                                        width:self.mixedStreamConfig.videoConfig.width
                                                                       height:self.mixedStreamConfig.videoConfig.height];
    [self.rtcEngineKit updatePushMixedStream:kMixedStreamTaskId withPushTargetConfig:self.mixedStreamPushConfig withMixedConfig:self.mixedStreamConfig];
}

- (void)stopPushStreamToCDN {
    // Stop span the room retweet stream
    [[LiveRTCManager shareRtc] stopForwardStreamToRooms];
    [self.rtcEngineKit stopPushMixedStream:kMixedStreamTaskId withPushTargetType:ByteRTCMixedStreamPushTargetTypeToCDN];
}

#pragma mark - Private Action
- (NSString *)getSEIJsonWithMixStatus:(RTCMixStatus)mixStatus {
    NSDictionary *dic = @{LiveSEIKEY: @(mixStatus)};
    NSString *json = [dic yy_modelToJSONString];
    return json;
}

- (NSArray *)getRegionWithUserList:(NSArray<LiveUserModel *> *)userList
                         mixStatus:(RTCMixStatus)mixStatus
                         rtcRoomId:(NSString *)rtcRoomId
                             width:(NSInteger)videoWidth
                            height:(NSInteger)videoHeight{
    NSInteger audienceIndex = 0;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    for (int i = 0; i < userList.count; i++) {
        LiveUserModel *userModel = userList[i];
        ByteRTCMixedStreamLayoutRegionConfig *region = [[ByteRTCMixedStreamLayoutRegionConfig alloc] init];
        region.userID = userModel.uid;
        region.roomID = rtcRoomId;
        region.isLocalUser = [userModel.uid isEqualToString:[LocalUserComponent userModel].uid] ? YES : NO;
        region.renderMode = ByteRTCMixedStreamRenderModeHidden;
        switch (mixStatus) {
            case RTCMixStatusSingleLive: {
                // Single anchor layout
                region.locationX = 0.0;
                region.locationY = 0.0;
                region.width = videoWidth;
                region.height = videoHeight;
                region.zOrder = 1;
                region.alpha = 1.0;
            } break;

            case RTCMixStatusPK: {
                // Make Co-host layout
                if (region.isLocalUser) {
                    region.locationX = 0.0;
                    region.locationY = 0.25 * videoHeight;
                    region.width = 0.5 * videoWidth;
                    region.height = 0.5 * videoHeight;
                    region.zOrder = 0;
                    region.alpha = 1.0;
                } else {
                    region.locationX = 0.5 * videoWidth;
                    region.locationY = 0.25 * videoHeight;
                    region.width = 0.5 * videoWidth;
                    region.height = 0.5 * videoHeight;
                    region.zOrder = 0;
                    region.alpha = 1.0;
                }
            } break;

            case RTCMixStatusAddGuestsTwo: {
                // Make Guests layout
                if (region.isLocalUser) {
                    region.locationX = 0.0;
                    region.locationY = 0.0;
                    region.width = videoWidth;
                    region.height = videoHeight;
                    region.zOrder = 1;
                    region.alpha = 1.0;
                } else {
                    CGFloat screenW = 375.0;
                    CGFloat screenH = 667.0;
                    CGFloat itemHeight = 120.0;
                    CGFloat itemSpace = 6.0;
                    CGFloat itemRightSpace = 12;
                    CGFloat itemTopSpace = screenH - 23 - itemHeight;
                    NSInteger index = audienceIndex++;
                    CGFloat regionHeight = itemHeight / screenH;
                    CGFloat regionWidth = regionHeight * screenH / screenW;
                    CGFloat regionY = (itemTopSpace - (itemHeight + itemSpace) * index) / screenH;
                    CGFloat regionX = 1 - (regionHeight * screenH + itemRightSpace) / screenW;

                    region.locationX = regionX * videoWidth;
                    region.locationY = regionY * videoHeight;
                    region.width = regionWidth * videoWidth;
                    region.height = regionHeight * videoHeight;
                    region.zOrder = 2;
                    region.alpha = 1.0;
                    //                    region.cornerRadius = 4 / screenW;
                }
            } break;

            case RTCMixStatusAddGuestsMulti: {
                // Make Guests layout
                CGFloat screenW = 375.0;
                CGFloat screenH = 667.0;
                NSInteger maxItemNumber = 6;
                CGFloat itemSpace = 2.0;
                CGFloat itemHeight = (screenH - ((maxItemNumber - 1) * itemSpace)) / 6;
                CGFloat itemRightSpace = 0;
                if (region.isLocalUser) {
                    region.locationX = 0.0;
                    region.locationY = 0.0;
                    region.width = (1.0 - ((itemSpace + itemHeight) / screenW)) * videoWidth;
                    region.height = videoHeight;
                    region.zOrder = 1;
                    region.alpha = 1.0;
                } else {
                    NSInteger index = audienceIndex++;
                    CGFloat itemTopSpace = (itemHeight + itemSpace) * index;
                    CGFloat regionHeight = itemHeight / screenH;
                    CGFloat regionWidth = regionHeight * screenH / screenW;
                    CGFloat regionY = itemTopSpace / screenH;
                    CGFloat regionX = 1 - (regionHeight * screenH + itemRightSpace) / screenW;

                    region.locationX = regionX * videoWidth;
                    region.locationY = regionY * videoHeight;
                    region.width = regionWidth * videoWidth;
                    region.height = regionHeight * videoHeight;
                    region.zOrder = 2;
                    region.alpha = 1.0;
                }
            } break;

            default:
                break;
        }
        [list addObject:region];
    }
    return [list copy];
}

#pragma mark - Getter

#pragma mark - BaseRTCManagerMixedStreamDelegate
- (void)rtcEngine:(ByteRTCEngine *)engine onMixedStreamEvent:(ByteRTCMixedStreamTaskEvent)event withMixedStreamInfo:(ByteRTCMixedStreamTaskInfo *)info withErrorCode:(ByteRTCMixedStreamTaskErrorCode)errorCode {
    dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
        if ([self.delegate respondsToSelector:@selector(mixingEvent:taskId:error:mixType:)]) {
            [self.delegate mixingEvent:event taskId:info.taskId error:errorCode mixType:info.pushTargetType];
        }
    });
}

@end
