// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushViewController.h"
#import "VELPushUIViewController+Private.h"
#import "VELPushBaseNewViewController.h"
#import <MediaLive/VELCore.h>
#import <MediaLive/VELApplication.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
@interface VELPushViewController () <VELSwitchTabViewDelegate, UIScrollViewDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (nonatomic, strong) NSArray <NSString *> *categoryTitles;
@property (nonatomic, strong) NSArray <NSNumber *> *captureTypes;
@property (nonatomic, strong) VELSwitchTabView *tabView;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) NSMutableArray <VELPushUIViewController *> *pageViewControllers;
@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) NSInteger safeTopMargin;
@end

@implementation VELPushViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.currentIndex = -1;
    _safeTopMargin = VEL_SAFE_INSERT.top ?: 47;
    self.view.backgroundColor = [UIColor blackColor];
    self.showNavigationBar = NO;
    [self initData];
    [self initPageViewController];
    [self.view addSubview:self.closeBtn];
    [self.view addSubview:self.tabView];
    [self setupUIConstraints];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)initData {
    self.currentIndex = 0;
    self.categoryTitles = @[LocalizedStringFromBundle(@"medialive_camera", @"MediaLive"),
                            LocalizedStringFromBundle(@"medialive_voice_darkframe", @"MediaLive"),
                            LocalizedStringFromBundle(@"medialive_screen_capture", @"MediaLive"),
                            LocalizedStringFromBundle(@"medialive_video_file", @"MediaLive"),];
    self.captureTypes = @[@(VELSettingCaptureTypeInner),
                          @(VELSettingCaptureTypeAudioOnly),
                           @(VELSettingCaptureTypeScreen),
                          @(VELSettingCaptureTypeFile)];
}
- (VELPushUIViewController *)createPusherViewControllerForType:(VELSettingCaptureType)captureType {
    Class vcClass = [self getPushViewControllerClass:captureType];
    VELPushUIViewController *vc = [[vcClass alloc] initWithCaptureType:captureType];
    __weak __typeof__(self)weakSelf = self;
    [vc setStreamStatusChangedBlock:^(VELStreamStatus status, BOOL isStreaming) {
        __strong __typeof__(weakSelf)self = weakSelf;
        self.tabView.hidden = isStreaming;
        self.pageScrollView.scrollEnabled = !isStreaming;
    }];
    return vc;
}
- (VELPushUIViewController *)getPusherViewControllerAtIndex:(NSInteger)index {
    if (index < 0 || index >= self.pageViewControllers.count || index == NSNotFound) {
        return nil;
    }
    return [self.pageViewControllers objectAtIndex:index];
}
- (void)initPageViewController {
    [self.captureTypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.pageViewControllers addObject:[self createPusherViewControllerForType:obj.integerValue]];
    }];
    [self.pageViewController setViewControllers:@[[self getPusherViewControllerAtIndex:self.currentIndex]]
                                      direction:(UIPageViewControllerNavigationDirectionForward)
                                       animated:NO
                                     completion:nil];
    [self.pageViewController willMoveToParentViewController:self];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    [self.pageViewController.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self.pageViewController didMoveToParentViewController:self];
    UIScrollView *scrollView = [self findPageVCScrollView:self.pageViewController.view];
    scrollView.delegate = self;
    self.pageScrollView = scrollView;
    scrollView.scrollEnabled = NO;
}

- (void)setupUIConstraints {
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(30, 30));
        make.top.equalTo(self.view).offset(self.safeTopMargin);
        make.leading.equalTo(self.view).offset(20);
    }];
    

    [self.tabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.closeBtn.mas_bottom).offset(5);
        make.leading.equalTo(self.closeBtn);
        make.trailing.equalTo(self.view);
        make.height.mas_equalTo(41);
    }];
    
    [self.tabView refreshWithTitles:self.categoryTitles];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabView selectItemAtIndex:self.currentIndex animated:NO];
    });
}


