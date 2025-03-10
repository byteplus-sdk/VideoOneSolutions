// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BeautyHairColorCell.h"
#import "EffectCommon.h"
#import <Masonry/Masonry.h>

@interface BeautyHairColorCell ()

@end

@implementation BeautyHairColorCell

@synthesize vc = _vc;

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    [self displayContentController:self.vc];
}

- (void)onClose {
//    [self.colorVc onClose];
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
- (ColorFaceBeautyViewController *)vc {
    if (!_vc) {
        _vc = [ColorFaceBeautyViewController new];
    }
    return _vc;
}


@end
