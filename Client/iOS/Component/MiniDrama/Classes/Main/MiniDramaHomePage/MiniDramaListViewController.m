// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaListViewController.h"
#import "MiniDramaVideoViewNormalCell.h"
#import "MDDramaInfoModel.h"
#import <Masonry/Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import <ToolKit/UIColor+String.h>
#import "MiniDramaCarouselView.h"
#import <NetworkingManager+MiniDrama.h>
#import <ToolKit/ToolKit.h>
#import "MinidramaHeaderCell.h"
#import "MiniDramaTrendingCell.h"
#import "MiniDramaNewCell.h"
#import "MiniDramaDetailFeedViewController.h"
#import "MiniDramaLandscapeViewController.h"
#import "MDDramaEpisodeInfoModel.h"
#import "MDVideoEnginePool.h"
#import "MDVideoPlayerController+Resolution.h"
#import "VESettingManager.h"
#import <ToolKit/LocalUserComponent.h>

static BOOL MDHomeEnhancedPreloadEnabled(void) {
    return [[[VESettingManager universalManager] settingForKey:VESettingKeyMiniDramaHomeEnhancedPreload] open];
}
static const BOOL MDHomeFeedOnlyEnabled = NO; // YES: use only entries already supplied by the home feed; do not request the episode list.
static const BOOL MDHomeWarmupEnabled = YES; // One-time home page prerendering, enabled by default.


static BOOL MDHomeEntryValid(MDDramaInfoModel *drama) {
    MDDramaEpisodeInfoModel *entry = drama.preloadEntry;
    return entry && !entry.vip && entry.videoId.length && entry.playAuthToken.length &&
        drama.preloadEntryValidUntil > NSDate.date.timeIntervalSince1970 &&
        [drama.preloadEntryUserID isEqualToString:[LocalUserComponent userModel].uid] &&
        [entry.dramaId isEqualToString:drama.dramaId];
}

@interface MDHomePreloadTask : NSObject
@property (nonatomic, strong) MDDramaInfoModel *drama;
@property (nonatomic, strong) NSURLSessionDataTask *request;
@property (nonatomic, strong) id<TTVideoEngineMediaSource> source;
@property (nonatomic, assign) BOOL mediaStarted;
@property (nonatomic, assign) BOOL finished;
@end
@implementation MDHomePreloadTask
@end

// Entry lookup and media download share one slot; stale callbacks cannot restart a canceled task.
@interface MDDramaHomePreloader : NSObject
@property (nonatomic, strong) MDCacheLoader *loader;
@property (nonatomic, strong) MDPlaybackWarmup *warmup;
@property (nonatomic, strong) NSMutableDictionary<NSString *, MDHomePreloadTask *> *tasks;
@property (nonatomic, copy) NSArray<MDDramaInfoModel *> *candidates;
@property (nonatomic, copy) NSString *contextIdentity;
@property (nonatomic, copy) BOOL (^canAdd)(void);
- (void)updateCandidates:(NSArray<MDDramaInfoModel *> *)candidates retain:(NSArray<MDDramaInfoModel *> *)retained;
- (void)stop;
@end

