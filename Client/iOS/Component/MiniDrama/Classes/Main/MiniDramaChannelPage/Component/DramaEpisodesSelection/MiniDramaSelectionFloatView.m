// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaSelectionFloatView.h"
#import "MiniDramaSelectionViewController.h"
#import "MiniDramaSelectionCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
#import "MiniDramaEpisodeSectionView.h"

@interface MiniDramaSelectionFloatView ()<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, MiniDramaEpisodeSectionViewDelegate>

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) MDDramaEpisodeInfoModel *curPlayDramaVideoInfo;

@property (nonatomic, strong) MiniDramaEpisodeSectionView *episodeSectionView;
@property (nonatomic, strong) UICollectionView *episodeColloction;
@property (nonatomic, strong) NSArray<MDDramaEpisodeInfoModel *> *currentSectionModels;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) UIButton *unlockButton;

@end

@implementation MiniDramaSelectionFloatView

- (instancetype)initWtihDramaVideoInfo:(MDDramaEpisodeInfoModel *)dramaVideoInfo dramaList:(NSArray<MDDramaEpisodeInfoModel *> *)dramaVideoModels {
    self = [super init];
    if (self) {
        _curPlayDramaVideoInfo = dramaVideoInfo;
        _dramaVideoModels = dramaVideoModels;
        [self configuratoinCustomView];
        self.desLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_selectView_title", @"MiniDrama"), dramaVideoModels.count];
        [self updateCurrentSectionView:self.curPlayDramaVideoInfo];
    }
    return self;
}

- (void)configuratoinCustomView {
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(8);
        make.bottom.equalTo(self).offset(-8);
        make.trailing.equalTo(self.mas_trailing).offset(-20);
        make.width.mas_equalTo(360);
    }];
    
    [self.contentView addSubview:self.headerView];
    [self.headerView addSubview:self.coverImageView];
    [self.headerView addSubview:self.titleLabel];
    [self.headerView addSubview:self.desLabel];
    [self.headerView addSubview:self.unlockButton];
    [self.contentView addSubview:self.episodeSectionView];
    [self.contentView addSubview:self.episodeColloction];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(16);
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(86);
    }];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.equalTo(self.headerView).offset(16);
        make.size.mas_equalTo(CGSizeMake(44, 62));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView).offset(20);
        make.leading.equalTo(self.coverImageView.mas_trailing).with.offset(14);
        make.trailing.equalTo(self.headerView).offset(-108);
    }];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(4);
        make.leading.trailing.equalTo(self.titleLabel);
    }];
    [self.unlockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 32));
        make.trailing.equalTo(self.headerView).offset(-16);
        make.centerY.equalTo(self.headerView);
    }];
    
    [self.episodeSectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.leading.trailing.equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
    
    [self.episodeColloction registerClass:[MiniDramaSelectionCell class] forCellWithReuseIdentifier:MiniDramaSelectionCellReuseID];
    [self.episodeColloction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.episodeSectionView.mas_bottom).offset(5);
        make.leading.trailing.bottom.equalTo(self.contentView);
    }];
}

- (void)updateCurrentSectionView:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    NSInteger res =  dramaVideoInfo.order % EpisodeSectionSegmentCount;
     if (res == 0) {
         self.episodeSectionView.currentTabOrder =  dramaVideoInfo.order / EpisodeSectionSegmentCount - 1;
     } else if (res == dramaVideoInfo.order)  {
         self.episodeSectionView.currentTabOrder = 0;
     }else {
         self.episodeSectionView.currentTabOrder =  dramaVideoInfo.order / EpisodeSectionSegmentCount;
     }
}

- (void)maskViewAction {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

- (void)show{
    UIView *parentView = [DeviceInforTool topViewController].view;
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
}

- (void)setDramaCoverUrl:(NSString *)dramaCoverUrl {
    _dramaCoverUrl = dramaCoverUrl;
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:dramaCoverUrl]
                           placeholderImage:[UIImage imageNamed:@"playcover_default" bundleName:@"VodPlayer"]];
}

- (void)setDramaTitle:(NSString *)dramaTitle {
    _dramaTitle = dramaTitle;
    self.titleLabel.text = dramaTitle;
}

- (void)onClickUnlockAllBtn {
    [self maskViewAction];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickUnlockAllEpisode)]) {
        [self.delegate onClickUnlockAllEpisode];
    }
}

