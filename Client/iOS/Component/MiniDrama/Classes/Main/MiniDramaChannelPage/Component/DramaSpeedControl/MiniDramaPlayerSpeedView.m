// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaPlayerSpeedView.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

static NSString *MiniDramaPlayerSpeedViewCellIdentify = @"MiniDramaPlayerSpeedViewCellIdentify";

static NSInteger MiniDramaSpeedViewHeight = 360;

@interface MiniDramaPlayerSpeedViewCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation MiniDramaPlayerSpeedViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
    }];
}

- (void)setSpeedValue:(NSString *)speedValue {
    _speedValue = speedValue;
    self.label.text = [NSString stringWithFormat:@"%@x", speedValue];
}

#pragma mark - Getter

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:15];
    }
    return _label;
}

@end



@interface MiniDramaPlayerSpeedView ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIView *maskView;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UITableView *speedTable;

@property (nonatomic, strong) NSArray *speedOptionsArray;

@end

@implementation MiniDramaPlayerSpeedView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _speedOptionsArray = @[@"2.0", @"1.5", @"1.25", @"1.0",  @"0.75"];
        [self setupUI];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose:)];
        tap.numberOfTapsRequired = 1;
        [self.maskView addGestureRecognizer:tap];
    }
    return self;
}

- (void)setupUI {
    [self addSubview:self.maskView];
    [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(MiniDramaSpeedViewHeight);
    }];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.speedTable];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(12);
    }];
    
    [self.speedTable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(30);
        make.left.right.bottom.equalTo(self.contentView);
    }];
}

- (void)onClose:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    if (!CGRectContainsPoint(self.contentView.frame, point)) {
        [self dissmissSpeedView];
    }
}

- (void)showSpeedViewInView:(UIView *)parentView {
    [parentView addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    self.contentView.transform = CGAffineTransformMakeTranslation(0, MiniDramaSpeedViewHeight);
    [UIView animateWithDuration:0.5 animations:^{
        self.contentView.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
}

- (void)dissmissSpeedView {
    if (self.superview) {
        [self removeFromSuperview];
    }
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.speedOptionsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MiniDramaPlayerSpeedViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MiniDramaPlayerSpeedViewCellIdentify];
    cell.speedValue = self.speedOptionsArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onChoosePlaybackSpeed:)]) {
        [self.delegate onChoosePlaybackSpeed: [self.speedOptionsArray[indexPath.row] floatValue]];
    }
    [self dissmissSpeedView];
}


#pragma mark - Getter

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
    }
    return _maskView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.userInteractionEnabled = YES;
        _contentView.backgroundColor = [UIColor blackColor];
        _contentView.layer.cornerRadius = 8;
        _contentView.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    return _contentView;
}
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.text = LocalizedStringFromBundle(@"mini_drama_playback_speed_title", @"MiniDrama");
    }
    return _titleLabel;
}

- (UITableView *)speedTable {
    if (!_speedTable) {
        _speedTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _speedTable.dataSource = self;
        _speedTable.delegate = self;
        _speedTable.backgroundColor = [UIColor clearColor];
        _speedTable.separatorStyle = UITableViewCellSeparatorStyleNone;
        _speedTable.rowHeight =  48;
        _speedTable.showsVerticalScrollIndicator = NO;
        _speedTable.showsHorizontalScrollIndicator = NO;
        [_speedTable registerClass:[MiniDramaPlayerSpeedViewCell class] forCellReuseIdentifier:MiniDramaPlayerSpeedViewCellIdentify];
        
    }
    return _speedTable;
}
@end