@implementation MDDramaHomePreloader
- (instancetype)init {
    if ((self = [super init])) {
        _loader = [MDCacheLoader new];
        _warmup = [MDPlaybackWarmup new];
        _tasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)cancelTask:(MDHomePreloadTask *)task {
    [self.tasks removeObjectForKey:task.drama.dramaId];
    [task.request cancel];
    if (task.source) [self.loader stopTask:task.source];
}

- (void)updateCandidates:(NSArray<MDDramaInfoModel *> *)candidates retain:(NSArray<MDDramaInfoModel *> *)retained {
    NSString *context = [NSString stringWithFormat:@"%@/%ld/%d/%d", [LocalUserComponent userModel].uid,
                         (long)[MDVideoPlayerController getPlayerCurrentResolution],
                         [[[VESettingManager universalManager] settingForKey:VESettingKeyUniversalABRConfig] open],
                         MDHomeEnhancedPreloadEnabled()];
    if (![context isEqualToString:self.contextIdentity]) {
        [self stop];
        self.contextIdentity = context;
    }
    self.candidates = candidates;
    NSMutableSet *keep = [NSMutableSet set];
    for (MDDramaInfoModel *drama in retained) if (drama.dramaId.length) [keep addObject:drama.dramaId];
    if (!MDHomeEnhancedPreloadEnabled() && self.canAdd && self.canAdd()) {
        [keep removeAllObjects];
        for (MDDramaInfoModel *drama in candidates) {
            if (drama.dramaId.length && (!MDHomeFeedOnlyEnabled || MDHomeEntryValid(drama))) [keep addObject:drama.dramaId];
            if (keep.count == 2) break;
        }
    }
    for (MDHomePreloadTask *task in self.tasks.allValues) {
        BOOL invalid = task.source && (!MDHomeEntryValid(task.drama) ||
            ![MDSourceIdentity(task.source) isEqualToString:MDSourceIdentity([MDDramaEpisodeInfoModel videoEngineVidSource:task.drama.preloadEntry])]);
        if (![keep containsObject:task.drama.dramaId] || invalid) {
            [self cancelTask:task];
        }
    }
    [self reconcile];
}

- (void)reconcile {
    if (!self.canAdd || !self.canAdd()) return;
    NSUInteger occupied = 0;
    for (MDHomePreloadTask *task in self.tasks.allValues) {
        if (!MDHomeEnhancedPreloadEnabled() || !task.finished) occupied++;
    }
    NSUInteger limit = MDHomeEnhancedPreloadEnabled() ? 9 : 2;
    NSMutableSet *candidateIDs = [NSMutableSet set];
    for (MDDramaInfoModel *drama in self.candidates) if (drama.dramaId.length) [candidateIDs addObject:drama.dramaId];
    for (MDDramaInfoModel *drama in self.candidates) {
        if (!drama.dramaId.length) continue;
        MDHomePreloadTask *task = self.tasks[drama.dramaId];
        if (task) {
            if (task.source && !task.mediaStarted && !task.finished) [self startMedia:task];
            continue;
        }
        if (occupied >= limit && MDHomeEnhancedPreloadEnabled()) {
            // Keep only existing tasks behind the viewport; free a slot when a new visible item needs it.
            for (MDHomePreloadTask *old in self.tasks.allValues) {
                if (!old.finished && ![candidateIDs containsObject:old.drama.dramaId]) {
                    [self cancelTask:old];
                    occupied--;
                    break;
                }
            }
        }
        if (occupied >= limit) {
            break;
        }
        if (!MDHomeEntryValid(drama)) {
            drama.preloadEntry = nil;
            if (MDHomeFeedOnlyEnabled) continue;
        }
        task = [MDHomePreloadTask new];
        task.drama = drama;
        self.tasks[drama.dramaId] = task;
        occupied++;
        if (MDHomeEntryValid(drama)) {
            task.source = [MDDramaEpisodeInfoModel videoEngineVidSource:drama.preloadEntry];
            [self startMedia:task];
        } else {
            [self lookupEntry:task];
        }
    }
}

- (void)lookupEntry:(MDHomePreloadTask *)task {
    __weak typeof(self) weakSelf = self;
    NSString *context = self.contextIdentity;
    task.request = [NetworkingManager getDramaDataForDetailPage:task.drama.dramaId success:^(NSArray<MDDramaEpisodeInfoModel *> *list) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MDDramaHomePreloader *owner = weakSelf;
            if (!owner || owner.tasks[task.drama.dramaId] != task || ![owner.contextIdentity isEqual:context]) {
                return;
            }
            task.request = nil;
            MDDramaEpisodeInfoModel *entry = nil;
            for (MDDramaEpisodeInfoModel *model in list) {
                if (!model.vip && model.videoId.length && model.playAuthToken.length) { entry = model; break; }
            }
            if (!entry) {
                task.finished = YES;
                if (MDHomeEnhancedPreloadEnabled()) [owner reconcile];
                return;
            }
            // Use the first playable episode from the existing API. Use FEED_ONLY when the client provides a resume entry.
            entry.dramaId = task.drama.dramaId;
            task.drama.preloadEntry = entry;
            task.drama.preloadEntryUserID = [LocalUserComponent userModel].uid;
            task.drama.preloadEntryValidUntil = NSDate.date.timeIntervalSince1970 + 30;
            task.source = [MDDramaEpisodeInfoModel videoEngineVidSource:entry];
            if (owner.canAdd && owner.canAdd()) [owner startMedia:task];
        });
    } failure:^(NSString *message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MDDramaHomePreloader *owner = weakSelf;
            if (!owner || owner.tasks[task.drama.dramaId] != task) return;
            task.request = nil;
            task.finished = YES;
            if (MDHomeEnhancedPreloadEnabled()) [owner reconcile];
        });
    }];
}

