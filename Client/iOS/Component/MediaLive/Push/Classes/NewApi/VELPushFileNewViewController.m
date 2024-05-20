// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushFileNewViewController.h"
#import "VELPushImageUtils.h"
#import "VELFileTool.h"
#import <ToolKit/Localizator.h>
#define LOG_TAG @"NEW_PUSH_FILE"
#define VEL_DEFINE_TO_STR(x) #x
static int vel_push_new_file_index = 2;
@interface VELPushFileNewViewController ()
@property (nonatomic, strong) VELFileReader *videoFileReader;
@property (nonatomic, strong) VELVideoFileConfig *videoConfig;
@property (nonatomic, strong) VELFileReader *audioFileReader;
@property (nonatomic, strong) VELAudioFileConfig *audioConfig;
@end

@implementation VELPushFileNewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)restartEngine {
    [super restartEngine];
    [self changeFileType:vel_push_new_file_index];
}

- (void)startStreaming {
    if (!self.videoConfig.isValid) {
        [self startVideoFileReader];
        return;
    }
    if (!self.audioConfig.isValid) {
        [self startAudioFileReader];
        return;
    }
    [super startStreaming];
    [self setPreviewRenderMode:(VELSettingPreviewRenderModeFit)];
}
- (void)applicationWillResignActive {
}

- (void)applicationDidBecomeActive {
}

- (void)changeFileType:(NSInteger)index {
    [self stopAudioFileReader];
    [self stopVideoFileReader];
    vel_push_new_file_index = (int)index;
    [self startVideoFileReader];
    [self startAudioFileReader];
}

- (void)startVideoFileReader {
    [self stopVideoFileReader];
    __weak __typeof__(self)weakSelf = self;
    [self getVideoFileConfig:^(VELVideoFileConfig *config) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (!self.vel_isViewLoadedAndVisible) {
            return;
        }
        if (config == nil || VEL_IS_EMPTY_STRING(config.path) ||  ![NSFileManager.defaultManager fileExistsAtPath:config.path]) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_video_file_not_set", @"MediaLive") inView:self.view];
            return;
        }
        self.videoConfig = config;
        self.previewContainer.hidden = config.convertType == VELVideoFileConvertTypeEncodeData;
        if (config.convertType == VELVideoFileConvertTypeTextureID) {
            [VELUIToast showText:[NSString stringWithFormat:LocalizedStringFromBundle(@"medialive_read_type_file_TextureID", @"MediaLive"), config.fileTypeDes] inView:self.view];
        } else if (config.convertType == VELVideoFileConvertTypePixelBuffer) {
            [VELUIToast showText:[NSString stringWithFormat:LocalizedStringFromBundle(@"medialive_read_type_file_CVPixelBuffer", @"MediaLive"), config.fileTypeDes] inView:self.view];
        } else if (config.convertType == VELVideoFileConvertTypeSampleBuffer) {
            [VELUIToast showText:[NSString stringWithFormat:LocalizedStringFromBundle(@"medialive_read_type_file_CMSampleBuffer", @"MediaLive"), config.fileTypeDes] inView:self.view];
        } else {
            [VELUIToast showText:[NSString stringWithFormat:LocalizedStringFromBundle(@"medialive_read_type_file", @"MediaLive"), config.fileTypeDes] inView:self.view];
        }
        [self startReadFileWithVideoFileConfig:self.videoConfig];
    }];
    
}

- (void)startReadFileWithVideoFileConfig:(VELVideoFileConfig *)config {
    [self stopVideoFileReader];
    
    self.videoFileReader = [VELFileReader readerWithConfig:config];
    self.videoFileReader.repeat = YES;
    __weak __typeof__(self)weakSelf = self;
    [self.videoFileReader startWithDataCallBack:^(NSData * _Nullable data, CMTime pts) {
        __strong __typeof__(weakSelf)self = weakSelf;
        VeLiveVideoFrame *videoFrame = [[VeLiveVideoFrame alloc] init];
        videoFrame.width = config.width;
        videoFrame.height = config.height;
        videoFrame.pts = pts;
        if (config.convertType == VELVideoFileConvertTypeTextureID) {
            [self.imageUtils beginCurrentContext];
            VELPushImageBuffer *imgBuffer = [self.imageUtils allocBufferWithWidth:config.width
                                                                           height:config.height
                                                                      bytesPerRow:config.width * 4
                                                                           format:(VELImageFormatType_BGRA)];
            if (imgBuffer == nil) {
                return;
            }
            [data getBytes:imgBuffer.buffer length:data.length];
            id <VELPushGLTexture> texture = [self.imageUtils transforBufferToTexture:imgBuffer];
            videoFrame.bufferType = VeLiveVideoBufferTypeTexture;
            videoFrame.pixelFormat = VeLivePixelFormat2DTexture;
            videoFrame.textureId = texture.texture;
            [self.pusher pushExternalVideoFrame:videoFrame];
        } else if (config.convertType == VELVideoFileConvertTypePixelBuffer) {
            videoFrame.bufferType = VeLiveVideoBufferTypePixelBuffer;
            CVPixelBufferRef pixelBuffer = [VELPixelBufferManager fromBGRAData:data width:config.width height:config.height];
            videoFrame.pixelBuffer = pixelBuffer;
            [videoFrame setReleaseCallback:^{
                CVPixelBufferRelease(pixelBuffer);
            }];
            [self.pusher pushExternalVideoFrame:videoFrame];
        } else if (config.convertType == VELVideoFileConvertTypeSampleBuffer) {
            videoFrame.bufferType = VeLiveVideoBufferTypeSampleBuffer;
            CVPixelBufferRef pixelBuffer = [VELPixelBufferManager fromBGRAData:data width:config.width height:config.height];
            CMSampleBufferRef sampleBuffer = [VELPixelBufferManager sampleBufferFromPixelBuffer:pixelBuffer];
            videoFrame.sampleBuffer = sampleBuffer;
            [videoFrame setReleaseCallback:^{
                CFRelease(sampleBuffer);
                CVPixelBufferRelease(pixelBuffer);
            }];
            [self.pusher pushExternalVideoFrame:videoFrame];
        } else {
            videoFrame.bufferType = VeLiveVideoBufferTypeNSData;
            videoFrame.data = data;
            switch (config.fileType) {
                case VELVideoFileType_BGRA:
                    videoFrame.pixelFormat = VeLivePixelFormatBGRA32;
                    break;
                case VELVideoFileType_NV12:
                    videoFrame.pixelFormat = VeLivePixelFormatNV12;
                    break;
                case VELVideoFileType_NV21:
                    videoFrame.pixelFormat = VeLivePixelFormatNV21;
                    break;
                case VELVideoFileType_YUV:
                    videoFrame.pixelFormat = VeLivePixelFormatI420;
                    break;
                default:
                    return;
                    break;
            }
            [self.pusher pushExternalVideoFrame:videoFrame];
        }
    } completion:^(NSError * _Nullable error, BOOL isEnd) {
        
    }];
}

