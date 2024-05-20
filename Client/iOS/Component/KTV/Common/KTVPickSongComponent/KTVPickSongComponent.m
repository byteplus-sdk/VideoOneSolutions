// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "KTVPickSongComponent.h"
#import "KTVDownloadMusicComponent.h"
#import "KTVPickSongTopView.h"
#import "KTVPickSongListView.h"
#import "KTVRTSManager.h"

@interface KTVPickSongComponent ()

@property (nonatomic, copy) NSString *roomID;

@property (nonatomic, weak) UIView *superView;
@property (nonatomic, strong) UIView *pickSongView;
@property (nonatomic, strong) UIView *backView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) KTVPickSongTopView *topView;
@property (nonatomic, strong) KTVPickSongListView *onlineListView;
@property (nonatomic, strong) KTVPickSongListView *pickedListView;

@property (nonatomic, assign) BOOL isRequesting;
@property (nonatomic, strong) NSMutableArray<KTVSongModel*> *waitingDownloadArray;

@end

@implementation KTVPickSongComponent

- (instancetype)initWithSuperView:(UIView *)superView roomID:(nonnull NSString *)roomID {
    if (self = [super init]) {
        self.superView = superView;
        self.roomID = roomID;
        
        [self setupView];
    }
    return self;
}

- (void)requestMusicListWithBlock:(void(^)(NSArray <KTVSongModel *> *musicList))complete {
    [self requestOnlineSongListWithBlock:complete];
    [self requestPickedSongList];
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

- (void)show {
    [self.superView addSubview:self.pickSongView];
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.bottom = SCREEN_HEIGHT;
    }];
    [self changedSongListView:0];
    [self.topView changedSelectIndex:0];
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

- (void)downloadMusicModel:(KTVSongModel *)songModel {
    if (self.isRequesting) {
        // Currently downloading, add songs to the waiting array
        songModel.status = KTVSongModelStatusWaitingDownload;
        [self.waitingDownloadArray addObject:songModel];
        [self updateUI];
        return;
    }
    [self downloadMusic:songModel];
}

- (NSArray <KTVSongModel *> *)getOnlineMusicList {
    return self.onlineListView.dataArray;
}

#pragma mark - Network request Method

- (void)requestOnlineSongListWithBlock:(void(^)(NSArray <KTVSongModel *> *))complete {
    __weak typeof(self) weakSelf = self;
    [KTVRTSManager getPresetSongList:self.roomID
                               block:^(NSArray<KTVSongModel *> * _Nonnull songList,
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
    [KTVRTSManager requestPickedSongList:self.roomID
                                   block:^(RTSACKModel * _Nonnull model, NSArray<KTVSongModel *> * _Nonnull list) {
        weakSelf.pickedListView.dataArray = list;
        [weakSelf syncSongListStstus];
        
        if ([weakSelf.delegate respondsToSelector:@selector(ktvPickSongComponent:pickedSongCountChanged:)]) {
            [weakSelf.delegate ktvPickSongComponent:weakSelf pickedSongCountChanged:list.count];
        }
        [weakSelf updateUI];
    }];
}

- (void)downloadMusic:(KTVSongModel *)songModel {
    self.isRequesting = YES;
    songModel.status = KTVSongModelStatusDownloading;
    [self updateUI];
    __weak typeof(self) weakSelf = self;
    KTVManagerType type = KTVManagerTypeMusic | KTVManagerTypeLyric;
    [[KTVDownloadMusicComponent shared] downloadMusicModel:songModel
                                                      type:type
                                                  complete:^(KTVDownloadSongModel *downloadModel) {
        if (NOEmptyStr(downloadModel.musicPath)) {
            [weakSelf requestPickSong:downloadModel.songModel];
        } else {
            [[ToastComponent shareToastComponent] showWithMessage:LocalizedString(@"toast_false_song_download")];
            songModel.status = KTVSongModelStatusDownloaded;
            songModel.isPicked = NO;
            [weakSelf updateUI];
            [weakSelf executeQueue];
        }
    }];
}

- (void)requestPickSong:(KTVSongModel *)songModel {
    __weak __typeof(self) wself = self;
    [KTVRTSManager pickSong:songModel
                     roomID:self.roomID
                      block:^(RTSACKModel * _Nonnull model) {
        if (!model.result) {
            [[ToastComponent shareToastComponent] showWithMessage:model.message];
            songModel.isPicked = NO;
            songModel.status = KTVSongModelStatusNormal;
            [wself updateUI];
        } else {
            songModel.isPicked = YES;
            songModel.status = KTVSongModelStatusDownloaded;
            [wself updateUI];
        }
        [wself executeQueue];
    }];
}

#pragma mark - Download queue

- (void)executeQueue {
    if (self.waitingDownloadArray.count > 0) {
        KTVSongModel *songModel = [self.waitingDownloadArray firstObject];
        [self.waitingDownloadArray removeObjectAtIndex:0];
        [self downloadMusic:songModel];
    } else {
        self.isRequesting = NO;
    }
}

#pragma mark - Private Action

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
        } else {
            [self.onlineListView refreshView];
        }
    }
}

- (void)syncSongListStstus {
    for (KTVSongModel *model in self.onlineListView.dataArray) {
        model.isPicked = NO;
        for (KTVSongModel *pickedModel in self.pickedListView.dataArray) {
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

#pragma mark - Getter

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
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 364 + 44 + [DeviceInforTool getVirtualHomeHeight])];
        _contentView.backgroundColor = [UIColor colorFromHexString:@"#000000"];
    }
    return _contentView;
}

- (KTVPickSongTopView *)topView {
    if (!_topView) {
        _topView = [[KTVPickSongTopView alloc] init];
        __weak typeof(self) weakSelf = self;
        _topView.selectedChangedBlock = ^(NSInteger index) {
            [weakSelf changedSongListView:index];
        };
    }
    return _topView;
}

- (KTVPickSongListView *)onlineListView {
    if (!_onlineListView) {
        _onlineListView = [[KTVPickSongListView alloc] initWithType:KTVSongListViewTypeOnline];
        __weak typeof(self) weakSelf = self;
        _onlineListView.pickSongBlock = ^(KTVSongModel * _Nonnull songModel) {
            [weakSelf downloadMusicModel:songModel];
        };
    }
    return _onlineListView;
}

- (KTVPickSongListView *)pickedListView {
    if (!_pickedListView) {
        _pickedListView = [[KTVPickSongListView alloc] initWithType:KTVSongListViewTypePicked];
        _pickedListView.hidden = YES;
    }
    return _pickedListView;
}

- (NSMutableArray<KTVSongModel *> *)waitingDownloadArray {
    if (!_waitingDownloadArray) {
        _waitingDownloadArray = [NSMutableArray array];
    }
    return _waitingDownloadArray;
}


@end
