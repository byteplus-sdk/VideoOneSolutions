// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELFileTool.h"
#import "BuildConfig.h"
#import <objc/runtime.h>
#import "VELFileDownloader.h"
#import <ToolKit/Localizator.h>
static NSString *vel_file_download_baseUrl = nil;

/**
 * You can change the file address below, but comply with the following requirements:
 *  1. the video file needs to be in nv21 format, with a resolution of 480 x 800, 15 fps
 *  2. the audio file needs to be in PCM format, with a sampleRate of 44100, Bit Depth is 16, Dual Channel
 */
static NSString *videoDownloadUrl = @"https://sf16-videoone.ibytedtos.com/obj/bytertc-platfrom-sg/videoone_480_800_15_nv21.yuv";
static NSString *audioDownloadUrl = @"https://sf16-videoone.ibytedtos.com/obj/bytertc-platfrom-sg/videoone_44100_16bit_2ch.pcm";

@implementation VELFileTool
+ (NSString *)downloadBaseUrl {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        vel_file_download_baseUrl = [ServerUrl stringByAppendingString:@"/getPCMFile/"];
    });
    return vel_file_download_baseUrl;
}

+ (VELAudioFileConfig *)getOrCreateAudioFileWithType:(VELAudioFileType)fileType {
    VELAudioFileConfig *config = [[VELAudioFileConfig alloc] init];
    config.fileType = fileType;
    [self findLocalAudioFileForAudioConfig:config];
    return config;
}

+ (VELAudioFileConfig *)getOrCreateAudioFileWithName:(NSString *)fileName {
    VELAudioFileConfig *config = [[VELAudioFileConfig alloc] init];
    config.name = fileName;
    [self findLocalAudioFileForAudioConfig:config];
    return config;
}

+ (void)findLocalAudioFileForAudioConfig:(VELAudioFileConfig *)config {
    NSString *fileName = nil;
    if (VEL_IS_NOT_EMPTY_STRING(config.name)) {
        fileName = config.name;
    }  else {
        NSString *fmt = @"pcm";
        switch (config.fileType) {
            case VELAudioFileType_UnKnown:
                fmt = @"pcm";
                config.fileType = VELAudioFileType_PCM;
            case VELAudioFileType_PCM:
                fmt = @"pcm";
                break;
        }
        fileName = [@"videoone_44100_16bit_2ch" stringByAppendingFormat:@".%@", fmt];
    }
    config.name = fileName;
    
    NSString *bundleFile = [NSString stringWithFormat:@"VELLiveDemo_Push.bundle/%@", fileName];
    NSString *bundleFilePath = [[NSBundle mainBundle] pathForResource:bundleFile ofType:nil];
    NSString *mainBundleFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (VEL_IS_NOT_EMPTY_STRING(bundleFilePath)
        && [NSFileManager.defaultManager fileExistsAtPath:bundleFilePath]) {
        config.path = bundleFilePath;
    } else if (VEL_IS_NOT_EMPTY_STRING(mainBundleFilePath)
               && [NSFileManager.defaultManager fileExistsAtPath:mainBundleFilePath]) {
        config.path = mainBundleFilePath;
    } else if ([VELFileDownloader fileExistWithFileName:fileName]) {
        config.path = [VELFileDownloader filePathWithFileName:fileName];
    }
}


+ (VELVideoFileConfig *)getOrCreateVideoFileWithType:(VELVideoFileType)fileType {
    VELVideoFileConfig *config = [[VELVideoFileConfig alloc] init];
    config.fileType = fileType;
    [self findLocalVideoFileForVideoConfig:config];
    return config;
}

