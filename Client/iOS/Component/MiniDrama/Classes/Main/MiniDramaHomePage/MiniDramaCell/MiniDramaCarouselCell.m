//
//  MiniDramaCarouselCell.m
//  Pods
//
//  Created by ByteDance on 2024/11/15.
//

#import "MiniDramaCarouselCell.h"

@interface MiniDramaCarouselCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) BaseButton *playNowButton;

@end

@implementation MiniDramaCarouselCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

#pragma mark - UI
-(void) initViews {
    [self addSubview:self.imageView];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self);
    }];
    [self addSubview:self.playNowButton];
    [self.playNowButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.equalTo(self).mas_offset(-18);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(120);
    }];
}

#pragma mark - lazy load

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 8;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (BaseButton *)playNowButton{
    if (!_playNowButton) {
        _playNowButton = [[BaseButton alloc] init];
        [_playNowButton setImage:[UIImage imageNamed:@"mini_drama_play_now" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
        _playNowButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_playNowButton addTarget:self action:@selector(tapPlayNow) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playNowButton;
}

- (void)setDramaInfoModel:(MDDramaInfoModel *)dramaInfoModel{
    [super setDramaInfoModel:dramaInfoModel];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:dramaInfoModel.dramaCoverUrl]];
}

-(void)tapPlayNow {
    [self.selectDelegate didMiniDramaSelectItem:self.dramaInfoModel];
}
@end
