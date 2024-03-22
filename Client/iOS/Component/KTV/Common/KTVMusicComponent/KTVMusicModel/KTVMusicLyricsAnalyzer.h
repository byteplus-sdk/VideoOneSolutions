//
//  KTVMusicLyricsAnalyzer.h
//  veRTC_Demo
//
//  Created by on 2022/1/18.
//

#import <Foundation/Foundation.h>
#import "KTVMusicLyricConfig.h"
@class KTVMusicLyricModel;

NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicLyricsAnalyzer : NSObject

+ (KTVMusicLyricModel *)analyzeLrcByPath:(NSString *)path
                               lrcFormat:(KTVMusicLrcFormat)lrcFormat;
@end

NS_ASSUME_NONNULL_END
