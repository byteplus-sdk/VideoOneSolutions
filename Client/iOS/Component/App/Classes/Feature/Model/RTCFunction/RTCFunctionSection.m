//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "RTCFunctionSection.h"
#import "RTCQuickStart.h"
#import "RTCMutiRoom.h"
#import "RTCCrossRoomPK.h"
#import "RTCAudioRawData.h"
#import "RTCAudioEffectMixing.h"
#import "RTCAudioMediaMixing.h"
#import "RTCSoundEffectMixing.h"
#import "RTCVideoPip.h"
#import "RTCVideoRotation.h"
#import "RTCVideoCommonConfig.h"
#import "RTCByteAIBeauty.h"
#import "RTCPushCDN.h"
#import "RTCNormalSei.h"
#import "RTCStreamSyncSei.h"

@implementation RTCFunctionSection

- (NSArray<__kindof BaseFunctionSection *> *)items {
    if (!_items) {
        NSArray *funcList = [self functionList];
        NSMutableArray *resultList = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in funcList) {
            NSArray *models = [dic objectForKey:@"items"];
            NSInteger count = models.count;
            NSMutableArray *list = [[NSMutableArray alloc] init];
            [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                BaseFunctionEntrance *func = [[NSClassFromString(obj) alloc] init];
                if (count > 1) {
                    func.marginTop = idx == 0 ? 8 : 0;
                    func.marginBottom = idx == count -1 ? 8 : 0;
                }
                if (func && func.isNeedShow) {
                    [list addObject:func];
                }
            }];
            BaseFunctionSection *section = [[BaseFunctionSection alloc] init];
            section.tableSectionName = [dic objectForKey:@"tableSectionName"];
            section.items = [list copy];
            [resultList addObject:section];
        }
        _items = [resultList copy];
    }
    return _items;
}

- (NSString *)functionSectionName {
    return LocalizedStringFromBundle(@"function_rtc_title", @"App");
}

- (NSArray *)functionList {
    static dispatch_once_t onceToken;
    static NSArray *_functionList;
    dispatch_once(&onceToken, ^{
        _functionList = @[
            @{
                @"tableSectionName": LocalizedStringFromBundle(@"label_example_base", @"APIExample"),
                @"items": @[
                    @"RTCQuickStart",
                ]
            },
            @{
                @"tableSectionName": LocalizedStringFromBundle(@"label_example_room", @"APIExample"),
                @"items": @[
                    @"RTCMutiRoom",
                ]
            },
            @{
                @"tableSectionName": LocalizedStringFromBundle(@"label_example_transmission", @"APIExample"),
                @"items": @[
                    @"RTCCrossRoomPK",
                ]
            },
            @{
                @"tableSectionName": LocalizedStringFromBundle(@"label_example_audio", @"APIExample"),
                @"items": @[
                    @"RTCAudioRawData",
                    @"RTCAudioEffectMixing",
                    @"RTCAudioMediaMixing",
                    @"RTCSoundEffectMixing",
                ]
            },
            @{
                @"tableSectionName": LocalizedStringFromBundle(@"label_example_video", @"APIExample"),
                @"items": @[
                    @"RTCVideoPip",
                    @"RTCVideoCommonConfig",
                    @"RTCVideoRotation",
                    @"RTCPushCDN"
                ]
            },
            @{
                @"tableSectionName": LocalizedStringFromBundle(@"label_example_important", @"APIExample"),
                @"items": @[
                    @"RTCByteAIBeauty",
                ]
            },
            @{
                @"tableSectionName": LocalizedStringFromBundle(@"label_example_message", @"APIExample"),
                @"items": @[
                    @"RTCNormalSei",
                    @"RTCStreamSyncSei"
                ]
            },
        ];
    });
    return _functionList;
}

@end
