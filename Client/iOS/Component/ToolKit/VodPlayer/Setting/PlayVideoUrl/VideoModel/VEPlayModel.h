// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>


@interface VEPlayModel : NSObject<YYModel>

@property (nonatomic, assign) NSInteger type;// 0: vid； 1: direct url 2: video model

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, copy) NSString *playAuthToken;

@property (nonatomic, copy) NSString *httpUrl;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *coverUrl;

@property (nonatomic, copy) NSString *duration;

//
@property (nonatomic, copy) NSArray<NSString *> *urlArray; //multi urls.

@property (nonatomic, copy) NSString *md5Key;

+ (VEPlayModel *)playModelWithLocalFileUrl:(NSString *)fileUrl;

+ (VEPlayModel *)playModelWithRemoteUrl:(NSString *)remoteUrl;

+ (VEPlayModel *)playModelWithRemoteUrls:(NSArray<NSString *> *)remoteUrls;


@end


