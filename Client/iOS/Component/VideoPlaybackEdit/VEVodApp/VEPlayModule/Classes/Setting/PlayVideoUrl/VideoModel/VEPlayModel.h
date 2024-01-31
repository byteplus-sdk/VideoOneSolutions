// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>


@interface VEPlayModel : NSObject<YYModel>

@property (nonatomic, assign) NSInteger type;// 0: vid； 1: direct url 2: video model

@property (nonatomic, copy) NSString *vid;// vid 必需

@property (nonatomic, copy) NSString *playAuthToken; // vid 必须

@property (nonatomic, copy) NSString *httpUrl; // direct url 必须

@property (nonatomic, copy) NSString *title; // 非必需

@property (nonatomic, copy) NSString *coverUrl; // 非必需

@property (nonatomic, copy) NSString *duration; // 非必需，单位：MS

//
@property (nonatomic, copy) NSArray<NSString *> *urlArray; //multi urls.

@property (nonatomic, copy) NSString *md5Key;

+ (VEPlayModel *)playModelWithLocalFileUrl:(NSString *)fileUrl;

+ (VEPlayModel *)playModelWithRemoteUrl:(NSString *)remoteUrl;

+ (VEPlayModel *)playModelWithRemoteUrls:(NSArray<NSString *> *)remoteUrls;


@end


