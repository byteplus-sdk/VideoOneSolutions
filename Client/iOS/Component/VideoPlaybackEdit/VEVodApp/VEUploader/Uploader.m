//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "Uploader.h"
#import "NetworkingManager+Uploader.h"
#import <TTSDK/BDFileUploaderHeader.h>

@interface VideoUploader () <BDVideoUploadClientDelegate>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong, nullable) void (^progressBlock)(NSInteger);
@property (nonatomic, strong, nullable) void (^completionBlock)(BDVideoUploadInfo *_Nullable, NSError *_Nullable);
@property (nonatomic, strong) BDVideoUploaderClient *videoUploadClient;
@property (atomic, assign) BOOL isStarted;
@property (atomic, assign) BOOL isClosed;

@end

@implementation VideoUploader

- (instancetype)initWithFilePath:(NSString *)filePath {
    self = [super init];
    if (self) {
        self.filePath = filePath;
    }
    return self;
}

- (void)start:(void (^)(NSInteger))progress
    completion:(void (^)(BDVideoUploadInfo *_Nullable, NSError *_Nullable))completion {
    if (self.isStarted) {
        return;
    }
    self.isStarted = YES;
    self.isClosed = NO;
    self.progressBlock = progress;
    self.completionBlock = completion;
    [NetworkingManager getUploadToken:^(STSToken *_Nullable token, NetworkingResponse *_Nonnull response) {
        if (self.isClosed) {
            return;
        }
        if (!response.result || token == nil) {
            self.isStarted = NO;
            if (self.completionBlock) {
                self.completionBlock(nil, response.error);
            }
            NSLog(@"[%@] didFinish error: %@", self.class, response.error);
            return;
        }
        [self createUploadClientWithToken:token];
        [self.videoUploadClient start];
    }];
}

- (void)close {
    self.isStarted = NO;
    self.isClosed = YES;
    [self.videoUploadClient close];
}

- (void)createUploadClientWithToken:(STSToken *)token {
    self.videoUploadClient = [[BDVideoUploaderClient alloc] initWithFilePath:self.filePath];
    self.videoUploadClient.delegate = self;
    NSDictionary *authParameter = @{
        BDFileUploadAccessKey: token.accessKey,
        BDFileUploadSecretKey: token.secretAccessKey,
        BDFileUploadSessionToken: token.sessionToken,
        BDFileUploadExpiredTime: token.expiredTime,
        BDFileUploadSpace: token.spaceName,
    };
    [self.videoUploadClient setAuthorizationParameter:authParameter];
    [self.videoUploadClient setUploadConfig:@{
        BDFileUploadSliceSize: @(512 * 1024),
    }];
    NSString *suffix = [self.filePath pathExtension];
    if (suffix != nil && suffix.length > 0) {
        [self.videoUploadClient setFileExtension:[NSString stringWithFormat:@".%@", suffix]];
    }
}

#pragma mark - BDVideoUploadClientDelegate

- (void)videoUpload:(BDVideoUploaderClient *)uploadClient didFinish:(nullable BDVideoUploadInfo *)videoInfo error:(nullable NSError *)error {
    if (self.completionBlock) {
        self.completionBlock(videoInfo, error);
    }
    if (error != nil) {
        NSLog(@"[%@] didFinish error: %@", self.class, error);
    }
    [self close];
}

- (void)videoUpload:(BDVideoUploaderClient *)uploadClient progressDidUpdate:(NSInteger)progress {
    if (self.progressBlock) {
        self.progressBlock(progress);
    }
}

@end
