//
//  MDHomePageData.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/15.
//

#import "MDDramaInfoModel.h"
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MDDramaSectionType) {
    MDDramaSectionTypeLoop,
    MDDramaSectionTypeTrending,
    MDDramaSectionTypeNew,
    MDDramaSectionTypeRecommend
};

@interface MDHomePageData : NSObject<YYModel>

@property (nonatomic, strong) NSArray<MDDramaInfoModel*> *sliderShowData;
@property (nonatomic, strong) NSArray<MDDramaInfoModel*> *trendingData;
@property (nonatomic, strong) NSArray<MDDramaInfoModel*> *latestDramaData;
@property (nonatomic, strong) NSArray<MDDramaInfoModel*> *recommendData;

@property (nonatomic, strong) NSArray *sections;

-(NSArray<MDDramaInfoModel*> *)getDramaInfo:(MDDramaSectionType) sectionType;

@end

NS_ASSUME_NONNULL_END
