// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, ChorusSongModelStatus) {
    ChorusSongModelStatusNormal = 0,
    ChorusSongModelStatusWaitingDownload = 1,
    ChorusSongModelStatusDownloading = 2,
    ChorusSongModelStatusDownloaded = 3,
};

typedef NS_ENUM(NSInteger, ChorusSongModelSingStatus) {
    ChorusSongModelSingStatusWaiting = 1,
    ChorusSongModelSingStatusSinging = 2,
    ChorusSongModelSingStatusFinish = 3,
};

@interface ChorusSongModel : NSObject

@property (nonatomic, copy) NSString *musicName;
@property (nonatomic, copy) NSString *musicId;
@property (nonatomic, copy) NSString *singerUserName;
@property (nonatomic, assign) NSInteger musicAllTime;
@property (nonatomic, copy) NSString *pickedUserID;
@property (nonatomic, copy) NSString *pickedUserName;
@property (nonatomic, copy) NSString *coverURL;
@property (nonatomic, assign) ChorusSongModelStatus status;
@property (nonatomic, assign) BOOL isPicked;
@property (nonatomic, assign) ChorusSongModelSingStatus singStatus;
@property (nonatomic, copy) NSString *musicFileUrl;
@property (nonatomic, copy) NSString *musicLrcUrl;


@end

NS_ASSUME_NONNULL_END
