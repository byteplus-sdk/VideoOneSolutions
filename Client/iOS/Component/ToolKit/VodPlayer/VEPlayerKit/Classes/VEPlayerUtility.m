//
//  VEPlayerUtility.m
//  ToolKit
//
//  Created by zys on 2026/1/15.
//

#import "VEPlayerUtility.h"
#import "Localizator.h"
#import <TTSDKFramework/TTSDKFramework.h>

@implementation VEPlayerUtility

+ (NSString *)transferResolutionTitleByType:(NSInteger)type {
    NSString *resolutionTitle;
    switch (type) {
        case TTVideoEngineResolutionTypeSD:
            resolutionTitle = @"320";
            break;
        case TTVideoEngineResolutionTypeHD:
            resolutionTitle = @"540";
            break;
        case TTVideoEngineResolutionTypeFullHD:
            resolutionTitle = @"720";
            break;
        case TTVideoEngineResolutionType1080P:
            resolutionTitle = @"1080";
            break;
        case TTVideoEngineResolutionType4K:
            resolutionTitle = @"4K";
            break;
        case TTVideoEngineResolutionTypeABRAuto:
            resolutionTitle = LocalizedStringFromBundle(@"resolution_abr_auto", @"VodPlayer");
            break;
        case TTVideoEngineResolutionTypeAuto:
            resolutionTitle = LocalizedStringFromBundle(@"resolution_auto", @"VodPlayer");
            break;
        case TTVideoEngineResolutionTypeUnknown:
            resolutionTitle = LocalizedStringFromBundle(@"resolution_unknown", @"VodPlayer");
            break;
        case TTVideoEngineResolutionTypeHDR:
            resolutionTitle = @"HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_240P:
            resolutionTitle = @"240p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_360P:
            resolutionTitle = @"360p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_480P:
            resolutionTitle = @"480p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_540P:
            resolutionTitle = @"540p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_720P:
            resolutionTitle = @"720p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_1080P:
            resolutionTitle = @"1080p HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_2K:
            resolutionTitle = @"2k HDR";
            break;
        case TTVideoEngineResolutionTypeHDR_4K:
            resolutionTitle = @"4k HDR";
            break;
        case TTVideoEngineResolutionType2K:
            resolutionTitle = @"2k";
            break;
        case TTVideoEngineResolutionType1080P_120F:
            resolutionTitle = @"1080P_120F";
            break;
        case TTVideoEngineResolutionType2K_120F:
            resolutionTitle = @"2K_120F";
            break;
        case TTVideoEngineResolutionType4K_120F:
            resolutionTitle = @"4K_120F";
            break;
        default:
            resolutionTitle = LocalizedStringFromBundle(@"resolution_default", @"VodPlayer");
            break;
    }
    return resolutionTitle;
}

@end
