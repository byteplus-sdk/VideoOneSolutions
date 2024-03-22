//
//  KTVSongModel.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KTVSongModelStatus) {
    KTVSongModelStatusNormal = 0,
    KTVSongModelStatusWaitingDownload = 1,
    KTVSongModelStatusDownloading = 2,
    KTVSongModelStatusDownloaded = 3,
};

typedef NS_ENUM(NSInteger, KTVSongModelSingStatus) {
    KTVSongModelSingStatusWaiting = 1,
    KTVSongModelSingStatusSinging = 2,
    KTVSongModelSingStatusFinish = 3,
};

@interface KTVSongModel : NSObject

@property (nonatomic, copy) NSString *musicName;
@property (nonatomic, copy) NSString *musicId;
@property (nonatomic, copy) NSString *singerUserName;
@property (nonatomic, assign) NSInteger musicAllTime;
@property (nonatomic, copy) NSString *pickedUserID;
@property (nonatomic, copy) NSString *pickedUserName;
@property (nonatomic, copy) NSString *coverURL;
@property (nonatomic, assign) KTVSongModelStatus status;
@property (nonatomic, assign) BOOL isPicked;
@property (nonatomic, assign) KTVSongModelSingStatus singStatus;
@property (nonatomic, copy) NSString *musicFileUrl;
@property (nonatomic, copy) NSString *musicLrcUrl;

@end

NS_ASSUME_NONNULL_END