- (void)startMedia:(MDHomePreloadTask *)task {
    if (task.mediaStarted || task.finished || self.tasks[task.drama.dramaId] != task) return;
    task.mediaStarted = YES;
    __weak typeof(self) weakSelf = self;
    BOOL accepted = [self.loader preload:task.source bytes:300 * 1024 completion:^(NSError *error) {
        MDDramaHomePreloader *owner = weakSelf;
        if (!owner || owner.tasks[task.drama.dramaId] != task) return;
        task.finished = YES;
        // Do not refill slots in basic mode, so an idle home page does not keep expanding downloads.
        if (MDHomeEnhancedPreloadEnabled()) [owner reconcile];
    }];
    if (!accepted) task.finished = YES;
    if (MDHomeWarmupEnabled) [self.warmup startWithSource:task.source];
}
- (void)stop {
    self.candidates = nil;
    for (MDHomePreloadTask *task in self.tasks.allValues) [self cancelTask:task];
    [self.loader stopAll];
    [self.warmup stop];
}
- (void)dealloc { [self stop]; }
@end

static NSString *MiniDramaCarouselCellReuseID = @"MiniDramaCarouselCellReuseID";
static NSString *MiniDramaTrendingCellReuseID = @"MiniDramaTrendingCellReuseID";
static NSString *MiniDramaNewCellReuseID = @"MiniDramaNewCellReuseID";
static NSString *MiniDramaVideoNormalCellReuseID = @"MiniDramaVideoNormalCellReuseID";
static NSString *MiniDramaVideoHeaderViewReuseID = @"MiniDramaVideoHeaderViewReuseID";
static NSString *MiniDramaVideoHFooterViewReuseID = @"MiniDramaVideoFooterViewReuseID";

@interface MiniDramaListViewController () <UICollectionViewDelegate, 
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
UIScrollViewDelegate,
MiniDramaItemSelectDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) BOOL isLoadingData;

@property (nonatomic, assign)CGSize carouselCellSize;
@property (nonatomic, assign)CGSize trendingCellSize;
@property (nonatomic, assign)CGSize newCellSize;
@property (nonatomic, assign)CGSize normalCellSize;
@property (nonatomic, assign)CGSize headerSize;
@property (nonatomic, weak)MiniDramaCarouselView *carouselView;

@property (nonatomic, strong) MDHomePageData* channelData;
@property (nonatomic, strong) MDDramaHomePreloader *homePreloader;
@property (nonatomic, strong) NSMapTable<UIScrollView *, NSDictionary *> *scrollSamples;
@property (nonatomic, strong) NSHashTable<UIScrollView *> *movingScrollViews;
@property (nonatomic, assign) BOOL preloadUpdatePending;
@property (nonatomic, assign) BOOL preloadPageActive;

