// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELQRScanViewController.h"
#import <MediaLive/VELCommon.h>
#import <AVFoundation/AVFoundation.h>
#import <ToolKit/Localizator.h>
@interface VELQRMaskView : UIView
@property (nonatomic, assign) CGRect qrRect;
@end

@implementation VELQRMaskView

- (void)startAnimating {
    
}

- (void)stopAnimation {
    
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetShouldAntialias(context, true);
    CGContextClearRect(context, rect);
    UIBezierPath *scanPath = [UIBezierPath bezierPathWithRect:self.qrRect];
    [scanPath setLineWidth:3];
    [[UIColor greenColor] setStroke];
    [scanPath stroke];
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:rect];
    [path appendPath:[scanPath bezierPathByReversingPath]];
    [[UIColor blackColor] setFill];
    [path fillWithBlendMode:(kCGBlendModeNormal) alpha:0.5];
}

@end
@interface VELQRScanViewController () <AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate>
@property (nonatomic, strong) VELQRMaskView *maskView;
@property (nonatomic, strong) AVCaptureDeviceInput *inputDevice;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (atomic, assign) BOOL isRunning;
@property(nonatomic, copy) void (^completionBlock)(VELQRScanViewController *vc, NSString *result);
@property (nonatomic, assign) CGRect scanRectOfInterest;
@property (atomic, assign) float brightness;
@property (nonatomic, strong) VELUIButton *torchBtn;
@property (atomic, strong) NSDate *startDate;
@property (nonatomic, copy) NSString *qrString;
@end

@implementation VELQRScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    self.scanRectOfInterest = CGRectMake(0.33, 0.19, 0.35, 0.62);
    [self.navigationBar onlyShowLeftBtn];
    self.navigationBar.backgroundColor = UIColor.clearColor;
    [self.navigationBar.leftButton setImage:VELUIImageMake(@"ic_close_white") forState:(UIControlStateNormal)];
    __weak __typeof__(self)weakSelf = self;
    [self requestCameraAuthorization:^(BOOL granted) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (granted) {
            [self setupSession];
            [self startCapture];
        } else {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_camera_privilege_ask", @"MediaLive") detailText:@""];
        }
    }];
    [self setupMaskView];
    [self setupTorchBtn];
}

- (void)dealloc {
    [self stopCapture];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.previewLayer.frame = self.view.bounds;
    self.maskView.frame = self.view.bounds;
    CGSize size = CGSizeMake(self.view.bounds.size.width * 0.7, self.view.bounds.size.width * 0.7);
    CGFloat x = (self.view.bounds.size.width - size.width) * 0.5;
    CGFloat y = (self.view.bounds.size.height - size.height) * 0.5;
    CGRect rect = CGRectMake(x, y, size.width, size.height);
    self.maskView.qrRect = rect;
    [self.torchBtn sizeToFit];
    CGFloat width = self.torchBtn.bounds.size.width;
    CGFloat height = self.torchBtn.bounds.size.height;
    x = (self.view.frame.size.width - width) * 0.5;
    y = (self.view.frame.size.height - height - 80);
    self.torchBtn.frame = CGRectMake(x, y, self.torchBtn.bounds.size.width, self.torchBtn.bounds.size.height);
}

- (void)setupMaskView {
    self.maskView = [[VELQRMaskView alloc] initWithFrame:self.view.bounds];
    self.maskView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.maskView];
}

