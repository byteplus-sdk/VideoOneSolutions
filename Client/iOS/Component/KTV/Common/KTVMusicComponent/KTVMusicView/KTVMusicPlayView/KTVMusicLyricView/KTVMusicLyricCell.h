//
//  KTVMusicLyricCell.h
//  AFNetworking
//
//  Created by bytedance on 2022/11/21.
//

#import "KTVMusicLyricConfig.h"
#import "KTVMusicLyricModel.h"
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicLyricCell : UITableViewCell

@property (nonatomic, strong) KTVMusicLyricLineModel *lineModel;

@property (nonatomic, strong) KTVMusicLyricConfig *config;

- (void)setCurrentRow:(NSInteger)currentRow playingRow:(NSInteger)playingRow;

- (void)playProgress:(NSInteger)time;

+ (CGFloat)getCellHeight:(KTVMusicLyricLineModel *)lineModel
                  config:(KTVMusicLyricConfig *)config
                maxWidth:(CGFloat)maxWidth;

@end

NS_ASSUME_NONNULL_END
