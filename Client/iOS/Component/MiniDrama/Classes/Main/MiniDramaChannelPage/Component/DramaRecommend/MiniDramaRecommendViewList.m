// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaRecommendViewList.h"
#import "MiniDramaRecommendViewListCell.h"
#import "BTDMacros.h"
#import "NetworkingManager+MiniDrama.h"
#import <Masonry/Masonry.h>
#import <ToolKit/UIImage+Bundle.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>


static CGFloat UIDesignScreenHeight = 744;
static CGFloat UIDesigneViewHeight = 576;
static NSInteger MiniDramaVideoRecomendPageCount = 5;

@interface MiniDramaRecommendViewList () <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UIImageView *tagIcon;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UITableView *playListTable;

@property (nonatomic, assign) CGFloat viewHeight;

@end

@implementation MiniDramaRecommendViewList

- (instancetype)init
{
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
        tap.delegate = self;
        [self addGestureRecognizer:tap];
        _viewHeight = UIDesigneViewHeight / UIDesignScreenHeight * [UIScreen mainScreen].bounds.size.height;
        [self configCustomview];
    }
    return self;
}

- (void)showInView:(UIView *)superview {
    [self loadData];
    [superview addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview);
    }];
    
    self.contentView.transform = CGAffineTransformMakeTranslation(0, self.viewHeight);
    @weakify(self);
    [UIView animateWithDuration:0.5 animations:^{
        @strongify(self);
        self.contentView.transform  = CGAffineTransformMakeTranslation(0, 0);
    } completion:nil];
}

- (void)close {
    @weakify(self);

    [UIView animateWithDuration:0.5 animations:^{
        @strongify(self);
        self.contentView.transform = CGAffineTransformMakeTranslation(0, self.viewHeight);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)loadData {
    @weakify(self);
    [NetworkingManager getDramaDataForChannelPage:NSMakeRange(0, MiniDramaVideoRecomendPageCount) success:^(NSArray<MDDramaFeedInfo *> * _Nonnull list) {
        @strongify(self);
        dispatch_queue_async_safe(dispatch_get_main_queue(), ^{
            self.playList = list;
        });
    } failure:^(NSString * _Nonnull errMessage) {
        [[ToastComponent shareToastComponent] showWithMessage:errMessage];

    }];
}

#pragma mark - Private Methods
- (void)configCustomview {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.height.mas_equalTo(self.viewHeight);
        make.bottom.equalTo(self);
    }];
    
    [self.contentView addSubview:self.tagIcon];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.closeButton];
    [self.contentView addSubview:self.playListTable];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(14);
        make.centerX.equalTo(self.contentView);
    }];
    
    [self.tagIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.titleLabel.mas_left).offset(-8);
        make.size.mas_equalTo(CGSizeMake(12, 12));
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleLabel);
        make.right.equalTo(self.contentView).offset(-16);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.playListTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.contentView);
        make.top.equalTo(self.titleLabel).offset(22);
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    return !CGRectContainsPoint(self.contentView.frame, point);
}

#pragma mark UITableViewDelegate&UITableViewDataSource

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_playListTable deselectRowAtIndexPath:indexPath animated:NO];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onClickRecommendVideoCallback:)]) {
        [self.delegate onClickRecommendVideoCallback:self.playList[indexPath.row]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MiniDramaRecommendViewListCell *cell = [tableView dequeueReusableCellWithIdentifier:MiniDramaRecommendViewListCellIdentify
                                                                           forIndexPath:indexPath];
    cell.model =  self.playList[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.playList.count;
}

- (void)setPlayList:(NSArray<MDDramaFeedInfo *> *)playList {
    _playList = playList;
    [self.playListTable reloadData];
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor blackColor];
    }
    return _contentView;
}

- (UIImageView *)tagIcon {
    if (!_tagIcon) {
        _tagIcon = [[UIImageView alloc] init];
        _tagIcon.image = [UIImage imageNamed:@"mini_drama_lisr_packet" bundleName:@"MiniDrama"];
    }
    return _tagIcon;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.text = LocalizedStringFromBundle(@"mini_drama_list_table_title", @"MiniDrama");
    }
    return _titleLabel;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"white_close" bundleName:@"ToolKit"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UITableView *)playListTable {
    if (!_playListTable) {
        _playListTable = [[UITableView alloc] init];
        _playListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _playListTable.delegate = self;
        _playListTable.dataSource = self;
        [_playListTable registerClass:[MiniDramaRecommendViewListCell class] forCellReuseIdentifier:MiniDramaRecommendViewListCellIdentify];
        _playListTable.backgroundColor = [UIColor clearColor];
    }
    return _playListTable;
}
@end