- (void)setupTorchBtn {
    self.torchBtn = [[VELUIButton alloc] init];
    [self.torchBtn setTitle:LocalizedStringFromBundle(@"medialive_tap_shine", @"MediaLive") forState:(UIControlStateNormal)];
    [self.torchBtn setTitle:LocalizedStringFromBundle(@"medialive_tap_close", @"MediaLive") forState:(UIControlStateSelected)];
    [self.torchBtn setTitleColor:UIColor.whiteColor forState:(UIControlStateNormal)];
    [self.torchBtn setImage:VELUIImageMake(@"ic_torch") forState:(UIControlStateNormal)];
    [self.torchBtn setImage:VELUIImageMake(@"ic_torch_off") forState:(UIControlStateSelected)];
    self.torchBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.torchBtn.imagePosition = VELUIButtonImagePositionTop;
    [self.view addSubview:self.torchBtn];
    self.torchBtn.hidden = YES;
    [self.torchBtn addTarget:self action:@selector(torchBtnClick) forControlEvents:(UIControlEventTouchUpInside)];
    
    CGFloat width = self.torchBtn.bounds.size.width;
    CGFloat height = self.torchBtn.bounds.size.height;
    CGFloat x = (self.view.frame.size.width - width) * 0.5;
    CGFloat y = (self.view.frame.size.height - height - 80);
    self.torchBtn.frame = CGRectMake(x, y, self.torchBtn.bounds.size.width, self.torchBtn.bounds.size.height);
}

- (void)torchBtnClick {
    AVCaptureTorchMode model = self.torchBtn.isSelected ? AVCaptureTorchModeOff : AVCaptureTorchModeOn;
    if ([self.device isTorchModeSupported:(model)]) {
        if ([self.device lockForConfiguration:nil]) {
            [self.device setTorchMode:model];
            [self.torchBtn setSelected:!self.torchBtn.isSelected];
            [self.device unlockForConfiguration];
        }
    }
}

- (void)setupSession {
    if (!self.session) {
        self.session = [[AVCaptureSession alloc] init];
        [self.session setSessionPreset:AVCaptureSessionPresetHigh];
        self.previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
        self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.previewLayer.frame = self.view.bounds;
        [self.view.layer insertSublayer:self.previewLayer atIndex:0];
    }
}

- (void)startCapture {
    if (self.isRunning) {
        return;
    }
    self.isRunning = YES;
    AVCaptureDevice *device = [self cameraDeviceWithPosition:(AVCaptureDevicePositionBack)];
    if (device == nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_camera_init_error", @"MediaLive") detailText:@""];
        self.isRunning = NO;
        return;
    }
    self.device = device;
    NSError *error = nil;
    self.inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (self.inputDevice == nil || error != nil) {
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_camera_init_error", @"MediaLive") detailText:@""];
        self.isRunning = NO;
        return;
    }
    self.metadataOutput = [[AVCaptureMetadataOutput alloc] init];
    
    [self.session beginConfiguration];
    if (self.inputDevice && [self.session canAddInput:self.inputDevice]) {
        [self.session addInput:self.inputDevice];
    } else {
        [self.session commitConfiguration];
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_camera_init_error", @"MediaLive") detailText:@""];
        self.isRunning = NO;
        return;
    }
    NSArray <AVMetadataObjectType>*qrTypes = @[AVMetadataObjectTypeQRCode, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    if (self.metadataOutput && [self.session canAddOutput:self.metadataOutput]) {
        [self.session addOutput:self.metadataOutput];
        NSArray<AVMetadataObjectType>* metaObjects = [self.metadataOutput availableMetadataObjectTypes];
        NSMutableArray *metaTypes = [NSMutableArray arrayWithCapacity:qrTypes.count];
        for (AVMetadataObjectType type in qrTypes) {
            if([metaObjects containsObject:type]) {
                [metaTypes addObject:type];
            }
        }
        self.metadataOutput.metadataObjectTypes = metaTypes;
        self.metadataOutput.rectOfInterest = self.scanRectOfInterest;
        [self.metadataOutput setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    } else {
        [self.session commitConfiguration];
        [VELUIToast showText:LocalizedStringFromBundle(@"medialive_camera_init_error", @"MediaLive") detailText:@""];
        self.isRunning = NO;
        return;
    }
    self.videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    if (self.videoOutput && [self.session canAddOutput:self.videoOutput]) {
        [self.session addOutput:self.videoOutput];
        [self.videoOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(0, 0)];
    }
    
    [self.session commitConfiguration];
    self.startDate = NSDate.date;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.session startRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.maskView startAnimating];
        });
    });
}

