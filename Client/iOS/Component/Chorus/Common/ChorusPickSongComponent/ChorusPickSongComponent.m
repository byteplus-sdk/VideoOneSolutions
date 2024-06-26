// 
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
// 

#import "ChorusPickSongComponent.h"
#import "ChorusPickSongTopView.h"
#import "ChorusDownloadMusicComponent.h"
#import "ChorusPickSongListView.h"
#import "ChorusRTSManager.h"

@interface ChorusPickSongComponent ()

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, strong) UIView *pickSongView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) ChorusPickSongTopView *topView;
@property (nonatomic, strong) ChorusPickSongListView *onlineListView;
@property (nonatomic, strong) ChorusPickSongListView *pickedListView;

@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray<ChorusSongModel*> *waitingDownloadArray;

@end

@implementation ChorusPickSongComponent

- (instancetype)initWithSuperView:(UIView *)superView roomID:(nonnull NSString *)roomID {
    if (self = [super init]) {
        self.superView = superView;
        self.roomID = roomID;
        
        [self setupView];
    }
    return self;
}

- (void)setupView {
    [self.pickSongView addSubview:self.backView];
    [self.pickSongView addSubview:self.contentView];
    [self.contentView addSubview:self.topView];
    [self.contentView addSubview:self.onlineListView];
    [self.contentView addSubview:self.pickedListView];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.equalTo(self.contentView);
    }];
    [self.onlineListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.contentView);
        make.top.equalTo(self.topView.mas_bottom);
    }];
    [self.pickedListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.onlineListView);
    }];
}

#pragma mark - Publish Action

- (void)pickSong:(ChorusSongModel *)songModel {
    if (self.isRequesting) {
        // Currently downloading, add songs to the waiting array
        songModel.status = ChorusSongModelStatusWaitingDownload;
        [self.waitingDownloadArray addObject:songModel];
        [self updateUI];
        return;
    }
    [self downloadMusic:songModel];
}

- (void)requestMusicListWithBlock:(void(^)(NSArray <ChorusSongModel *> *musicList))complete {
    [self requestOnlineSongListWithBlock:complete];
    [self requestPickedSongList];
}

#pragma mark - Network request Method

- (void)requestOnlineSongListWithBlock:(void(^)(NSArray <ChorusSongModel *> *))complete {
    __weak typeof(self) weakSelf = self;
    [ChorusRTSManager getPresetSongList:@""
                                  block:^(NSArray<ChorusSongModel *> * _Nonnull songList,
                                       RTSACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
        } else {
            weakSelf.onlineListView.dataArray = songList;
            [weakSelf updateUI];
        }
        if (complete) {
            complete(songList);
        }
    }];
}

- (void)requestPickedSongList {
    __weak typeof(self) weakSelf = self;
    [ChorusRTSManager requestPickedSongList:self.roomID block:^(RTSACKModel * _Nonnull model, NSArray<ChorusSongModel *> * _Nonnull list) {
        
        weakSelf.pickedListView.dataArray = list;
        [weakSelf syncSongListStstus];
        
        if ([weakSelf.delegate respondsToSelector:@selector(ChorusPickSongComponent:pickedSongCountChanged:)]) {
            [weakSelf.delegate ChorusPickSongComponent:weakSelf pickedSongCountChanged:list.count];
        }
        [weakSelf updateUI];
    }];
}

- (void)downloadMusic:(ChorusSongModel *)songModel {
    self.isRequesting = YES;
    songModel.status = ChorusSongModelStatusDownloading;
    [self updateUI];
    __weak typeof(self) weakSelf = self;
    ChorusManagerType type = ChorusManagerTypeMusic | ChorusManagerTypeLyric;
    [[ChorusDownloadMusicComponent shared] downloadMusicModel:songModel
                                                      type:type
                                                  complete:^(ChorusDownloadSongModel *downloadModel) {
        if (NOEmptyStr(downloadModel.musicPath)) {
            [weakSelf requestPickSong:downloadModel.songModel];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_false_song_download")];
            songModel.status = ChorusSongModelStatusDownloaded;
            songModel.isPicked = NO;
            [weakSelf updateUI];
            [weakSelf executeQueue];
        }
    }];
}