#pragma mark -MiniDramaEpisodeSectionViewDelegate
- (void)onSelectTab:(NSInteger)pageOffset segmentCount:(NSInteger)segmentCount {
    NSInteger location = pageOffset *EpisodeSectionSegmentCount;
    NSRange range;
    if (location + EpisodeSectionSegmentCount > self.dramaVideoModels.count) {
        NSInteger length = self.dramaVideoModels.count - location;
        range = NSMakeRange(location, length);
    } else {
        range = NSMakeRange(location, EpisodeSectionSegmentCount);
    }
    _currentSectionModels = [self.dramaVideoModels subarrayWithRange:range];
    [self.episodeColloction reloadData];
}

#pragma mark ----- UICollectionView Delegate & DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.currentSectionModels.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MDDramaEpisodeInfoModel *dramaVideoModel = [self.currentSectionModels objectAtIndex:indexPath.row];
    MiniDramaSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaSelectionCellReuseID forIndexPath:indexPath];
    cell.dramaVideoInfo = dramaVideoModel;
    cell.curPlayDramaVideoInfo = self.curPlayDramaVideoInfo;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MDDramaEpisodeInfoModel *dramaVideoInfo = [self.currentSectionModels objectAtIndex:indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDramaSelectionCallback:)]) {
        self.curPlayDramaVideoInfo = dramaVideoInfo;
        [self.delegate onDramaSelectionCallback:dramaVideoInfo];
        [self maskViewAction];
    }
}

#pragma mark -Getter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.backgroundColor = [UIColor clearColor];
        _maskView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(maskViewAction)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.layer.cornerRadius = 5;
        _contentView.clipsToBounds = YES;
        _contentView.backgroundColor = [UIColor colorFromRGBHexString:@"#000000" andAlpha:0.7 * 255];
    }
    return _contentView;
}


- (MiniDramaEpisodeSectionView *)episodeSectionView {
    if (!_episodeSectionView) {
        _episodeSectionView = [[MiniDramaEpisodeSectionView alloc] initWith:self.dramaVideoModels.count segmentCount:EpisodeSectionSegmentCount];
        _episodeSectionView.backgroundColor = [UIColor clearColor];
        _episodeSectionView.delegate = self;
    }
    return _episodeSectionView;
}

- (UICollectionView *)episodeColloction {
    if (!_episodeColloction) {
        UICollectionViewFlowLayout *collectionViewlayout = [UICollectionViewFlowLayout new];
        collectionViewlayout.itemSize = CGSizeMake(50, 50);
        collectionViewlayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        collectionViewlayout.minimumLineSpacing = 12.0;
        collectionViewlayout.minimumInteritemSpacing = 10.0;
        collectionViewlayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);
        collectionViewlayout.footerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);
        
        _episodeColloction = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewlayout];
        _episodeColloction.backgroundColor = [UIColor clearColor];
        _episodeColloction.delegate = self;
        _episodeColloction.dataSource = self;
        _episodeColloction.showsHorizontalScrollIndicator = NO;
    }
    return _episodeColloction;
}

- (UIView *)headerView {
    if (_headerView == nil) {
        _headerView = [[UIView alloc] init];
        _headerView.backgroundColor = [UIColor clearColor];
    }
    return _headerView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#CACBCE"];
        _titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    }
    return _titleLabel;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = [UIColor colorFromHexString:@"#76797E"];
        _desLabel.font = [UIFont systemFontOfSize:14];
    }
    return _desLabel;
}

- (UIImageView *)coverImageView {
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc] init];
        _coverImageView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (UIButton *)unlockButton {
    if (!_unlockButton) {
        _unlockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_unlockButton setBackgroundColor:[UIColor colorFromHexString:@"#FFDD99"]];
        [_unlockButton setTitle:LocalizedStringFromBundle(@"mini_drama_unlock_all", @"MiniDrama") forState:UIControlStateNormal];
        [_unlockButton setTitleColor:[UIColor colorFromHexString:@"#703A17"] forState:UIControlStateNormal];
        _unlockButton.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        [_unlockButton setImage:[UIImage imageNamed:@"lock_gold" bundleName:@"MiniDrama"] forState:UIControlStateNormal];
        _unlockButton.layer.cornerRadius = 4;
        _unlockButton.layer.masksToBounds = YES;
        [_unlockButton addTarget:self action:@selector(onClickUnlockAllBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _unlockButton;
}

@end