- (void)stopVideoFileReader {
    if (self.videoFileReader) {
        [self.videoFileReader stop];
        self.videoFileReader = nil;
    }
}

- (void)startVideoCapture {
    [self startVideoFileReader];
    [self.pusher startVideoCapture:(VeLiveVideoCaptureExternal)];
}

- (void)stopVideoCapture {
    [self stopVideoFileReader];
    [self.pusher stopVideoCapture];
}

- (void)startAudioFileReader {
    [self stopAudioFileReader];
    __weak __typeof__(self)weakSelf = self;
    [self getAudioFileConfig:^(VELAudioFileConfig *config) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (!self.vel_isViewLoadedAndVisible) {
            return;
        }
        if (config == nil || VEL_IS_EMPTY_STRING(config.path) ||  ![NSFileManager.defaultManager fileExistsAtPath:config.path]) {
            [VELUIToast showText:LocalizedStringFromBundle(@"medialive_audio_file_not_set", @"MediaLive") inView:self.view];
            return;
        }
        self.audioConfig = config;
        [self startReadAudioFileWithFileConfig:self.audioConfig];
    }];
}

- (void)startReadAudioFileWithFileConfig:(VELAudioFileConfig *)config {
    [self stopAudioFileReader];
    self.audioFileReader = [VELFileReader readerWithConfig:config];
    self.audioFileReader.repeat = YES;
    __weak __typeof__(self)weakSelf = self;
    [self.audioFileReader startWithDataCallBack:^(NSData * _Nullable data, CMTime pts) {
        __strong __typeof__(weakSelf)self = weakSelf;
        VeLiveAudioFrame *audioFrame = [[VeLiveAudioFrame alloc] init];
        audioFrame.bufferType = VeLiveAudioBufferTypeNSData;
        audioFrame.data = data;
        audioFrame.sampleRate = config.sampleRate;
        audioFrame.channels = config.channels;
        audioFrame.pts = pts;
        [self.pusher pushExternalAudioFrame:audioFrame];
    } completion:^(NSError * _Nullable error, BOOL isEnd) {
    }];
}

- (void)stopAudioFileReader {
    if (self.audioFileReader) {
        [self.audioFileReader stop];
        self.audioFileReader = nil;
    }
}

- (void)startAudioCapture {
    [self startAudioFileReader];
    [self.pusher startAudioCapture:(VeLiveAudioCaptureExternal)];
}

- (void)stopAudioCapture {
    [self stopAudioFileReader];
    [self.pusher stopAudioCapture];
}

- (void)setupAudioCapture {
    VELLogInfo(LOG_TAG, LocalizedStringFromBundle(@"medialive_ignore_audio_capture", @"MediaLive"));
}
- (void)getAudioFileConfig:(void (^)(VELAudioFileConfig *config))completion {
    [VELFileTool getAudioFileWithConfig:[VELFileTool getOrCreateAudioFileWithType:(VELAudioFileType_PCM)]
                                 inView:self.view
                             completion:completion];
}


- (void)getVideoFileConfig:(void (^)(VELVideoFileConfig *config))completion {
    NSArray <NSNumber *>* videoFileType = @[@(VELVideoFileType_BGRA), @(VELVideoFileType_NV12), @(VELVideoFileType_NV21)];
    vel_push_new_file_index = vel_push_new_file_index % (videoFileType.count);
    VELVideoFileType fileType = videoFileType[vel_push_new_file_index].integerValue;
    VELVideoFileConfig *config = [[VELVideoFileConfig alloc] init];
    config.fileType = fileType;
    [VELFileTool getVideoFileWithConfig:config inView:self.view completion:completion];
}
@end

