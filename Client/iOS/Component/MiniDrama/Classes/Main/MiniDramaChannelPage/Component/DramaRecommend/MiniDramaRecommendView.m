//
//  MiniDramaRecommendView.m
//  MiniDrama
//
//  Created by ByteDance on 2024/11/20.
//

#import "MiniDramaRecommendView.h"
#import "MDDramaFeedInfo.h"
#import "MiniDramaRecommendViewList.h"
#import "BTDMacros.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>


@interface MiniDramaRecommendView ()

@property (nonatomic, strong) UIImageView *tagIcon;
@property (nonatomic, strong) UIImageView *arrowIcon;
@property (nonatomic, strong) UILabel *titleLabel;

@end


@implementation MiniDramaRecommendView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorFromRGBHexString:@"#07080A" andAlpha:0.4 * 255];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleClick)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
        [self configCustomView];
    }
    return self;
}

- (void)configCustomView {
    [self addSubview:self.tagIcon];
    [self addSubview:self.titleLabel];
    [self addSubview:self.arrowIcon];
    
    [self.tagIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(10);
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.centerY.equalTo(self);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self.tagIcon.mas_right).offset(6);
    }];
    
    [self.arrowIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(12, 12));
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-10);
    }];
}


- (void)reloadData:(MDDramaFeedInfo *)dramaVideoInfo {
    self.titleLabel.text = LocalizedStringFromBundle(@"mini_drama_list_label", @"MiniDrama");
}

#pragma mark - Private Methods
- (void)handleClick {
    if ([self.delegate respondsToSelector:@selector(onShowRecommentList)]) {
        [self.delegate onShowRecommentList];
    }
}

#pragma mark - Getter
- (UIImageView *)tagIcon {
    if (!_tagIcon) {
        _tagIcon = [[UIImageView alloc] init];
        _tagIcon.image = [UIImage imageNamed:@"mini_drama_lisr_packet" bundleName:@"MiniDrama"];
    }
    return _tagIcon;
}

- (UIImageView *)arrowIcon {
    if (!_arrowIcon) {
        _arrowIcon = [[UIImageView alloc] init];
        _arrowIcon.image = [UIImage imageNamed:@"arrow_right" bundleName:@"MiniDrama"];
    }
    return _arrowIcon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

@end
