//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FunctionsViewController.h"
#import "FunctionTableView.h"
#import "FunctionTableCell.h"
#import "Localizator.h"
#import "SectionListView.h"
#import "UIColor+String.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

@interface FunctionsViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *backgroundImgView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) SectionListView *sectionListView;
@property (nonatomic, copy) NSArray <BaseFunctionDataList *> *tableDataArray;
@property (nonatomic, assign) NSInteger curSectionRow;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation FunctionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorFromHexString:@"#F6FAFD"];
    [self addSubvieAndMakeConstraints];

    __weak __typeof(self) wself = self;
    self.sectionListView.clickBlock = ^(NSInteger row) {
        wself.curSectionRow = row;
        CGRect frame = wself.scrollView.frame;
        CGPoint point  = CGPointMake(frame.size.width * row, frame.origin.y);
        [wself.scrollView setContentOffset:point animated:NO];
    };
}


#pragma mark - Private Action
- (void)addSubvieAndMakeConstraints {
    [self.view addSubview:self.backgroundImgView];
    [self.backgroundImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
    }];

    [self.view addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(16);
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(12);
    }];
    
    [self.view addSubview:self.sectionListView];
    [self.sectionListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(16);
        make.right.equalTo(self.view).offset(-16);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(31);
        make.height.equalTo(@36);
    }];

    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.sectionListView.mas_bottom).offset(20);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
    }];
    
    [self.scrollView setNeedsLayout];
    [self.scrollView layoutIfNeeded];
    
    CGFloat viewWidth = self.view.frame.size.width;
    CGFloat viewHeight = self.scrollView.frame.size.height;
    FunctionTableView *lastTableView;
    for (NSDictionary *funcSection in [FunctionsViewController funcSectionList]) {
        BaseFunctionDataList *section = [[NSClassFromString(funcSection[@"className"]) alloc] init];
        if (section) {
            FunctionTableView *tableView = [[FunctionTableView alloc] initWithDataList:section];
            [self.scrollView addSubview:tableView];
            if (lastTableView != nil) {
                [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(lastTableView.mas_right);
                    make.width.mas_equalTo(viewWidth);
                    make.top.equalTo(self.sectionListView.mas_bottom).offset(20);
                    make.bottom.equalTo(self.view);
                }];
            } else {
                [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(self.scrollView);
                    make.width.mas_equalTo(viewWidth);
                    make.top.equalTo(self.sectionListView.mas_bottom).offset(20);
                    make.bottom.equalTo(self.view);
                }];
            }
            lastTableView = tableView;
        }
    }
    [lastTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.scrollView);
    }];
}

#pragma mark - Getter

- (SectionListView *)sectionListView {
    if (!_sectionListView) {
        _sectionListView = [[SectionListView alloc] initWithList:self.tableDataArray];
    }
    return _sectionListView;
}

- (NSArray<BaseFunctionDataList *> *)tableDataArray {
    if (!_tableDataArray) {
        NSMutableArray *list = [[NSMutableArray alloc] init];
        for (NSDictionary *funcSection in [FunctionsViewController funcSectionList]) {
            BaseFunctionDataList *section = [[NSClassFromString(funcSection[@"className"]) alloc] init];
            if (section) {
                [list addObject:section];
            }
        }
        _tableDataArray = [list copy];
    }
    return _tableDataArray;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int currentPage = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    [self.sectionListView updateItemWithCurIndex:currentPage];
}

- (UIImageView *)backgroundImgView {
    if (!_backgroundImgView) {
        _backgroundImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"account_bg" bundleName:@"App"]];
        _backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _backgroundImgView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _titleLabel.textColor = [UIColor colorWithRed:0.114 green:0.129 blue:0.161 alpha:1.0];
        _titleLabel.font = [UIFont fontWithName:@"Roboto-Bold" size:28] ?: [UIFont boldSystemFontOfSize:28];
        _titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        if (@available(iOS 14.0, *)) {
            _titleLabel.lineBreakStrategy = NSLineBreakStrategyNone;
        }
        NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
        [paraStyle setParagraphStyle:NSParagraphStyle.defaultParagraphStyle];
        paraStyle.lineBreakStrategy = NSLineBreakStrategyNone;
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:LocalizedStringFromBundle(@"function_title", @"App") attributes:@{
            NSFontAttributeName: _titleLabel.font,
            NSForegroundColorAttributeName: _titleLabel.textColor,
            NSParagraphStyleAttributeName: paraStyle
        }];
        _titleLabel.attributedText = attr;
    }
    return _titleLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.pagingEnabled = YES;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
    }
    return _scrollView;
}

+ (NSArray *)funcSectionList {
    static NSArray *_funcSectionList;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _funcSectionList = @[
            @{@"className": @"MediaLiveFunctionSection"},
            @{@"className": @"VODFunctionSection"},
            @{@"className": @"RTCFunctionSection"}
        ];
    });
    return _funcSectionList;
}

@end
