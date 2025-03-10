// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDScrollViewController.h"
#import <Masonry/Masonry.h>

@interface MDScrollViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation MDScrollViewController

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Class scrollViewClass = [self scrollViewClass];
    UIScrollView *scrollView = nil;
    if (scrollViewClass) {
        scrollView = [scrollViewClass new];
    }
    if (!scrollView) {
        scrollView = [UIScrollView new];
        self.scrollView = scrollView;
    }
    
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.width.height.equalTo(self.view);
    }];
}

- (void)dealloc {
    _scrollView.delegate = nil;
}

- (Class _Nullable)scrollViewClass {
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if ([self respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
            [self scrollViewDidEndScrolling:scrollView];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self respondsToSelector:@selector(scrollViewDidEndScrolling:)]) {
        [self scrollViewDidEndScrolling:scrollView];
    }
}

#pragma mark - MDScrollViewDelegate

- (void)scrollViewDidEndScrolling:(UIScrollView * _Nonnull)scrollView {
    
}

@end
