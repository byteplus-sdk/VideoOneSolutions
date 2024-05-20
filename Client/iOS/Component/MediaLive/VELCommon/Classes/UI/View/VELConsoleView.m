// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELConsoleView.h"
#import "VELUILabel.h"
#import <Masonry/Masonry.h>
#import "VELCommonDefine.h"
#define VEL_CONSOLE_MAX_COUNT 1024
@interface VELConsoleViewCell : UITableViewCell
@property (nonatomic, strong) VELUILabel *contentLabel;
@property (nonatomic, strong) NSIndexPath *indexPath;
@end

@implementation VELConsoleViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.backgroundColor = UIColor.clearColor;
    self.backgroundColor = UIColor.clearColor;
    self.contentLabel = [[VELUILabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:12];
    self.contentLabel.numberOfLines = 0;
    self.contentLabel.textColor = [UIColor whiteColor];
    [self.contentView addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)updateText:(NSString *)text {
    if ([text isKindOfClass:NSAttributedString.class]) {
        self.contentLabel.attributedText = (NSAttributedString *)text;
    } else if ([text isKindOfClass:NSString.class]) {
        self.contentLabel.text = text;
    }
}

@end

@interface VELConsoleView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UIVisualEffectView *bgView;
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSString *> *infoStringArray;
@property (nonatomic, assign) BOOL needReload;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, assign) BOOL forbiddenScrollToBottom;
@end

@implementation VELConsoleView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.infoStringArray = [[NSMutableArray alloc] initWithCapacity:1024];
        [self setupUI];
        self.dateFormatter = [[NSDateFormatter alloc] init];
        self.dateFormatter.dateFormat = @"HH:mm:ss.SSS";
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _title = title.copy;
    self.titleLabel.text = title;
}

- (void)setDateFormat:(NSString *)dateFormat {
    _dateFormat = dateFormat.copy;
    self.dateFormatter.dateFormat = dateFormat;
}

- (void)setupUI {
    self.bgView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:(UIBlurEffectStyleDark)]];
    [self addSubview:self.bgView];
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    self.layer.cornerRadius = 16;
    self.layer.masksToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel = [[VELUILabel alloc] init];
    self.titleLabel.textColor = UIColor.whiteColor;
    self.titleLabel.font = [UIFont systemFontOfSize:14];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).mas_offset(6);
        make.left.equalTo(self).mas_offset(13);
    }];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.allowsSelection = NO;
    self.tableView.allowsMultipleSelection = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.estimatedRowHeight = UITableViewAutomaticDimension;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [self.tableView registerClass:VELConsoleViewCell.class forCellReuseIdentifier:@"VELConsoleViewCell"];
    [self addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).mas_offset(13);
        make.right.equalTo(self).mas_offset(-13);
        make.top.equalTo(self.titleLabel.mas_bottom).mas_offset(8);
        make.bottom.equalTo(self).mas_offset(-13);
    }];
}
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    if (self.needReload) {
        [self.tableView reloadData];
        self.needReload = NO;
        [self scrollToBottom];
    }
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden && self.needReload) {
        [self.tableView reloadData];
        self.needReload = NO;
        [self scrollToBottom];
    }
    if (hidden) {
        [self.infoStringArray removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)scrollToBottom {
    if (self.infoStringArray.count < 2 || self.forbiddenScrollToBottom) {
        return;
    }
    if (!(self.tableView.isDragging || self.tableView.isDecelerating || self.tableView.isTracking)) {
        NSIndexPath *last = [NSIndexPath indexPathForItem:self.infoStringArray.count - 1 inSection:0];
        [self.tableView scrollToRowAtIndexPath:last atScrollPosition:(UITableViewScrollPositionNone) animated:YES];
    }
}

- (void)updateInfo:(NSString *)info append:(BOOL)append {
    [self updateInfo:info append:append date:NSDate.date];
}

- (void)updateInfo:(NSString *)info append:(BOOL)append date:(nonnull NSDate *)date {
    if (VEL_IS_EMPTY_STRING(info)) {
        return;
    }
    if (self.showDate) {
        info = [NSString stringWithFormat:@"[%@] %@", [self.dateFormatter stringFromDate:date], info];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableIndexSet *removeIndexSet = [[NSMutableIndexSet alloc] init];
        if (!append) {
            self.infoStringArray = @[info].mutableCopy;
        } else {
            if (self.infoStringArray.count >= VEL_CONSOLE_MAX_COUNT) {
                NSInteger count = self.infoStringArray.count - VEL_CONSOLE_MAX_COUNT * 0.1;
                for (int i = 0; i < count; i++) {
                    [removeIndexSet addIndex:i];
                }
                [self.infoStringArray removeObjectsAtIndexes:removeIndexSet];
            }
            [self.infoStringArray addObject:info];
        }
        
        if (self.isHidden || self.superview == nil) {
            self.needReload = YES;
            return;
        }
        
        if (!append) {
            [self.tableView reloadData];
        } else {
            if (removeIndexSet.count <= 0) {
                NSArray <NSIndexPath *>* indexPaths = @[[NSIndexPath indexPathForItem:self.infoStringArray.count - 1 inSection:0]];
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationBottom)];
            } else {
                [self.tableView reloadData];
            }
            [self scrollToBottom];
        }
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.infoStringArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VELConsoleViewCell *cell = (VELConsoleViewCell *)[tableView dequeueReusableCellWithIdentifier:@"VELConsoleViewCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    [cell updateText:self.infoStringArray[indexPath.row]];
    return cell;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.forbiddenScrollToBottom = YES;
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self checkShouldForbiddenScrollToBottom];
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self checkShouldForbiddenScrollToBottom];
}

- (void)checkShouldForbiddenScrollToBottom {
    VELConsoleViewCell *lastCell = self.tableView.visibleCells.lastObject;
    if (lastCell.indexPath.row >= self.infoStringArray.count - 3) {
        self.forbiddenScrollToBottom = NO;
    }
}
@end
