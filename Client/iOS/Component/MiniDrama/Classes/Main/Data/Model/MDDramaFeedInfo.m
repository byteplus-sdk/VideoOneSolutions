//
//  MDDramaVideoInfoModel.m
//  MDPlayModule
//

#import "MDDramaFeedInfo.h"
#import "MDVideoPlayerController+Resolution.h"
#import "MDTTVideoEngineSourceCategory.h"

@implementation MDDramaFeedInfo

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"dramaInfo": @"drama_meta",
        @"videoInfo": @"video_meta",
    };
}

+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"dramaInfo" : [MDDramaInfoModel class],
             @"videoInfo" : [MDDramaEpisodeInfoModel class]};
}


@end