- (void)stopCapture {
    if (!self.isRunning && !self.session.isRunning) {
        return;
    }
    self.isRunning = NO;
    if (self.session.isRunning) {
        [self.session stopRunning];
    }
    [self.session beginConfiguration];
    if (self.inputDevice != nil) {
        [self.session removeInput:self.inputDevice];
        self.inputDevice = nil;
    }
    if (self.metadataOutput != nil) {
        [self.session removeOutput:self.metadataOutput];
        self.metadataOutput = nil;
    }
    [self.session commitConfiguration];
}

- (AVCaptureDevice *)cameraDeviceWithPosition:(AVCaptureDevicePosition)position {
    AVCaptureDevice *deviceRet = nil;
    if (position != AVCaptureDevicePositionUnspecified) {
        NSArray <AVCaptureDevice *>* devices = nil;
        if (@available(iOS 10.0, *)) {
            AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
            devices = session.devices;
        } else {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
#pragma clang diagnostic pop
        }
        for (AVCaptureDevice *device in devices) {
            if ([device position] == position) {
                deviceRet = device;
            }
        }
    }
    return deviceRet;
}

+ (VELQRScanViewController *)showFromVC:(UIViewController *)vc completion:(void (^)(VELQRScanViewController *vc, NSString * _Nonnull))completion {
    vc = vc ?: UIApplication.sharedApplication.keyWindow.rootViewController;
    VELQRScanViewController *qrVc = [[VELQRScanViewController alloc] init];
    qrVc.completionBlock = completion;
    if (![vc.presentedViewController isKindOfClass:VELQRScanViewController.class]) {
        [vc presentViewController:qrVc animated:YES completion:nil];
    }
    return qrVc;
}

- (void)hide {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    if (metadataObjects.count > 0) {
        NSString *str = nil;
        for (AVMetadataMachineReadableCodeObject *obj in metadataObjects) {
            if ([obj isKindOfClass:AVMetadataMachineReadableCodeObject.class]) {
                str = obj.stringValue;
                break;
            }
        }
        vel_sync_main_queue(^{
            if ([self.qrString isEqualToString:str]) {
                return;
            }
            self.qrString = str;
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
                [generator prepare];
                [generator impactOccurred];
            }
            if (self.completionBlock) {
                self.completionBlock(self, self.qrString);
            }
        });
    }
}

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    if (metadataDict != NULL) {
        CFDictionaryRef exifProperty =  CFDictionaryGetValue(metadataDict, kCGImagePropertyExifDictionary);
        if (exifProperty == NULL) {
            return;
        }
        CFNumberRef exifBrightness = CFDictionaryGetValue(exifProperty, kCGImagePropertyExifBrightnessValue);
        if (exifBrightness == NULL) {
            CFRelease(exifProperty);
            return;
        }
        float brightness = 0;
        CFNumberGetValue(exifBrightness, kCFNumberFloatType, &brightness);
        if ([NSDate.date timeIntervalSinceDate:self.startDate] < 3) {
            return;
        }
        if (brightness < 0 && self.brightness < 0) {
            return;
        }
        if (brightness > 0 && self.brightness > 0) {
            return;
        }
        self.brightness = brightness;
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.device isTorchModeSupported:(AVCaptureTorchModeOn)]) {
                [self.torchBtn setSelected:(self.device.torchMode == AVCaptureTorchModeOn)];
                self.torchBtn.hidden = self.brightness > 0 && !self.torchBtn.isSelected;
            }
        });
    }
    CFRelease(metadataDict);
}

