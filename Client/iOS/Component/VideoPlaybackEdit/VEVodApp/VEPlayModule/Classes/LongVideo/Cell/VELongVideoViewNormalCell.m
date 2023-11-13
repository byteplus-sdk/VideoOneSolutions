// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELongVideoViewNormalCell.h"
#import "VEVideoModel.h"
#import <SDWebImage/SDWebImage.h>

@interface VELongVideoViewNormalCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subLabel;

@end

@implementation VELongVideoViewNormalCell

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    if ([videoModel isKindOfClass:[VEVideoModel class]]) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@", videoModel.title];
        self.subLabel.text = [NSString stringWithFormat:@"%@", videoModel.subTitle];
        [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:videoModel.coverUrl]];
    } else {
        self.titleLabel.text = @"";
        self.coverImgView.image = nil;
    }
}

@end
