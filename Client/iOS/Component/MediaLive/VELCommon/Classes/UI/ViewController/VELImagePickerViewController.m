// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELImagePickerViewController.h"
#import <Masonry/Masonry.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <MediaLive/VELCommon.h>
#import <ToolKit/Localizator.h>
#import "VELUIToast.h"
static BOOL __IsFirstShowPicker__ = YES;
@interface VELImagePickerViewController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) PHPickerViewController *phImagePicker API_AVAILABLE(ios(14));
@property(nonatomic, copy) void (^completionBlock)(VELImagePickerViewController *vc, NSArray <UIImage *>* images);
@end

@implementation VELImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.showNavigationBar = NO;
    if (@available(iOS 14.0, *)) {
        [self setupImagePickerViewController];
    } else {
        if (__IsFirstShowPicker__) {
            [VELUIToast showLoading:LocalizedStringFromBundle(@"medialive_loading", @"MediaLive") inView:self.view];
        } else {
            [self setupImagePickerViewController];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (@available(iOS 14.0, *)) {
    } else {
        if (__IsFirstShowPicker__ && !_imagePicker) {
            [self setupImagePickerViewController];
            __IsFirstShowPicker__ = NO;
        }
    }
}

- (void)setupImagePickerViewController {
    if (@available(iOS 14.0, *)) {
        PHPickerConfiguration *config = [[PHPickerConfiguration alloc] initWithPhotoLibrary:PHPhotoLibrary.sharedPhotoLibrary];
        config.selectionLimit = 1;
        config.filter = PHPickerFilter.imagesFilter;
        self.phImagePicker = [[PHPickerViewController alloc] initWithConfiguration:config];
        self.phImagePicker.delegate = self;
        [self bdl_addViewController:self.phImagePicker];
    } else {
        [self bdl_addViewController:self.imagePicker];
    }
}

- (void)bdl_addViewController:(UIViewController *)vc {
    [vc willMoveToParentViewController:self];
    [self addChildViewController:vc];
    [self.view addSubview:vc.view];
    [vc.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.view);
    }];
    [vc didMoveToParentViewController:self];
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController == _imagePicker) {
        [VELUIToast hideAllLoadingInView:self.view animated:YES];
    }
}

+ (VELImagePickerViewController *)showFromVC:(nullable UIViewController *)vc
                                  completion:(void (^)(VELImagePickerViewController *vc, NSArray <UIImage *>* images))completion {
    vc = vc ?: UIApplication.sharedApplication.keyWindow.rootViewController;
    VELImagePickerViewController *pickerVc = [[VELImagePickerViewController alloc] init];
    pickerVc.completionBlock = completion;
    if (![vc.presentedViewController isKindOfClass:VELImagePickerViewController.class]) {
        [vc presentViewController:pickerVc animated:YES completion:nil];
    }
    return pickerVc;
}

- (void)hide {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.completionBlock) {
        self.completionBlock(self, nil);
    }
    [self hide];
}

- (void)requestAssetAndCallBack:(PHAsset *)asset {
    if (asset == nil || ![asset isKindOfClass:PHAsset.class]) {
        [self callCompletionWithFile:nil type:nil];
        return;
    }
    PHImageRequestOptions *phImageRequestOptions = [[PHImageRequestOptions alloc] init];
    __weak __typeof__(self)weakSelf = self;
    [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                      options:phImageRequestOptions
                                                resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (imageData != nil) {
            NSString *tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:imageData.vel_md5String];
            NSString *extension = [dataUTI componentsSeparatedByString:@"."].lastObject ?: @"jpeg";
            tmpFilePath = [tmpFilePath stringByAppendingPathExtension:extension];
            [imageData writeToFile:tmpFilePath atomically:YES];
            [self callCompletionWithFile:tmpFilePath type:dataUTI ?: info[@"PHImageFileUTIKey"]];
        } else {
            [self callCompletionWithFile:nil type:nil];
        }
    }];
}

- (void)checkPotoLibraryPermission:(void(^)(BOOL granted))completion {
    if (!completion) return;
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusNotDetermined) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            completion(status == PHAuthorizationStatusAuthorized);
        }];
    }
    else {
        completion(status == PHAuthorizationStatusAuthorized);
    }
}

