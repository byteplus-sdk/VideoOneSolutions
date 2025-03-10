// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaPlayerToastModule.h"
#import "MDPlayerContextKeyDefine.h"
#import "MDPlayerActionViewInterface.h"
#import <Masonry/Masonry.h>
#import "MDVideoPlayback.h"
#import "MDDramaFeedInfo.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "MDPlayerUtility.h"
#import "BTDMacros.h"


@interface MiniDramaPlayerToastModule ()

@property (nonatomic, weak) id<MDVideoPlayback> playerInterface;
@property (nonatomic, weak) id<MDPlayerActionViewInterface> actionViewInterface;
@property (nonatomic, weak) MDDramaFeedInfo *dramaVideoInfo;

@end

@implementation MiniDramaPlayerToastModule

MDPlayerContextDILink(playerInterface, MDVideoPlayback, self.context);
MDPlayerContextDILink(actionViewInterface, MDPlayerActionViewInterface, self.context);

#pragma mark - Life Cycle

- (void)moduleDidLoad {
    [super moduleDidLoad];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    [self.context addKey:MDPlayerContextKeyMiniDramaDataModelChanged withObserver:self handler:^(MDDramaFeedInfo *dramaVideoInfo, NSString * _Nullable key) {
        @strongify(self);
        self.dramaVideoInfo = dramaVideoInfo;
    }];
    
    [self.context addKey:MDPlayerContextKeyShowToastModule withObserver:self handler:^(NSString *message, NSString * _Nullable key) {
        @strongify(self);
        if (message) {
            [self showToast:message];
        }
    }];
}

- (void)controlViewTemplateDidUpdate {
    [super controlViewTemplateDidUpdate];
}

- (void)configuratoinCustomView {
    
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
}

- (void)showToast:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:UIApplication.sharedApplication.keyWindow animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = message;
    hud.offset = CGPointMake(0, 50);
    [hud hideAnimated:YES afterDelay:1.5];
}

@end
