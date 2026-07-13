// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushAudioOnlyNewViewController.h"
#import <ToolKit/Localizator.h>
#import "VELPushImageUtils.h"

@interface VELPushAudioOnlyNewViewController ()
@property (nonatomic, strong) VELUIButton *imageButton;
@property (nonatomic, strong) UIImage *bgImage;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger timestamp;
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
    [self.rtcEngine setVideoSourceType:ByteRTCVideoSourceTypeExternal];
    [self startTimer];
}

- (void)stopVideoCapture {
    [self stopTimer];
    [self.rtcEngine stopVideoCapture];
}
- (void)setupUIForNotStreaming {
    [super setupUIForNotStreaming];
    self.bgImage = nil;
}

- (void)deleteCurrentImage {
    self.bgImage = nil;
    [self.imageButton setTitle:LocalizedStringFromBundle(@"medialive_add_replace_remove", @"MediaLive") forState:(UIControlStateNormal)];
}

- (void)replaceCurrentImage:(UIImage *)image {
    self.bgImage = image;
    [self.imageButton setTitle:@"" forState:UIControlStateNormal];
//    [self.imageButton setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)setupPushImageView {
    [self.controlContainerView insertSubview:self.imageButton atIndex:0];
    [self.imageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.controlContainerView);
        make.width.height.mas_equalTo(200);
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

- (void)startTimer {
    [self stopTimer];
    self.timestamp = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0/15.0 target:self selector:@selector(pushExternalFrame) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

- (void)pushExternalFrame {
    if (!self.rtcEngine) {
        return;
    }
    UIImage *image = self.bgImage;
    if (!image) {
        image = [self createBlackImage];
    }
    CVPixelBufferRef pixelBuffer = [self pixelBufferFromCGImage:image.CGImage];
    if (pixelBuffer) {
        ByteRTCVideoFrameData *videoFrame = [[ByteRTCVideoFrameData alloc] init];
        videoFrame.bufferType = ByteRTCVideoBufferTypeCVPixelBuffer;
        videoFrame.cvpixelbuffer = pixelBuffer;
        videoFrame.width = (int)CGImageGetWidth(image.CGImage);
        videoFrame.height = (int)CGImageGetHeight(image.CGImage);
        videoFrame.timestamp = CMTimeMake(self.timestamp++, 15);
        [self.rtcEngine pushExternalVideoFrame:videoFrame];
        CVPixelBufferRelease(pixelBuffer);
    }
}

- (UIImage *)createBlackImage {
    CGSize size = CGSizeMake(self.config.encodeSize.width, self.config.encodeSize.height);
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image {
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);

    NSDictionary *options = @{
        (id)kCVPixelBufferCGImageCompatibilityKey: @YES,
        (id)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES
    };

    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                          width,
                                          height,
                                          kCVPixelFormatType_32BGRA,
                                          (__bridge CFDictionaryRef)options,
                                          &pxbuffer);

    if (status != kCVReturnSuccess || pxbuffer == NULL) {
        return NULL;
    }

    CVPixelBufferLockBaseAddress(pxbuffer, 0);

    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pxbuffer);

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 width,
                                                 height,
                                                 8,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    if (!context) {
        CGColorSpaceRelease(colorSpace);
        CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
        CVPixelBufferRelease(pxbuffer);
        return NULL;
    }

    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);

    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);

    return pxbuffer;
}

@end

