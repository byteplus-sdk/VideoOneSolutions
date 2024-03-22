//
//  KTVDownloadSongModel.h
//  veRTC_Demo
//
//  Created by on 2022/1/20.
//  
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 获取歌曲歌词下载地址模型
/// Get song lyrics download address model
@interface KTVDownloadSongModel : NSObject

@property (nonatomic, copy) NSString *lrcPath;
@property (nonatomic, copy) NSString *musicPath;
@property (nonatomic, strong) KTVSongModel *songModel;

@end

NS_ASSUME_NONNULL_END