- (void)requestAssetWithAssetUrl:(NSURL *)imageAssetUrl API_DEPRECATED("Will be removed in a future release", ios(8, 11), tvos(8, 11)) {
    if (imageAssetUrl == nil || ![imageAssetUrl isKindOfClass:NSURL.class]) {
        [self callCompletionWithFile:nil type:nil];
        return;
    }
    __weak __typeof__(self)weakSelf = self;
    [self checkPotoLibraryPermission:^(BOOL granted) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (!granted) {
            [self callCompletionWithFile:nil type:nil];
            return;
        }
        PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[imageAssetUrl] options:nil];
        PHAsset *asset = [result firstObject];
        [self requestAssetAndCallBack:asset];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    [self runSyncOnMainQueue:^{
        [VELUIToast showLoading:nil inView:self.view];
    }];
    if (@available(iOS 11.0, *)) {
        PHAsset *asset = info[UIImagePickerControllerPHAsset];
        if (asset != nil && [asset isKindOfClass:PHAsset.class]) {
            [self requestAssetAndCallBack:asset];
        } else {
            NSURL *url = info[UIImagePickerControllerImageURL];
            [self callCompletionWithFile:url.path type:info[UIImagePickerControllerMediaType]];
        }
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        NSURL *imageAssetUrl = [info objectForKey:UIImagePickerControllerReferenceURL];
        [self requestAssetWithAssetUrl:imageAssetUrl];
#pragma clang diagnostic pop
    }
}

- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results API_AVAILABLE(ios(14)) {
    PHPickerResult *result = results.firstObject;
    if (result.itemProvider == nil) {
        [self callCompletionWithFile:nil type:nil];
        return;
    }
    
    NSString *fileName = result.itemProvider.suggestedName;
    NSString *typeIdentifier = result.itemProvider.registeredTypeIdentifiers.firstObject;
    for (NSString *identifier in result.itemProvider.registeredTypeIdentifiers) {
        /// first for gif
        if ([identifier.lowercaseString containsString:@"gif"]) {
            typeIdentifier = identifier;
            break;
        }
    }
    [self runSyncOnMainQueue:^{
        [VELUIToast showLoading:nil inView:self.view];
    }];
    __weak __typeof__(self)weakSelf = self;
    [result.itemProvider loadDataRepresentationForTypeIdentifier:typeIdentifier
                                               completionHandler:^(NSData * _Nullable data, NSError * _Nullable error) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (data != nil) {
            NSString *tmpFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName ?: data.vel_md5String];
            NSString *extension = [typeIdentifier componentsSeparatedByString:@"."].lastObject ?: @"jpeg";
            tmpFilePath = [tmpFilePath stringByAppendingPathExtension:extension];
            [data writeToFile:tmpFilePath atomically:YES];
            [self callCompletionWithFile:tmpFilePath type:typeIdentifier];
        } else {
            [self callCompletionWithFile:nil type:nil];
        }
        [self runSyncOnMainQueue:^{
            [VELUIToast hideAllLoadingInView:self.view animated:YES];
        }];
    }];
}

- (void)callCompletionWithFile:(NSString *)filePath type:(NSString *)type {
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:filePath];
    [self runSyncOnMainQueue:^{
        [VELUIToast hideAllLoadingInView:self.view animated:YES];
        if (image) {
            if (self.completionBlock) {
                self.completionBlock(self, @[image]);
            }
        } else {
            [VELUIToast showLoading:LocalizedStringFromBundle(@"medialive_image_picker_error", @"MediaLive") inView:self.view];
            if (self.completionBlock) {
                self.completionBlock(self, nil);
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (void)runSyncOnMainQueue:(dispatch_block_t)block {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _imagePicker.allowsEditing = NO;
        /// from : SDImageIOAnimatedCoderInternal.h
        _imagePicker.mediaTypes = @[@"public.heic",
                                    @"public.heif",
                                    @"public.heics",
                                    @"org.webmproject.webp",
                                    @"public.image",
                                    @"public.jpeg",
                                    @"public.png",
                                    @"public.svg-image",
                                    @"com.compuserve.gif",
                                    @"public.camera-raw-image"];
    }
    return _imagePicker;
}
@end