@end

@implementation MiniDramaListViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.preloadPageActive = YES;
    [self schedulePreloadUpdate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.preloadPageActive = NO;
    [self.homePreloader stop];
    [self.movingScrollViews removeAllObjects];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.homePreloader = [MDDramaHomePreloader new];
    self.scrollSamples = [NSMapTable weakToStrongObjectsMapTable];
    self.movingScrollViews = [NSHashTable weakObjectsHashTable];
    __weak typeof(self) weakSelf = self;
    self.homePreloader.canAdd = ^BOOL { return [weakSelf canAddHomePreload]; };
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homeEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(schedulePreloadUpdate) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(homePreloadSettingChanged) name:@"MDHomePreloadSettingChanged" object:nil];
    [self initViews];
    [self loadData];
}

- (void)initViews {
    self.view.backgroundColor = [UIColor colorFromHexString:@"#161823"];
    self.carouselCellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 363);
    self.trendingCellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 310);
    self.newCellSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 181);
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 42) / 2.0;
    CGFloat height = width * 284 / 167.0f;
    self.normalCellSize = CGSizeMake(width, height);
    self.headerSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 84);
    
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[MiniDramaCarouselView class] forCellWithReuseIdentifier:MiniDramaCarouselCellReuseID];
    [self.collectionView registerClass:[MiniDramaTrendingCell class] forCellWithReuseIdentifier:MiniDramaTrendingCellReuseID];
    [self.collectionView registerClass:[MiniDramaNewCell class] forCellWithReuseIdentifier:MiniDramaNewCellReuseID];
    [self.collectionView registerClass:[MiniDramaVideoViewNormalCell class] forCellWithReuseIdentifier:MiniDramaVideoNormalCellReuseID];
    [self.collectionView registerClass:[MiniDramaHeaderCell class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MiniDramaVideoHeaderViewReuseID];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:MiniDramaVideoHFooterViewReuseID];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(44);
        } else {
            make.top.equalTo(self.view).offset(64);
        }
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    __weak typeof(self) weakSelf = self;
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [strongSelf loadData];
    }];
    self.collectionView.mj_footer.hidden = YES;
}

- (void)loadData {
    if (self.isLoadingData) {
        return;
    }
    self.isLoadingData = YES;
    self.collectionView.mj_footer.hidden = NO;

    [NetworkingManager getDramaDataForHomePageData:^(MDHomePageData * _Nonnull pageData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView.mj_header endRefreshing];
            self.channelData = pageData;
            [self.homePreloader stop];
            [self.collectionView reloadData];
            self.isLoadingData = NO;
            [self schedulePreloadUpdate];
        });
    } failure:^(NSString * _Nonnull message) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ToastComponent shareToastComponent] showWithMessage:message];
            self.isLoadingData = NO;
        });
    }];
}

- (void)setViewisVisible:(BOOL)viewisVisible {
    _viewisVisible = viewisVisible;
    self.preloadPageActive = viewisVisible;
    if (viewisVisible) [self schedulePreloadUpdate];
    else [self.homePreloader stop];
    if (self.carouselView) {
        self.carouselView.viewisVisible = viewisVisible;
    }
}

#pragma mark --UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self miniDramaScrollViewDidStop:scrollView];
        NSIndexPath *specificIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
        BOOL isVisible = [self isCellVisibleForIndexPath:specificIndexPath];
        if (self.carouselView) {
            self.carouselView.viewisVisible = isVisible;
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self miniDramaScrollViewDidStop:scrollView];
    NSIndexPath *specificIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    BOOL isVisible = [self isCellVisibleForIndexPath:specificIndexPath];
    if (self.carouselView) {
        self.carouselView.viewisVisible = isVisible;
    }
}