+ (void)findLocalVideoFileForVideoConfig:(VELVideoFileConfig *)config {
    NSString *fileName = nil;
    if (VEL_IS_NOT_EMPTY_STRING(config.name)) {
        fileName = config.name;
    } else {
        NSString *fmt = @"bgra";
        switch (config.fileType) {
            case VELVideoFileType_UnKnown:
                fmt = @"bgra";
                config.fileType = VELVideoFileType_BGRA;
            case VELVideoFileType_BGRA:
                fmt = @"bgra";
                break;
            case VELVideoFileType_NV12:
                fmt = @"nv12";
                break;
            case VELVideoFileType_NV21:
                fmt = @"nv21";
                break;
            case VELVideoFileType_YUV:
                fmt = @"yuv420";
                break;
        }
        fileName = [NSString stringWithFormat:@"videoone_480_800_15_%@.yuv", fmt];
    }
    config.name = fileName;
    
    NSString *bundleFile = [NSString stringWithFormat:@"VELLiveDemo_Push.bundle/%@", fileName];
    NSString *bundleFilePath = [[NSBundle mainBundle] pathForResource:bundleFile ofType:nil];
    NSString *mainBundleFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    if (VEL_IS_NOT_EMPTY_STRING(bundleFilePath)
        && [NSFileManager.defaultManager fileExistsAtPath:bundleFilePath]) {
        config.path = bundleFilePath;
    } else if (VEL_IS_NOT_EMPTY_STRING(mainBundleFilePath)
               && [NSFileManager.defaultManager fileExistsAtPath:mainBundleFilePath]) {
        config.path = mainBundleFilePath;
    } else if ([VELFileDownloader fileExistWithFileName:fileName]) {
        config.path = [VELFileDownloader filePathWithFileName:fileName];
    }
}

+ (void)getAudioFile:(VELAudioFileType)fileType inView:(UIView *)inView completion:(void (^)(VELAudioFileConfig *config))completion {
    VELAudioFileConfig *audioCfg = [[VELAudioFileConfig alloc] init];
    audioCfg.fileType = fileType;
    [self getAudioFileWithConfig:audioCfg inView:inView completion:completion];
}


+ (void)getVideoFile:(VELVideoFileType)fileType inView:(UIView *)inView completion:(void (^)(VELVideoFileConfig *config))completion {
    VELVideoFileConfig *videoCfg = [[VELVideoFileConfig alloc] init];
    videoCfg.fileType = fileType;
    [self getVideoFileWithConfig:videoCfg inView:inView completion:completion];
}

+ (void)getAudioFileWithConfig:(VELAudioFileConfig *)config inView:(UIView *)inView completion:(void (^)(VELAudioFileConfig *config))completion {
    [self findLocalAudioFileForAudioConfig:config];
    if (VEL_IS_NOT_EMPTY_STRING(config.path)
        && [NSFileManager.defaultManager fileExistsAtPath:config.path]) {
        if (completion) {
            completion(config);
        }
    } else {
        __weak __typeof__(self)weakSelf = self;
        [self downloadFile:config.name downloadUrl:audioDownloadUrl inView:inView completion:^(NSString *path, NSError *error) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (error != nil) {
                [self showChoseFileAlertTip:^(BOOL allowed) {
                    if (allowed) {
                        [self selectAudio:config fromVC:inView.vel_topViewController
                               completion:^(VELAudioFileConfig * _Nullable fileConfig, BOOL isCancel) {
                            if (completion) {
                                completion(fileConfig);
                            }
                        }];
                    } else {
                        if (completion) {
                            completion(config);
                        }
                    }
                }];
            } else {
                config.path = path;
                if (completion) {
                    completion(config);
                }
            }
        }];
    }
}

+ (void)getVideoFileWithConfig:(VELVideoFileConfig *)config inView:(UIView *)inView completion:(void (^)(VELVideoFileConfig *config))completion {
    [self findLocalVideoFileForVideoConfig:config];
    
    if (VEL_IS_NOT_EMPTY_STRING(config.path)
        && [NSFileManager.defaultManager fileExistsAtPath:config.path]) {
        if (completion) {
            completion(config);
        }
    } else {
        __weak __typeof__(self)weakSelf = self;
        [self downloadFile:config.name downloadUrl:videoDownloadUrl inView:inView completion:^(NSString *path, NSError *error) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (error != nil) {
                [self showChoseFileAlertTip:^(BOOL allowed) {
                    if (allowed) {
                        [self selectVideo:config fromVC:inView.vel_topViewController completion:^(VELVideoFileConfig * _Nullable fileConfig, BOOL isCancel) {
                            if (completion) {
                                completion(fileConfig);
                            }
                        }];
                    } else {
                        if (completion) {
                            completion(config);
                        }
                    }
                }];
            } else {
                config.path = path;
                if (completion) {
                    completion(config);
                }
            }
        }];
    }
}

+ (void)selectVideoFile:(VELVideoFileType)fileType fromFileAppInView:(UIView *)inView completion:(void (^)(VELVideoFileConfig * _Nonnull))completion {
    VELVideoFileConfig *cfg = [[VELVideoFileConfig alloc] init];
    cfg.fileType = fileType;
    [self selectVideo:cfg fromVC:inView.vel_topViewController completion:^(VELVideoFileConfig * _Nullable fileConfig, BOOL isCancel) {
        if (completion) {
            completion(isCancel ? nil : fileConfig);
        }
    }];
}