- (void)updateConstraints:(BOOL)landScape {
    if (landScape) {
        [self.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.top.leading.equalTo(self.view).offset(20);
        }];
        [self.tabView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(20);
            make.leading.equalTo(self.closeBtn.mas_trailing).offset(10);
            make.trailing.equalTo(self.view);
            make.height.mas_equalTo(41);
        }];
    } else {
        [self.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(30, 30));
            make.top.equalTo(self.view).offset(self.safeTopMargin);
            make.leading.equalTo(self.view).offset(20);
        }];
        

        [self.tabView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.closeBtn.mas_bottom).offset(5);
            make.leading.equalTo(self.closeBtn);
            make.trailing.equalTo(self.view);
            make.height.mas_equalTo(41);
        }];
    }
}
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    BOOL landScape = (size.width > size.height);
    [self updateConstraints:landScape];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.tabView reloadData];
    });
    [[self getPusherViewControllerAtIndex:self.currentIndex] viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
- (BOOL)shouldPopViewController:(BOOL)isGesture {
    VELPushUIViewController *pushUIVC = [self getPusherViewControllerAtIndex:self.currentIndex];
    return [pushUIVC shouldPopViewController:isGesture];
}

- (Class)getPushViewControllerClass:(VELSettingCaptureType)captureType {
    NSString *className = nil;
    switch (captureType) {
        case VELSettingCaptureTypeInner:
            className = @"VELPushInner";
            break;
        case VELSettingCaptureTypeFile:
            className = @"VELPushFile";
            break;
        case VELSettingCaptureTypeAudioOnly:
            className = @"VELPushAudioOnly";
            break;
        case VELSettingCaptureTypeScreen:
            className = @"VELPushScreenCapture";
            break;
        default:
            break;
    }
    className = [className stringByAppendingString:@"NewViewController"];
    Class cls = NSClassFromString(className);
    if (cls == nil) {
        return VELPushUIViewController.class;
    }
    return cls;
}


// VELSwitchTabViewDelegate
- (void)switchTabDidSelectedAtIndex:(NSInteger)index {
    VELPushUIViewController *currentVc = [self getPusherViewControllerAtIndex:self.currentIndex];
    VELPushUIViewController *toVc = [self getPusherViewControllerAtIndex:index];
    
    if (index == self.currentIndex) {
        return;
    }
    
    if (toVc == nil || ![currentVc shouldPopViewController:NO]) {
        if (index != self.currentIndex) {
            [self.tabView selectItemAtIndex:self.currentIndex animated:NO];
        }
        return;
    }
    
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    if (index < self.currentIndex) {
        direction = UIPageViewControllerNavigationDirectionReverse;
    }
    __weak __typeof__(self)weakSelf = self;
    self.tabView.userInteractionEnabled = NO;
    [self.pageViewController setViewControllers:@[toVc]
                                      direction:(direction)
                                       animated:YES
                                     completion:^(BOOL finished) {
        __strong __typeof__(weakSelf)self = weakSelf;
        if (finished) {
            self.currentIndex = index;
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.tabView.userInteractionEnabled = YES;
        });
    }];
}

- (UIScrollView *)findPageVCScrollView:(UIView *)view {
    for (UIView *v in view.subviews) {
        if ([v isKindOfClass:UIScrollView.class]) {
            return (UIScrollView *)v;
        }
        if (v.subviews.count > 0) {
            return [self findPageVCScrollView:v];
        }
    }
    return nil;
}

/// MARK: - UIPageViewControllerDataSource
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSInteger index = [self.pageViewControllers indexOfObject:(VELPushUIViewController *)viewController];
    return [self getPusherViewControllerAtIndex:index - 1];
}

- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSInteger index = [self.pageViewControllers indexOfObject:(VELPushUIViewController *)viewController];
    return [self getPusherViewControllerAtIndex:index + 1];
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers
       transitionCompleted:(BOOL)completed {
    UIViewController *vc = pageViewController.viewControllers.firstObject;
    NSInteger index =  [self.pageViewControllers indexOfObject:(VELPushUIViewController *)vc];
    self.currentIndex = index;
    [self.tabView selectItemAtIndex:index animated:YES];
}

/// MARK: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self disablePageViewBounce:scrollView];
    CGFloat offsetX = self.pageScrollView.contentOffset.x;
    CGFloat proportion = offsetX / self.pageScrollView.frame.size.width;
    proportion = self.currentIndex + (proportion - 1);
    if (!isnan(proportion)) {
        self.tabView.proportion = proportion;
    }
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    [self disablePageViewBounce:scrollView];
}

- (void)disablePageViewBounce:(UIScrollView *)scrollView {
    if (self.currentIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    } else if (self.currentIndex == self.pageViewControllers.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width) {
        scrollView.contentOffset = CGPointMake(scrollView.bounds.size.width, 0);
    }
}


- (VELSwitchTabView *)tabView {
    if (!_tabView) {
        VELSwitchTabView *tabView = [[VELSwitchTabView alloc] initWithTitles:self.categoryTitles];
        tabView.position = VELSwitchTabPositionCenter;
        tabView.normalTextColor = [UIColor vel_colorWithHexString:@"#E8E5E5"];
        tabView.hightlightTextColor = [UIColor whiteColor];
        tabView.delegate = self;
        tabView.itemMargin = 10;
        VELSwitchIndicatorLineStyle *lineStyle = [[VELSwitchIndicatorLineStyle alloc] init];
        lineStyle.backgroundColor = [UIColor whiteColor];
        lineStyle.widthRatio = 1;
        lineStyle.height = 2;
        lineStyle.bottomMargin = 1;
        tabView.indicatorLineStyle = lineStyle;
        tabView.proportion = 0;
        _tabView = tabView;
    }
    return _tabView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_closeBtn setImage:VELUIImageMake(@"ic_close_white") forState:UIControlStateNormal];
        _closeBtn.adjustsImageWhenHighlighted = NO;
        _closeBtn.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _closeBtn;
}

- (UIPageViewController *)pageViewController {
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:(UIPageViewControllerTransitionStyleScroll) navigationOrientation:(UIPageViewControllerNavigationOrientationHorizontal) options:nil];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
    }
    return _pageViewController;
}

- (NSMutableArray<VELPushUIViewController *> *)pageViewControllers {
    if (!_pageViewControllers) {
        _pageViewControllers = [NSMutableArray arrayWithCapacity:self.categoryTitles.count];
    }
    return _pageViewControllers;
}

- (void)dealloc {
    [VELUIToast hideAllToast];
}
@end