- (BOOL)isCellVisibleForIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attributes = [self.collectionView layoutAttributesForItemAtIndexPath:indexPath];
    CGRect itemFrameInCollectionView = attributes.frame;
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, self.collectionView.contentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    return CGRectIntersectsRect(itemFrameInCollectionView, visibleRect);
}

#pragma mark ----- UICollectionView Delegate & DataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.channelData sections].count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSArray *sections = [self.channelData sections];
    switch ([sections[section] integerValue]) {
        case MDDramaSectionTypeLoop:
        case MDDramaSectionTypeTrending:
        case MDDramaSectionTypeNew:
            return 1;
        default:
            return [self.channelData getDramaInfo:[sections[section] integerValue]].count;
    }
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = [self.channelData sections];
    NSInteger sectionType = [sections[indexPath.section] integerValue];
    NSArray<MDDramaInfoModel *> *infos = [self.channelData getDramaInfo:sectionType];
    switch (sectionType) {
        case MDDramaSectionTypeLoop:{
            MiniDramaCarouselView *carouselView = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaCarouselCellReuseID forIndexPath:indexPath];
            carouselView.miniDramaDatas = infos;
            carouselView.selectDelegate = self;
            self.carouselView = carouselView;
            return carouselView;
        }
        case MDDramaSectionTypeTrending:{
            MiniDramaTrendingCell *trendingCell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaTrendingCellReuseID forIndexPath:indexPath];
            trendingCell.miniDramaDatas = infos;
            trendingCell.selectDelegate = self;
            return trendingCell;
        }
        case MDDramaSectionTypeNew:{
            MiniDramaNewCell *newCell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaNewCellReuseID forIndexPath:indexPath];
            newCell.miniDramaDatas = infos;
            newCell.selectDelegate = self;
            return newCell;
        }
            
        default:{
            MiniDramaVideoViewNormalCell *normalCell = [collectionView dequeueReusableCellWithReuseIdentifier:MiniDramaVideoNormalCellReuseID forIndexPath:indexPath];
            normalCell.dramaInfoModel = infos[indexPath.row];
            return normalCell;
        }
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        NSArray *sections = [self.channelData sections];
        NSInteger sectionType = [sections[indexPath.section] integerValue];
        MiniDramaHeaderCell *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:MiniDramaVideoHeaderViewReuseID forIndexPath:indexPath];
        [header setText:[self sectionHeaderText:sectionType]  icon:nil];
        return header;
    } else {
        return [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MiniDramaVideoHFooterViewReuseID forIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return CGSizeZero;
    }
    return self.headerSize;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = [self.channelData sections];
    MDDramaInfoModel *model = [self.channelData getDramaInfo:[sections[indexPath.section] integerValue]][indexPath.row];
    [self didMiniDramaSelectItem:model];
}