+ (void)selectAudioFile:(VELAudioFileType)fileType fromFileAppInView:(UIView *)inView completion:(void (^)(VELAudioFileConfig * _Nonnull))completion {
    VELAudioFileConfig *cfg = [[VELAudioFileConfig alloc] init];
    cfg.fileType = fileType;
    [self selectAudio:cfg fromVC:inView.vel_topViewController completion:^(VELAudioFileConfig * _Nullable fileConfig, BOOL isCancel) {
        if (completion) {
            completion(isCancel ? nil : fileConfig);
        }
    }];
}

+ (void)showChoseFileAlertTip:(void (^)(BOOL allowed))completion {
    [[VELAlertManager shareManager] showWithMessage:LocalizedStringFromBundle(@"medialive_download_failed_toast", @"MediaLive")
                                            actions:@[
        [VELAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_confirm", @"MediaLive") block:^(UIAlertAction * _Nonnull action) {
        completion(YES);
    }],
        [VELAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_cancel", @"MediaLive") block:^(UIAlertAction * _Nonnull action) {
        completion(NO);
    }]]];
}

+ (void)downloadFile:(NSString *)fileName downloadUrl:(NSString *)downloadUrl inView:(UIView *)inView completion:(void (^)(NSString *path, NSError *error))completion {
    if (VEL_IS_EMPTY_STRING(downloadUrl)) {
        [VELUIToast showText:[NSString stringWithFormat:@"%@: download url is empty!",fileName] detailText:@""];
        if (completion) {
            completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:-10010 userInfo:nil]);
        }
        return;
    }
    [VELFileDownloader checkUrl:downloadUrl hostIsValid:^(BOOL isValid) {
        if (isValid) {
            [VELFileDownloader downloadUrl:downloadUrl fileName:fileName progressBlock:^(CGFloat progress) {
                vel_sync_main_queue(^{
                });
            } completionBlock:^(VELFileDownloadItem * _Nonnull item, BOOL success, NSError * _Nullable error) {
                vel_sync_main_queue(^{
                    if (error == nil) {
                        NSString *tipStr = [NSString stringWithFormat:@"%@ %@",LocalizedStringFromBundle(@"medialive_downloaded", @"MediaLive"), fileName];
                        [VELUIToast showText:tipStr inView:inView];
                    }
                    if (completion) {
                        completion(item.filePath, error);
                    }
                });
            }];
        } else {
            if (completion) {
                completion(nil, [NSError errorWithDomain:NSURLErrorDomain code:-10010 userInfo:nil]);
            }
        }
    }];
}


+ (void)selectAudio:(VELAudioFileConfig *)fileConfig fromVC:(UIViewController *)fromVC completion:(void (^)(VELAudioFileConfig *_Nullable fileConfig, BOOL isCancel))completion {
    UIViewController *topVC = fromVC?:UIApplication.sharedApplication.keyWindow.rootViewController.vel_topViewController;
    [VELFilePickerViewController showFromVC:topVC fileTypes:@[@"public.data"] completion:^(VELFilePickerViewController * _Nonnull vc, NSArray<NSString *> * _Nonnull files) {
        if (files.count == 0) {
            return;
        }
        fileConfig.path = files.firstObject;
        if (VEL_IS_EMPTY_STRING(fileConfig.name)) {
            fileConfig.name = fileConfig.path.lastPathComponent;
        }
        
        if (fileConfig.fileType == VELAudioFileType_PCM) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizedStringFromBundle(@"medialive_input_andio_data_title", @"MediaLive")
                                                                           message:LocalizedStringFromBundle(@"medialive_input_andio_data_des", @"MediaLive")
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = [NSString stringWithFormat:@"%@ %d",LocalizedStringFromBundle(@"medialive_audio_sample", @"MediaLive") ,fileConfig.sampleRate];
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = [NSString stringWithFormat:@"%@%d", LocalizedStringFromBundle(@"medialive_audio_bit_depth", @"MediaLive"),fileConfig.bitDepth];
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = [NSString stringWithFormat:@"%@%d", LocalizedStringFromBundle(@"medialive_audio_channel", @"MediaLive"),fileConfig.channels];
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            __weak __typeof__(alert)weakAlert = alert;
            [alert addAction:[UIAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_confirm", @"MediaLive") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                __strong __typeof__(weakAlert)alert = weakAlert;
                if (VEL_IS_NOT_EMPTY_STRING(alert.textFields[0].text)) {
                    fileConfig.sampleRate = alert.textFields[0].text.intValue;
                }
                if (VEL_IS_NOT_EMPTY_STRING(alert.textFields[1].text)) {
                    fileConfig.bitDepth = alert.textFields[1].text.intValue;
                }
                if (VEL_IS_NOT_EMPTY_STRING(alert.textFields[2].text)) {
                    fileConfig.channels = alert.textFields[2].text.intValue;
                }
                if (completion) {
                    completion(fileConfig, NO);
                }
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_cancel", @"MediaLive") style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                if (completion) {
                    completion(nil, YES);
                }
            }]];
            [topVC presentViewController:alert animated:YES completion:nil];
        } else {
            if (completion) {
                completion(fileConfig, NO);
            }
        }
    }];
}

