//
//  KTVMusicLyricView.h
//  AFNetworking
//
//  Created by bytedance on 2022/11/21.
//

#import <UIKit/UIKit.h>
#import "KTVMusicLyricModel.h"
#import "KTVMusicLyricConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicLyricView : UITableView

@property (nonatomic, copy) void (^finishLineBlock)(KTVMusicLyricLineModel *lineModel);

- (void)loadLrcByPath:(NSString *)path
               config:(KTVMusicLyricConfig *)config
                error:(NSError * _Nullable *)error;

- (void)playAtTime:(NSTimeInterval)time;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