#pragma mark - MiniDramaItemSelectDelegate
- (void)didMiniDramaSelectItem:(MDDramaInfoModel *)dramaInfoModel{
    MDHomePreloadTask *task = self.homePreloader.tasks[dramaInfoModel.dramaId ?: @""];
    // The same drama may have different objects across sections; copy its valid entry before stopping tasks.
    if (!MDHomeEntryValid(dramaInfoModel) && MDHomeEntryValid(task.drama)) {
        dramaInfoModel.preloadEntry = task.drama.preloadEntry;
        dramaInfoModel.preloadEntryUserID = task.drama.preloadEntryUserID;
        dramaInfoModel.preloadEntryValidUntil = task.drama.preloadEntryValidUntil;
    }
    [self.homePreloader stop];
    if (!MDHomeEntryValid(dramaInfoModel)) dramaInfoModel.preloadEntry = nil;
    if (dramaInfoModel.dramaDisplayType == MiniDramaVideoDisplayTypeVertical) {
        MiniDramaDetailFeedViewController *vc = [[MiniDramaDetailFeedViewController alloc] initWithDramaInfo:dramaInfoModel];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        MiniDramaLandscapeViewController *vc = [[MiniDramaLandscapeViewController alloc] initWithDramaInfo:dramaInfoModel];
        vc.landscapeMode = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

// Sample both the outer list and horizontal lists; block new tasks if any moving list has an unknown or stale speed.
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView { [self miniDramaScrollViewWillMove:scrollView]; }
- (void)scrollViewDidScroll:(UIScrollView *)scrollView { [self miniDramaScrollViewDidMove:scrollView]; }
- (void)miniDramaScrollViewWillMove:(UIScrollView *)scrollView {
    // Update the preload window during automatic carousel scrolling; stop prerendering only for user scrolling.
    if (scrollView.tracking || scrollView.dragging || scrollView.decelerating) [self.homePreloader.warmup stop];
    [self.movingScrollViews addObject:scrollView];
    [self.scrollSamples setObject:@{@"offset": [NSValue valueWithCGPoint:scrollView.contentOffset], @"time": @(CACurrentMediaTime())} forKey:scrollView];
    [self schedulePreloadUpdate];
}
- (void)miniDramaScrollViewDidMove:(UIScrollView *)scrollView {
    if (scrollView.tracking || scrollView.dragging || scrollView.decelerating) [self.homePreloader.warmup stop];
    if (scrollView.dragging || scrollView.decelerating) [self.movingScrollViews addObject:scrollView];
    CFTimeInterval now = CACurrentMediaTime();
    NSDictionary *previous = [self.scrollSamples objectForKey:scrollView];
    CGPoint offset = scrollView.contentOffset;
    CGPoint old = [previous[@"offset"] CGPointValue];
    double elapsed = now - [previous[@"time"] doubleValue];
    BOOL horizontal = scrollView != self.collectionView;
    double delta = horizontal ? offset.x - old.x : offset.y - old.y;
    if (horizontal && delta != 0) {
        UIView *parent = scrollView.superview;
        while (parent && ![parent isKindOfClass:MiniDramaCollectionViewBaseCell.class]) parent = parent.superview;
        [(MiniDramaCollectionViewBaseCell *)parent setPreloadScrollDirection:delta > 0 ? 1 : -1];
    }
    NSMutableDictionary *sample = [@{@"offset": [NSValue valueWithCGPoint:offset], @"time": @(now), @"direction": @(delta >= 0 ? 1 : -1)} mutableCopy];
    if (previous && elapsed > 0) sample[@"speed"] = @(fabs(delta) / elapsed);
    [self.scrollSamples setObject:sample forKey:scrollView];
    [self schedulePreloadUpdate];
}
- (void)miniDramaScrollViewDidStop:(UIScrollView *)scrollView {
    [self.movingScrollViews removeObject:scrollView];
    [self schedulePreloadUpdate];
}
- (BOOL)canAddHomePreload {
    if (!self.preloadPageActive || UIApplication.sharedApplication.applicationState == UIApplicationStateBackground) return NO;
    if (!self.movingScrollViews.count) return YES;
    if (!MDHomeEnhancedPreloadEnabled()) return NO;
    CFTimeInterval now = CACurrentMediaTime();
    for (UIScrollView *scrollView in self.movingScrollViews) {
        NSDictionary *sample = [self.scrollSamples objectForKey:scrollView];
        if (!sample[@"speed"] || now - [sample[@"time"] doubleValue] > 0.2 || [sample[@"speed"] doubleValue] > 1000) return NO;
    }
    return YES;
}
- (void)schedulePreloadUpdate {
    if (self.preloadUpdatePending) return;
    self.preloadUpdatePending = YES;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        MiniDramaListViewController *owner = weakSelf;
        owner.preloadUpdatePending = NO;
        [owner updateHomePreloadWindow];
    });
}
- (void)updateHomePreloadWindow {
    if (!self.preloadPageActive) return;
    [self.collectionView layoutIfNeeded];
    NSArray<NSIndexPath *> *paths = [self.collectionView.indexPathsForVisibleItems sortedArrayUsingSelector:@selector(compare:)];
    NSMutableArray *visible = [NSMutableArray array];
    NSMutableArray *ahead = [NSMutableArray array];
    NSMutableArray *behind = [NSMutableArray array];
    NSArray *sections = self.channelData.sections;
    NSInteger direction = [[[self.scrollSamples objectForKey:self.collectionView] objectForKey:@"direction"] integerValue] ?: 1;
    for (NSIndexPath *path in paths) {
        MiniDramaCollectionViewBaseCell *cell = (id)[self.collectionView cellForItemAtIndexPath:path];
        [visible addObjectsFromArray:[cell visibleDramaInfosInView:self.collectionView]];
        [ahead addObjectsFromArray:[cell adjacentDramaInfosInDirection:1]];
        [behind addObjectsFromArray:[cell adjacentDramaInfosInDirection:-1]];
    }
    // In the two-column grid, add only one row ahead; keep only existing tasks in the row behind.
    for (NSInteger step = -1; step <= 1; step += 2) {
        NSIndexPath *edge = step * direction > 0 ? paths.lastObject : paths.firstObject;
        if (!edge) continue;
        if (edge.section >= sections.count || [sections[edge.section] integerValue] != MDDramaSectionTypeRecommend) continue;
        NSArray *infos = [self.channelData getDramaInfo:MDDramaSectionTypeRecommend];
        NSInteger row = edge.item / 2;
        NSInteger start = (row + step * direction) * 2;
        for (NSInteger i = start; i < start + 2; i++) {
            if (i >= 0 && i < infos.count) [(step > 0 ? ahead : behind) addObject:infos[i]];
        }
    }
    NSMutableArray *candidates = [visible mutableCopy];
    [candidates addObjectsFromArray:ahead];
    NSMutableArray *retained = [candidates mutableCopy];
    [retained addObjectsFromArray:behind];
    [self.homePreloader updateCandidates:candidates retain:retained];
}
- (void)homeEnterBackground {
    [self.homePreloader stop];
    [self.movingScrollViews removeAllObjects];
}
- (void)homePreloadSettingChanged {
    [self.homePreloader stop];
    [self schedulePreloadUpdate];
}
- (void)dealloc { [[NSNotificationCenter defaultCenter] removeObserver:self]; }

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sections = [self.channelData sections];
    switch ([sections[indexPath.section] integerValue]) {
        case MDDramaSectionTypeLoop:
            return self.carouselCellSize;
        case MDDramaSectionTypeTrending:
            return self.trendingCellSize;
        case MDDramaSectionTypeNew:
            return self.newCellSize;
        default:
            return self.normalCellSize;
    }
}


#pragma mark ----- lazy load

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *viewFlowLayout = [UICollectionViewFlowLayout new];
        
        viewFlowLayout.itemSize = self.normalCellSize;
        viewFlowLayout.sectionInset = UIEdgeInsetsMake(0, 16, 0, 16);
        viewFlowLayout.minimumLineSpacing = 16.0;
        viewFlowLayout.minimumInteritemSpacing = 8.0;
        viewFlowLayout.headerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);
        viewFlowLayout.footerReferenceSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 10);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:viewFlowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
    }
    return _collectionView;
}

-(NSString *)sectionHeaderText:(NSInteger)type {
    switch (type) {
        case MDDramaSectionTypeLoop:
            return @"";
        case MDDramaSectionTypeTrending:
            return LocalizedStringFromBundle(@"mini_drama_trending", @"MiniDrama");
        case MDDramaSectionTypeNew:
            return LocalizedStringFromBundle(@"mini_drama_new_release", @"MiniDrama");
        case MDDramaSectionTypeRecommend:
            return LocalizedStringFromBundle(@"mini_drama_recommended", @"MiniDrama");
        default:
            return @"";
    }
}

@end
