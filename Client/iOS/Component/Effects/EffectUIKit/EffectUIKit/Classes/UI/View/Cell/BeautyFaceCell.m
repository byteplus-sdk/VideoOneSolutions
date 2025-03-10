// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BeautyFaceCell.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"
@interface EffectUIKitFaceBeautyViewCell ()

@end

@implementation EffectUIKitFaceBeautyViewCell

@synthesize vc = _vc;

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self displayContentController:self.vc];
}

- (void)onClose {
//    [self.vc onClose];
}

- (void)displayContentController:(UIViewController *)viewController {
    UIViewController *parent = [EffectCommon topViewControllerForResponder:self.contentView];
    if (viewController.parentViewController != parent
        && viewController.parentViewController != nil) {
        [self hideContentController:viewController];
        [parent addChildViewController:viewController];
    }
    [self.contentView addSubview:viewController.view];
    [viewController didMoveToParentViewController:parent];
    [viewController.view mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)hideContentController:(UIViewController*)content {
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

#pragma mark - getter
- (FaceBeautyViewController *)vc {
    if (!_vc) {
        _vc = [FaceBeautyViewController new];
    }
    return _vc;
}

@end
