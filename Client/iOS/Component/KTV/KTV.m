//
//  KTV.m
//  KTV
//
//  Created by on 2022/5/9.
//

#import "KTV.h"
#import "KTVRTCManager.h"
#import "JoinRTSParams.h"
#import "KTVRoomListsViewController.h"

@implementation KTV

- (instancetype)init {
    self = [super init];
    if (self) {
        self.bundleName = HomeBundleName;
        self.title = LocalizedString(@"ktv_scenes");
        self.des = LocalizedString(@"ktv_scenes_des");
        self.iconName = @"scene_ktv_bg";
        self.scenesName = @"ktv";
    }
    return self;
}

- (void)enterWithCallback:(void (^)(BOOL result))block {
    [super enterWithCallback:block];
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.scenesName forKey:@"scenes_name"];
    [dic setValue:[LocalUserComponent userModel].loginToken forKey:@"login_token"];
    
    [[ToastComponent shareToastComponent] showLoading];
    __weak __typeof(self) wself = self;
    [JoinRTSParams getJoinRTSParams:[dic copy]
                              block:^(JoinRTSParamsModel *_Nonnull model) {
        [[ToastComponent shareToastComponent] dismiss];
        [wself joinRTS:model block:block];
    }];
}
- (void)joinRTS:(JoinRTSParamsModel * _Nonnull)model
          block:(void (^)(BOOL result))block{
    if (!model) {
        [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"connection_failed")];
        if (block) {
            block(NO);
        }
        return;
    }
    // Connect RTS
    [[KTVRTCManager shareRtc] connect:model.appId
                             RTSToken:model.RTSToken
                            serverUrl:model.serverUrl
                            serverSig:model.serverSignature
                                  bid:model.bid
                                block:^(BOOL result) {
        if (result) {
            KTVRoomListsViewController *next = [[KTVRoomListsViewController alloc] init];
            UIViewController *topVC = [DeviceInforTool topViewController];
            [topVC.navigationController pushViewController:next animated:YES];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"connection_failed")];
        }
        if (block) {
            block(result);
        }
    }];
}


@end
