// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaSelectionViewController.h"
#import "MiniDramaSelectionCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/UIColor+String.h>
#import <ToolKit/Localizator.h>
#import "MiniDramaEpisodeSectionView.h"

NSString *MiniDramaSelectionCellReuseID = @"MiniDramaSelectionCellReuseID";

NSInteger EpisodeSectionSegmentCount = 5;

@interface MiniDramaSelectionViewController () 
<UICollectionViewDelegate, UICollectionViewDataSource, UIGestureRecognizerDelegate, MiniDramaEpisodeSectionViewDelegate>

@property (nonatomic, strong) MDDramaEpisodeInfoModel *curPlayDramaVideoInfo;
@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, strong) MiniDramaEpisodeSectionView *episodeSectionView;
@property (nonatomic, strong) UICollectionView *episodeColloction;
@property (nonatomic, strong) NSArray<MDDramaEpisodeInfoModel *> *currentSectionModels;

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *coverImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *desLabel;
@property (nonatomic, strong) UIButton *unlockButton;

@end

@implementation MiniDramaSelectionViewController

- (instancetype)initWtihDramaVideoInfo:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    self = [super init];
    if (self) {
        _curPlayDramaVideoInfo = dramaVideoInfo;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configuratoinCustomView];
    [self showSectionView];
}

#pragma mark - UI

- (void)configuratoinCustomView {
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.containerView];

    [self.containerView addSubview:self.headerView];
    [self.containerView addSubview:self.episodeSectionView];
    [self.containerView addSubview:self.episodeColloction];
    
    [self.headerView addSubview:self.coverImageView];
    [self.headerView addSubview:self.titleLabel];
    [self.headerView addSubview:self.desLabel];
    [self.headerView addSubview:self.unlockButton];
    
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(16);
        make.left.right.equalTo(self.containerView);
        make.height.mas_equalTo(86);
    }];
    [self.coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(self.headerView).offset(16);
        make.size.mas_equalTo(CGSizeMake(44, 62));
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView).offset(20);
        make.left.equalTo(self.coverImageView.mas_right).with.offset(14);
        make.right.equalTo(self.headerView).offset(-108);
    }];
    [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(4);
        make.left.right.equalTo(self.titleLabel);
    }];
    [self.unlockButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(90, 32));
        make.right.equalTo(self.headerView).offset(-16);
        make.centerY.equalTo(self.headerView);
    }];

    [self.episodeSectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom);
        make.leading.trailing.equalTo(self.containerView);
        make.height.mas_equalTo(46);
    }];

    [self.episodeColloction registerClass:[MiniDramaSelectionCell class] forCellWithReuseIdentifier:MiniDramaSelectionCellReuseID];
    [self.episodeColloction mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.episodeSectionView.mas_bottom).offset(5);
        make.leading.trailing.bottom.equalTo(self.containerView);
    }];

    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapHandle:)];
    tapGesture.delegate = self;
    [self.view addGestureRecognizer:tapGesture];
}
#pragma mark - Public

- (void)setDramaCoverUrl:(NSString *)dramaCoverUrl {
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:dramaCoverUrl]
                           placeholderImage:[UIImage imageNamed:@"playcover_default" bundleName:@"VodPlayer"]];
}

- (void)setDramaTitle:(NSString *)dramaTitle {
    _dramaTitle = dramaTitle;
    self.titleLabel.text = dramaTitle;
}

- (void)setDramaVideoModels:(NSArray<MDDramaEpisodeInfoModel *> *)dramaVideoModels {
    _dramaVideoModels = dramaVideoModels;
    [self updateCurrentDramaVideoInfo:self.curPlayDramaVideoInfo];
    self.desLabel.text = [NSString stringWithFormat:LocalizedStringFromBundle(@"mini_drama_selectView_title", @"MiniDrama"), dramaVideoModels.count];
}

- (void)updateCurrentDramaVideoInfo:(MDDramaEpisodeInfoModel *)dramaVideoInfo {
    _curPlayDramaVideoInfo = dramaVideoInfo;
    [self updateCurrentSectionView:dramaVideoInfo];
    [self.episodeColloction reloadData];
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

#pragma mark - Private

- (void)showSectionView {
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) / 2, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame) / 2.0);
    } completion:^(BOOL finished) {
        
    }];
}

- (void)close {
    [UIView animateWithDuration:0.3f animations:^{
        self.containerView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame) / 2.0);
    } completion:^(BOOL finished) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onCloseHandleCallback)]) {
            [self.delegate onCloseHandleCallback];
        }
    }];
}

- (void)onClickUnlockAllBtn {
    [self close];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickUnlockAllEpisode)]) {
        [self.delegate onClickUnlockAllEpisode];
    }
}
#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isDescendantOfView:self.episodeColloction]) {
        return NO;
    } else if ([touch.view isDescendantOfView:self.headerView]){
        return NO;
    }
    return YES;
}

#pragma mark - Event
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    return !CGRectContainsPoint(self.containerView.frame, point);
}

- (void)onTapHandle:(UIGestureRecognizer *)gestureReco {
    [self close];
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
        [self close];
    }
}

#pragma mark ----- lazy load
- (UIView *)containerView {
    if (_containerView == nil) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.frame) / 2.0 + 20)];
        _containerView.backgroundColor = [UIColor blackColor];
        _containerView.layer.cornerRadius = 16;
        _containerView.layer.masksToBounds = YES;
    }
    return _containerView;
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
        
        CGFloat width = ([UIScreen mainScreen].bounds.size.width - 16 * 2 - 5 * 10) / 6.0;
        CGFloat height = width;
        
        collectionViewlayout.itemSize = CGSizeMake(width, height);
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
@end
