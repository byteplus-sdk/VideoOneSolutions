// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELUIToast.h"

@interface VELUIToastQueue : NSObject
@property (nonatomic, strong) NSOperationQueue *toastQueue;
@end

@implementation VELUIToastQueue
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VELUIToastQueue *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (void)showToast:(VELUIToast *)toast block:(void (^)(VELUIToast *toast))block {
    [[self sharedInstance] showToast:toast block:block];
}

+ (NSInteger)getOperationsCount {
    return [[[[self sharedInstance] toastQueue] operations] count];
}

- (void)showToast:(VELUIToast *)toast block:(void (^)(VELUIToast *toast))block  {
    [self.toastQueue addOperationWithBlock:^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (toast.superview != nil) {
                [toast setWillHideBlock:^(VELToastView * _Nonnull toastView) {
                    dispatch_semaphore_signal(semaphore);
                }];
                block(toast);
            } else {
                dispatch_semaphore_signal(semaphore);
            }
        });
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    }];
}

- (NSOperationQueue *)toastQueue {
    if (!_toastQueue) {
        _toastQueue = [[NSOperationQueue alloc] init];
        _toastQueue.maxConcurrentOperationCount = 1;
        _toastQueue.name = @"com.toast.queue";
    }
    return _toastQueue;
}

@end

@interface VELUIToastContainer : NSObject
@property(nonatomic, weak) UIView *containerView;
@property(nonatomic, weak, class, readonly) UIView *containerView;
@property(nonatomic, weak, class, readonly) UIView *loadingContainerView;
@property(nonatomic, weak) UIView *loadingContainerView;
@end
@implementation VELUIToastContainer
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VELUIToastContainer *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}
+ (UIView *)containerView {
    return [[self sharedInstance] containerView];
}
+ (UIView *)loadingContainerView {
    return [[self sharedInstance] loadingContainerView];
}
- (UIView *)loadingContainerView {
    if (_loadingContainerView == nil) {
        return self.containerView;
    }
    return _loadingContainerView;
}
- (UIView *)containerView {
    if (_containerView == nil
        || _containerView.superview == nil
        || _containerView.isHidden
        || _containerView.superview.isHidden
        || _containerView.window == nil) {
        return UIApplication.sharedApplication.delegate.window;
    }
    return _containerView;
}
@end

@interface VELUIToast ()
@property (nonatomic, strong) UIView *contentCustomView;
@property (nonatomic, weak) UIView *tempSuperView;
@end

@implementation VELUIToast
- (void)syncOnMainQueue:(dispatch_block_t)block {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

+ (void)syncOnMainQueue:(dispatch_block_t)block {
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void)showLoading:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay {
    [self syncOnMainQueue:^{
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [indicator startAnimating];
        self.contentCustomView = indicator;
        [self showTipWithText:text detailText:detailText hideAfterDelay:delay isLoading:YES];
    }];
}

- (void)showTipWithText:(NSString *)text detailText:(NSString *)detailText hideAfterDelay:(NSTimeInterval)delay isLoading:(BOOL)isLoading {
    [self syncOnMainQueue:^{
        if (text.length == 0 && self.contentCustomView == nil) {
            return;
        }
        VELToastContentView *contentView = self.contentView;
        contentView.customView = self.contentCustomView;
        contentView.text = text ?: @"";
        contentView.detailText = detailText ?: @"";
        self.loadingView = isLoading;
        [self showWithAnimated:YES];
        
        if (delay <= 0) {
            [self hideWithAnimated:YES afterDelay:[self.class delaySecnodsWith:text detailText:detailText]];
        } else if (delay > 0) {
            [self hideWithAnimated:YES afterDelay:delay];
        }
    }];
}

+ (void)setTemporaryShowView:(UIView *)view {
    [[VELUIToastContainer sharedInstance] setContainerView:view];
}

+ (void)setTemporaryLoadingShowView:(UIView *)view {
    [[VELUIToastContainer sharedInstance] setLoadingContainerView:view];
}

+ (VELUIToast *)showLoading:(nullable NSString *)text {
    return [self showLoading:text detailText:@"" inView:VELUIToastContainer.loadingContainerView hideAfterDelay:60];
}

+ (VELUIToast *)showLoading:(NSString *)text inView:(UIView *)view {
    return [self showLoading:text detailText:@"" inView:view?:VELUIToastContainer.loadingContainerView hideAfterDelay:60];
}

+ (VELUIToast *)showLoading:(NSString *)text inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    return [self showLoading:text detailText:@"" inView:view?:VELUIToastContainer.loadingContainerView hideAfterDelay:delay];
}

+ (VELUIToast *)showLoading:(NSString *)text hideAfterDelay:(NSTimeInterval)delay {
    return [self showLoading:text detailText:@"" inView:VELUIToastContainer.loadingContainerView hideAfterDelay:delay];
}

+ (VELUIToast *)showLoading:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    [self hideAllToast];
    VELUIToast *toast = [self createDefailtToastWithContainer:view?:VELUIToastContainer.loadingContainerView];
//    [VELUIToastQueue showToast:toast block:^(VELUIToast *toast) {
        [toast showLoading:text detailText:detailText hideAfterDelay:delay];
//    }];
    return toast;
}

+ (VELUIToast *)showText:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    NSString *information = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    return [self showText:information detailText:@"" inView:VELUIToastContainer.containerView hideAfterDelay:-1];
}

+ (VELUIToast *)showText:(NSString *)text inView:(UIView *)view {
    return [self showText:text detailText:@"" inView:view hideAfterDelay:-1];
}

+ (VELUIToast *)showText:(nullable NSString *)text detailText:(nullable NSString *)detailText {
    return [self showText:text detailText:detailText inView:VELUIToastContainer.containerView hideAfterDelay:-1];
}

+ (VELUIToast *)showText:(NSString *)text detailText:(NSString *)detailText inView:(UIView *)view hideAfterDelay:(NSTimeInterval)delay {
    VELUIToast *toast = [self createDefailtToastWithContainer:view];
    [VELUIToastQueue showToast:toast block:^(VELUIToast *toast) {
        [toast showTipWithText:text detailText:detailText hideAfterDelay:delay isLoading:NO];
    }];
    return toast;
}

+ (VELUIToast *)createDefailtToastWithContainer:(UIView *)view {
    __block VELUIToast *toast = nil;
    [self syncOnMainQueue:^{
        toast = [[VELUIToast alloc] initWithContainer:view?:VELUIToastContainer.containerView];
        [view addSubview:toast];
    }];
    return toast;
}

+ (NSTimeInterval)delaySecnodsWith:(NSString *)text detailText:(NSString *)detailText {
    if ([VELUIToastQueue getOperationsCount] > 1) {
        return 0.3;
    }
    NSUInteger length = [(text?:@"") stringByAppendingString:detailText?:@""].length;
    if (length <= 20) {
        return 1.5;
    } else if (length <= 40) {
        return 2.0;
    } else if (length <= 50) {
        return 2.5;
    } else {
        return 3.0;
    }
}

+ (void)hideAllToastInView:(UIView *)view {
    [self syncOnMainQueue:^{
        [self hideAllToastInView:view animated:NO];
    }];
}

+ (void)hideAllToast {
    [self hideAllToastInView:nil];
}

+ (void)hideAllLoadingView {
    [self syncOnMainQueue:^{
        [self hideAllLoadingInView:nil animated:NO];
    }];
}
@end
