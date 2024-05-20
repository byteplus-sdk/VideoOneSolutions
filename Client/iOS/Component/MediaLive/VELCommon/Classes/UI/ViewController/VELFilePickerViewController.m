// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELFilePickerViewController.h"

@interface VELFilePickerViewController () <UIDocumentPickerDelegate>
@property (nonatomic, strong) UIDocumentPickerViewController *pickerVC;
@property (nonatomic, strong) NSArray <NSString *> *fileTypes;
@property (nonatomic, copy) void (^completionBlock)(VELFilePickerViewController *picker, NSArray <NSString *>* files);
@property (nonatomic, strong) NSString *savedDir;
@end

@implementation VELFilePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.showNavigationBar = NO;
    [self setupSavedDir];
    [self vel_addViewController:self.pickerVC];
    
}

- (void)setupSavedDir {
    self.savedDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject
                     stringByAppendingPathComponent:@"file_copy"];
    BOOL isDir = NO;
    if ([NSFileManager.defaultManager fileExistsAtPath:self.savedDir isDirectory:&isDir]
        || !isDir) {
        [NSFileManager.defaultManager createDirectoryAtPath:self.savedDir
                                withIntermediateDirectories:YES
                                                 attributes:nil
                                                      error:nil];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)saveFileAndCallBack:(NSURL *)url {
    NSString *dstFile = [self.savedDir stringByAppendingPathComponent:url.lastPathComponent];
    if ([NSFileManager.defaultManager fileExistsAtPath:dstFile]) {
        [NSFileManager.defaultManager removeItemAtPath:dstFile error:nil];
    }
    BOOL success = [NSFileManager.defaultManager copyItemAtURL:url toURL:[NSURL fileURLWithPath:dstFile] error:nil];
    if (self.completionBlock) {
        self.completionBlock(self, success ? @[dstFile] : @[]);
    }
}

+ (VELFilePickerViewController *)showFromVC:(UIViewController *)vc fileTypes:(nonnull NSArray<NSString *> *)fileTypes completion:(nonnull void (^)(VELFilePickerViewController * _Nonnull, NSArray<NSString *> * _Nonnull))completion {
    vc = vc ?: UIApplication.sharedApplication.keyWindow.rootViewController;
    VELFilePickerViewController *pickerVc = [[VELFilePickerViewController alloc] init];
    pickerVc.completionBlock = completion;
    pickerVc.fileTypes = fileTypes;
    if (![vc.presentedViewController isKindOfClass:VELFilePickerViewController.class]) {
        [vc presentViewController:pickerVc animated:YES completion:nil];
    }
    return pickerVc;
}

- (void)hide {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    [self saveFileAndCallBack:url];
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma clang diagnostic pop
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray<NSURL *> *)urls API_AVAILABLE(ios(11.0)) {
    [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self saveFileAndCallBack:obj];
    }];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller {
    if (self.completionBlock) {
        self.completionBlock(self, @[]);
    }
}

- (UIDocumentPickerViewController *)pickerVC {
    if (!_pickerVC) {
        _pickerVC = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:self.fileTypes
                                                                           inMode:(UIDocumentPickerModeImport)];
        _pickerVC.delegate = self;
        
    }
    return _pickerVC;
}
@end
