//
//  MiniDramaSelectionView.m
//  MDPlayModule
//

#import "MiniDramaSelectionTabView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/UIImage+Bundle.h>


@interface MiniDramaSelectionTabView ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation MiniDramaSelectionTabView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuratoinCustomView];
    }
    return self;
}

- (void)configuratoinCustomView {
    self.layer.cornerRadius = 18;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    
    [self addSubview:self.iconImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.arrowImageView];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(16);
        make.size.mas_equalTo(CGSizeMake(20, 20));
        make.centerY.equalTo(self);
    }];
    
    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
        make.centerY.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).with.offset(4);
        make.right.equalTo(self.arrowImageView.mas_left).with.offset(-4);
        make.centerY.equalTo(self);
    }];
    
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickHandle)];
    [self addGestureRecognizer:tapGes];
}

#pragma mark - Event

- (void)onClickHandle {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickDramaSelectionCallback)]) {
        [self.delegate onClickDramaSelectionCallback];
    }
}

#pragma mark - public
- (void)setEpisodeCount:(NSInteger)episodeCount {
    self.titleLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_selectbar_title", @"MiniDrama"), episodeCount];
}

#pragma mark - lazy load

- (UIImageView *)iconImageView {
    if (_iconImageView == nil) {
        _iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"total_episode_icon" bundleName:@"MiniDrama"]];
    }
    return _iconImageView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        self.titleLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_selectbar_title", @"MiniDrama"), 0];
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (_arrowImageView == nil) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_up" bundleName:@"MiniDrama"]];
    }
    return _arrowImageView;
}

@end