+ (void)selectVideo:(VELVideoFileConfig *)fileConfig fromVC:(UIViewController *)fromVC completion:(void (^)(VELVideoFileConfig *_Nullable fileConfig, BOOL isCancel))completion {
    UIViewController *topVC = fromVC?:UIApplication.sharedApplication.keyWindow.rootViewController.vel_topViewController;
    [VELFilePickerViewController showFromVC:topVC fileTypes:@[@"public.data"] completion:^(VELFilePickerViewController * _Nonnull vc, NSArray<NSString *> * _Nonnull files) {
        if (files.count == 0) {
            return;
        }
        fileConfig.path = files.firstObject;
        if (VEL_IS_EMPTY_STRING(fileConfig.name)) {
            fileConfig.name = fileConfig.path.lastPathComponent;
        }
        if (fileConfig.fileType != VELVideoFileType_UnKnown) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:LocalizedStringFromBundle(@"medialive_input_video_data_title", @"MediaLive")
                                                                           message:LocalizedStringFromBundle(@"medialive_input_video_data_des", @"MediaLive")
                                                                    preferredStyle:(UIAlertControllerStyleAlert)];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = [NSString stringWithFormat:@"%@ %d",LocalizedStringFromBundle(@"medialive_video_fps", @"MediaLive") ,fileConfig.fps];
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = [NSString stringWithFormat:@"%@ %d",LocalizedStringFromBundle(@"medialive_video_width", @"MediaLive") ,fileConfig.width];
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = [NSString stringWithFormat:@"%@ %d",LocalizedStringFromBundle(@"medialive_video_height", @"MediaLive") ,fileConfig.height];
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
                textField.placeholder = LocalizedStringFromBundle(@"medialive_video_required", @"MediaLive");
                textField.keyboardType = UIKeyboardTypeNumberPad;
            }];
            __weak __typeof__(alert)weakAlert = alert;
            [alert addAction:[UIAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_confirm", @"MediaLive") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
                __strong __typeof__(weakAlert)alert = weakAlert;
                if (VEL_IS_NOT_EMPTY_STRING(alert.textFields[0].text)) {
                    fileConfig.fps = alert.textFields[0].text.intValue;
                }
                if (VEL_IS_NOT_EMPTY_STRING(alert.textFields[1].text)) {
                    fileConfig.width = alert.textFields[1].text.intValue;
                }
                if (VEL_IS_NOT_EMPTY_STRING(alert.textFields[2].text)) {
                    fileConfig.height = alert.textFields[2].text.intValue;
                }
                if (VEL_IS_NOT_EMPTY_STRING(alert.textFields[3].text)) {
                    fileConfig.fileType = alert.textFields[3].text.intValue;
                    if (completion) {
                        completion(fileConfig, NO);
                    }
                } else {
                    [VELUIToast showText:LocalizedStringFromBundle(@"medialive_re_choose_file", @"MediaLive") inView:UIApplication.sharedApplication.keyWindow];
                }
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:LocalizedStringFromBundle(@"medialive_cancel", @"MediaLive") style:(UIAlertActionStyleCancel) handler:^(UIAlertAction * _Nonnull action) {
                if (completion) {
                    completion(nil, YES);
                }
            }]];
            [topVC presentViewController:alert animated:YES completion:nil];
        } else {
            if (completion) {
                completion(fileConfig, NO);
            }
        }
    }];
}

@end