- (void)requestCameraAuthorization:(void (^)(BOOL granted))handler {
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(granted);
            });
        }];
    } else if (authStatus == AVAuthorizationStatusAuthorized) {
        handler(YES);
    } else {
        handler(NO);
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
- (CGRect)convertToMetadataOutputRectOfInterestForRect:(CGRect)cropRect {
    return [self convertMetadataRectOfInterest:self.session.sessionPreset
                                  videoGravity:self.previewLayer.videoGravity
                                       forView:self.view
                                      cropRect:cropRect];
}

- (CGRect)convertMetadataRectOfInterest:(AVCaptureSessionPreset)sessionPreset
                         videoGravity:(AVLayerVideoGravity)videoGravity
                              forView:(UIView *)view
                             cropRect:(CGRect)cropRect {
    CGSize size = view.bounds.size;
    CGFloat viewScale = size.height / size.width;
    CGFloat outputScale = 1280.0 / 720.0;
    
    if ([sessionPreset isEqualToString:AVCaptureSessionPreset1920x1080]
        || [sessionPreset isEqualToString:AVCaptureSessionPresetHigh]
        || [sessionPreset isEqualToString:AVCaptureSessionPresetInputPriority]) {
        outputScale = 1920.0 / 1080.0;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset1280x720]
               || [sessionPreset isEqualToString:AVCaptureSessionPresetiFrame1280x720]) {
        outputScale = 1280.0 / 720.0;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPresetiFrame960x540]) {
        outputScale = 960.0 / 540.0;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPresetMedium]) {
        outputScale = 480.0 /360.0;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPreset352x288]) {
        outputScale = 352.0 / 288.0;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPresetLow]) {
        outputScale = 192.0 / 144.0;
    } else if ([sessionPreset isEqualToString:AVCaptureSessionPresetPhoto]) {
        outputScale = 4.0 / 3.0;
    } else  {
        if (@available(iOS 9.0, *)) {
            if ([sessionPreset isEqualToString:AVCaptureSessionPreset3840x2160]) {
                outputScale = 3840.0 / 2160.0;
            }
        }
    }
    CGRect rectOfInterest = CGRectMake(0, 0, 1, 1);
    if ([videoGravity isEqualToString:AVLayerVideoGravityResize]) {
        rectOfInterest = CGRectMake((cropRect.origin.y) / size.height,
                                    (size.width - (cropRect.size.width+cropRect.origin.x)) / size.width,
                                    cropRect.size.height / size.height,
                                    cropRect.size.width / size.width);
    } else if ([videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewScale < outputScale) {
            CGFloat fixHeight = size.width * outputScale;
            CGFloat fixPadding = (fixHeight - size.height) * 0.5;
            rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding) / fixHeight,
                                        (size.width - (cropRect.size.width + cropRect.origin.x)) / size.width,
                                        cropRect.size.height / fixHeight,
                                        cropRect.size.width / size.width);
        } else {
            CGFloat fixWidth = size.height * (1 / outputScale);
            CGFloat fixPadding = (fixWidth - size.width) * 0.5;
            rectOfInterest = CGRectMake(cropRect.origin.y / size.height,
                                        (size.width - (cropRect.size.width + cropRect.origin.x) + fixPadding) / fixWidth,
                                        cropRect.size.height / size.height,
                                        cropRect.size.width / fixWidth);
        }
    } else if ([videoGravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewScale > outputScale) {
            CGFloat fixHeight = size.width * outputScale;
            CGFloat fixPadding = (fixHeight - size.height) * 0.5;
            rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding) / fixHeight,
                                        (size.width - (cropRect.size.width + cropRect.origin.x)) / size.width,
                                        cropRect.size.height / fixHeight,
                                        cropRect.size.width / size.width);
        } else {
            CGFloat fixWidth = size.height * (1 / outputScale);
            CGFloat fixPadding = (fixWidth - size.width) * 0.5;
            rectOfInterest = CGRectMake(cropRect.origin.y / size.height,
                                        (size.width - (cropRect.size.width + cropRect.origin.x) + fixPadding) / fixWidth,
                                        cropRect.size.height / size.height,
                                        cropRect.size.width / fixWidth);
        }
    }
    NSLog(@"%@", NSStringFromCGRect(rectOfInterest));
    return rectOfInterest;
}
@end
