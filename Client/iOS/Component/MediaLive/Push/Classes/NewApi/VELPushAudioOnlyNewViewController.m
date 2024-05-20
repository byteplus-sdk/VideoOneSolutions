// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushAudioOnlyNewViewController.h"
#import <ToolKit/Localizator.h>
@interface VELPushAudioOnlyNewViewController ()
@property (nonatomic, strong) VELUIButton *imageButton;
@property (nonatomic, strong) UIImage *bgImage;
@end

@implementation VELPushAudioOnlyNewViewController

- (void)viewDidLoad {
    self.config.enableAudioOnly = YES;
    [super viewDidLoad];
    [self setupPushImageView];
}
- (void)applicationWillResignActive {
}

- (void)applicationDidBecomeActive {
}

- (void)startVideoCapture {
    [self.pusher startVideoCapture:(VeLiveVideoCaptureDummyFrame)];
}

- (void)stopVideoCapture {
    [self.pusher stopVideoCapture];
}
- (void)setupUIForNotStreaming {
    [super setupUIForNotStreaming];
    self.bgImage = nil;
}

- (void)deleteCurrentImage {
    self.bgImage = nil;
    [self.pusher switchVideoCapture:(VeLiveVideoCaptureDummyFrame)];
}

- (void)replaceCurrentImage:(UIImage *)image {
    self.bgImage = image;
    [self.pusher updateCustomImage:image];
    [self.pusher switchVideoCapture:(VeLiveVideoCaptureCustomImage)];
}

- (void)setupPushImageView {
    [self.controlContainerView insertSubview:self.imageButton atIndex:0];
    [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.controlContainerView);
    }];
}

- (void)imageButtonClick {
    if (self.bgImage != nil) {
        [self showActionAlert];
    } else {
        [self showPickImage];
    }
}

- (void)showActionAlert {
    __weak __typeof__(self)weakSelf = self;
    VELAlertAction *choseImage = [VELAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_replace_pic", @"MediaLive") block:^(UIAlertAction * _Nonnull action) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self showPickImage];
    }];
    VELAlertAction *deleteImage = [VELAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_remove_pic", @"MediaLive") block:^(UIAlertAction * _Nonnull action) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self deleteCurrentImage];
    }];
    [[VELAlertManager shareManager] showWithMessage:LocalizedStringFromBundle(@"medialive_choose_pic", @"MediaLive") actions:@[choseImage, deleteImage]];
}

- (void)showPickImage {
    __weak __typeof__(self)weakSelf = self;
    [VELImagePickerViewController showFromVC:self completion:^(VELImagePickerViewController * _Nonnull vc, NSArray<UIImage *> * _Nonnull images) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (images.count > 0) {
            [self replaceCurrentImage:images.firstObject];
        }
    }];
}

- (VELUIButton *)imageButton {
    if (!_imageButton) {
        _imageButton = [[VELUIButton alloc] init];
        _imageButton.backgroundColor = [UIColor clearColor];
        [_imageButton setTitle:LocalizedStringFromBundle(@"medialive_add_replace_remove", @"MediaLive") forState:(UIControlStateNormal)];
        [_imageButton setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
        _imageButton.titleLabel.font = [UIFont systemFontOfSize:18];
        [_imageButton addTarget:self action:@selector(imageButtonClick) forControlEvents:(UIControlEventTouchUpInside)];
    }
    return _imageButton;
}
@end

