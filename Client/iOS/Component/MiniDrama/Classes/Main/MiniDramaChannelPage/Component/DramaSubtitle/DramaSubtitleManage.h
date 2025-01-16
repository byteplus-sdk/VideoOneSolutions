//
//  DramaSubtitleManage.h
//  AFNetworking
//
//  Created by ByteDance on 2024/12/6.
//

#import <Foundation/Foundation.h>
#import "MDVideoPlayerController.h"
#import "DramaSubtitleLabel.h"
#import "TTVideoEngine.h"


NS_ASSUME_NONNULL_BEGIN

@interface DramaSubtitleModel : NSObject

@property (nonatomic, copy) NSString *languageName;
@property (nonatomic, assign) NSInteger subtitleId;

@end

@interface DramaSubtitleManage : NSObject

@property (nonatomic, strong) NSArray<DramaSubtitleModel *> *subtitleList;

@property (nonatomic, strong, readonly) DramaSubtitleModel *currentSubtitleModel;

@property (nonatomic, strong) DramaSubtitleLabel *subTitleLabel;

@property (nonatomic, strong) TTVideoEngine *videoEngine;

@property (nonatomic, copy) void (^openSubtitleBlock)(BOOL result, DramaSubtitleModel *_Nullable model);

- (void)openSubtitle:(NSString *)subtitleAuthToken;

- (void)switchSubtitle:(NSInteger)subtitleId withBlock:(void (^_Nullable)(BOOL result))block;

+ (NSString *)getLanguangeNameWithId:(NSInteger)languangeId;

- (void)clearState;

@end

NS_ASSUME_NONNULL_END
