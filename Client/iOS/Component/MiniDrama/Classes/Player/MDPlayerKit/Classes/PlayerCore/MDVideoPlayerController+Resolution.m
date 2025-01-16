//
//  MDVideoPlayerController+Resolution.m
//  VOLCDemo
//
//  Created by wangzhiyong on 2021/12/5.
//

#import "MDVideoPlayerController+Resolution.h"

static TTVideoEngineResolutionType kDefaultResolutionType = TTVideoEngineResolutionTypeHD;

@implementation MDVideoPlayerController (Resolution)

+ (TTVideoEngineResolutionType)getPlayerCurrentResolution {
    return kDefaultResolutionType;
}

+ (void)setPlayerCurrentResolution:(TTVideoEngineResolutionType)defaultResolution {
    kDefaultResolutionType = defaultResolution;
}

@end
