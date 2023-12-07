//
//  VEMultiStatePlayButton.h
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/10/25.
//


#import "VEActionButton.h"


typedef enum : NSUInteger {
    VEMultiStatePlayStatePlay,
    VEMultiStatePlayStatePause,
    VEMultiStatePlayStateReplay
} VEMultiStatePlayState;


@interface VEMultiStatePlayButton : VEActionButton

@property(nonatomic, assign) VEMultiStatePlayState playState;

@end

