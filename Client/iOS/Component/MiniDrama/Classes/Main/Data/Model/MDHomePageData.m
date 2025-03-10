// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDHomePageData.h"
#import "MDDramaInfoModel.h"

@implementation MDHomePageData

- (instancetype)init
{
    self = [super init];
    return self;
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{
        @"sliderShowData": @"loop",
        @"trendingData": @"trending",
        @"latestDramaData": @"new",
        @"recommendData": @"recommend"
    };
}


+ (NSDictionary<NSString *,id> *)modelContainerPropertyGenericClass {
    return @{@"sliderShowData" : [MDDramaInfoModel class],
                    @"trendingData" : [MDDramaInfoModel class],
                    @"latestDramaData" : [MDDramaInfoModel class],
                    @"recommendData": [MDDramaInfoModel class]
    };
}

- (NSArray *)sections {
    if (!_sections) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        if (self.sliderShowData.count > 0) {
            [array addObject:@(MDDramaSectionTypeLoop)];
        }
        if (self.trendingData.count > 0) {
            [array addObject:@(MDDramaSectionTypeTrending)];
        }
        if (self.latestDramaData.count > 0) {
            [array addObject:@(MDDramaSectionTypeNew)];
        }
        if (self.recommendData.count > 0) {
            [array addObject:@(MDDramaSectionTypeRecommend)];
        }
        _sections = [array copy];
    }
    return _sections;
}

- (NSArray<MDDramaInfoModel *> *)getDramaInfo:(MDDramaSectionType)sectionType {
    switch (sectionType) {
        case MDDramaSectionTypeLoop:
            return self.sliderShowData;
        case MDDramaSectionTypeTrending:
            return self.trendingData;
        case MDDramaSectionTypeNew:
            return self.latestDramaData;
        case MDDramaSectionTypeRecommend:
            return self.recommendData;
        default:
            return nil;;
    }
}

@end
