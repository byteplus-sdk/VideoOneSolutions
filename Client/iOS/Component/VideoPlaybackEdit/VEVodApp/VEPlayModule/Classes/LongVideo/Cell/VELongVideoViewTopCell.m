// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELongVideoViewTopCell.h"
#import "VEVideoModel.h"
#import <SDWebImage/SDWebImage.h>

@interface VELongVideoViewTopCell ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImgView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation VELongVideoViewTopCell

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    if ([videoModel isKindOfClass:[VEVideoModel class]]) {
        self.titleLabel.text = [NSString stringWithFormat:@"%@", videoModel.title];
        if (NSRunLoop.currentRunLoop.currentMode != UITrackingRunLoopMode) {
            [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:videoModel.coverUrl]];
        }
    } else {
        self.titleLabel.text = @"";
        self.coverImgView.image = nil;
    }
}


@end