- (void)requestPickSong:(ChorusSongModel *)songModel {
    __weak __typeof(self) wself = self;
    [ChorusRTSManager pickSong:songModel
                        roomID:self.roomID
                         block:^(RTSACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
            songModel.isPicked = NO;
            songModel.status = ChorusSongModelStatusNormal;
            [wself updateUI];
        } else {
            songModel.isPicked = YES;
            songModel.status = ChorusSongModelStatusDownloaded;
            [wself updateUI];
        }
        [wself executeQueue];
    }];
}

#pragma mark - Download queue

- (void)executeQueue {
    if (self.waitingDownloadArray.count > 0) {
        ChorusSongModel *songModel = [self.waitingDownloadArray firstObject];
        [self.waitingDownloadArray removeObjectAtIndex:0];
        [self downloadMusic:songModel];
    } else {
        self.isRequesting = NO;
    }
}

#pragma mark - Private Action

- (void)show {
    [self.superView addSubview:self.pickSongView];
    [self updateUI];
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.bottom = SCREEN_HEIGHT;
    }];
}

- (void)dismissView {
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.top = SCREEN_HEIGHT;
    } completion:^(BOOL finished) {
        [self.pickSongView removeFromSuperview];
    }];
}

- (void)showPickedSongList {
    [self.superView addSubview:self.pickSongView];
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.bottom = SCREEN_HEIGHT;
    }];
    [self changedSongListView:1];
    [self.topView changedSelectIndex:1];
}

- (void)changedSongListView:(NSInteger)index {
    if (index == 0) {
        self.onlineListView.hidden = NO;
        self.pickedListView.hidden = YES;
    } else {
        self.onlineListView.hidden = YES;
        self.pickedListView.hidden = NO;
    }
    
    [self updateUI];
}

- (void)updateUI {
    if (self.pickSongView.superview) {
        
        [self.topView updatePickedSongCount:self.pickedListView.dataArray.count];
        
        if (self.onlineListView.isHidden) {
            [self.pickedListView refreshView];
        }
        else {
            [self.onlineListView refreshView];
        }
    }
}

- (void)refreshDownloadStstus:(ChorusSongModel *)model {

    [self updateUI];
}

- (void)syncSongListStstus {
    for (ChorusSongModel *model in self.onlineListView.dataArray) {
        model.isPicked = NO;
        for (ChorusSongModel *pickedModel in self.pickedListView.dataArray) {
            if ([pickedModel.pickedUserID isEqualToString:[LocalUserComponent userModel].uid] &&
                [pickedModel.musicId isEqualToString:model.musicId]) {
                model.isPicked = YES;
            }
        }
    }
}

- (void)updatePickedSongList {
    [self requestPickedSongList];
}

#pragma mark - getter

- (UIView *)pickSongView {
    if (!_pickSongView) {
        _pickSongView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
    }
    return _pickSongView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [[UIView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        [_backView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)]];
    }
    return _backView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 360 + 48)];
        _contentView.backgroundColor = [[UIColor colorFromHexString:@"#0E0825F2"] colorWithAlphaComponent:0.95];
    }
    return _contentView;
}

- (ChorusPickSongTopView *)topView {
    if (!_topView) {
        _topView = [[ChorusPickSongTopView alloc] init];
        __weak typeof(self) weakSelf = self;
        _topView.selectedChangedBlock = ^(NSInteger index) {
            [weakSelf changedSongListView:index];
        };
    }
    return _topView;
}

- (ChorusPickSongListView *)onlineListView {
    if (!_onlineListView) {
        _onlineListView = [[ChorusPickSongListView alloc] initWithType:ChorusSongListViewTypeOnline];
        __weak typeof(self) weakSelf = self;
        _onlineListView.pickSongBlock = ^(ChorusSongModel * _Nonnull songModel) {
            [weakSelf pickSong:songModel];
        };
    }
    return _onlineListView;
}

- (ChorusPickSongListView *)pickedListView {
    if (!_pickedListView) {
        _pickedListView = [[ChorusPickSongListView alloc] initWithType:ChorusSongListViewTypePicked];
        _pickedListView.hidden = YES;
    }
    return _pickedListView;
}

- (NSMutableArray<ChorusSongModel *> *)waitingDownloadArray {
    if (!_waitingDownloadArray) {
        _waitingDownloadArray = [NSMutableArray array];
    }
    return _waitingDownloadArray;
}

@end
