// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddGuestsApplicationListsView.h"
#import "LiveListEmptyView.h"
@interface LiveAddGuestsApplicationListsView () <UITableViewDelegate, UITableViewDataSource, LiveAddGuestsUserListtCellDelegate>

@property (nonatomic, strong) LiveListEmptyView *emptyView;

@property (nonatomic, strong) UILabel *numberLabel;
@property (nonatomic, strong) UITableView *roomTableView;
@property (nonatomic, strong) UIImageView *bottomImageView;

@end

@implementation LiveAddGuestsApplicationListsView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self addSubview:self.emptyView];
        [self.emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(92);
            make.centerX.equalTo(self);
            make.width.equalTo(self);
        }];

        [self addSubview:self.numberLabel];
        [self.numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(44);
            make.centerX.equalTo(self);
            make.top.equalTo(self);
        }];

        [self addSubview:self.roomTableView];
        [self.roomTableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.mas_safeAreaLayoutGuideBottom);
            make.top.equalTo(self.numberLabel.mas_bottom);
        }];

        [self addSubview:self.bottomImageView];
        [self.bottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self);
            make.bottom.equalTo(self.roomTableView);
            make.height.mas_equalTo(24);
        }];
    }
    return self;
}

#pragma mark - Publish Action

- (void)setIsApplyDisable:(BOOL)isApplyDisable {
    _isApplyDisable = isApplyDisable;
    [self.roomTableView reloadData];
}

- (void)setDataLists:(NSArray<LiveUserModel *> *)dataLists {
    _dataLists = dataLists;

    [self updatenumberLabel:@(dataLists.count).stringValue];

    self.emptyView.hidden = dataLists.count > 0 ? YES : NO;
    self.roomTableView.hidden = dataLists.count > 0 ? NO : YES;
    self.numberLabel.hidden = self.roomTableView.hidden;
    [self.roomTableView reloadData];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataLists.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LiveAddGuestsUserListtCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LiveAddGuestsUserListtCellID" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.indexStr = @(indexPath.row + 1).stringValue;
    cell.applicationUserModel = self.dataLists[indexPath.row];
    cell.isApplyDisable = self.isApplyDisable;
    cell.delegate = self;
    return cell;
}

#pragma mark - LiveAddGuestsUserListtCellDelegate
- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
         clickAgreeButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(applicationListsView:clickAgreeButton:)]) {
        [self.delegate applicationListsView:self clickAgreeButton:model];
    }
}
- (void)liveAddGuestsCell:(LiveAddGuestsUserListtCell *)liveAddGuestsCell
        clickRejectButton:(LiveUserModel *)model {
    if ([self.delegate respondsToSelector:@selector(applicationListsView:clickRejectButton:)]) {
        [self.delegate applicationListsView:self clickRejectButton:model];
    }
}

#pragma mark - Private Action
- (void)updatenumberLabel:(NSString *)time {
    NSString *str1 = LocalizedString(@"co-host_time_prefix");
    NSString *str2 = time;
    NSString *str3 = LocalizedString(@"co-host_time_suffix");
    ;
    NSString *all = [NSString stringWithFormat:@"%@ %@ %@", str1, str2, str3];
    NSRange range1 = [all rangeOfString:str1];
    NSRange range2 = [all rangeOfString:str2];
    NSRange range3 = [all rangeOfString:str3];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:all];

    CGFloat font = 14;
    UIColor *color1 = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:1.0 * 255];
    UIColor *color2 = [UIColor colorFromRGBHexString:@"#FFC95E" andAlpha:1.0 * 255];
    UIColor *color3 = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:1.0 * 255];
    [string addAttribute:NSForegroundColorAttributeName
                   value:color1
                   range:range1];
    [string addAttribute:NSForegroundColorAttributeName
                   value:color2
                   range:range2];
    [string addAttribute:NSForegroundColorAttributeName
                   value:color3
                   range:range3];
    [string addAttribute:NSFontAttributeName
                   value:[UIFont systemFontOfSize:font]
                   range:NSMakeRange(0, all.length)];

    self.numberLabel.attributedText = string;
}

#pragma mark - Getter

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [[UILabel alloc] init];
    }
    return _numberLabel;
}

- (UITableView *)roomTableView {
    if (!_roomTableView) {
        _roomTableView = [[UITableView alloc] init];
        _roomTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _roomTableView.delegate = self;
        _roomTableView.dataSource = self;
        _roomTableView.hidden = YES;
        [_roomTableView registerClass:LiveAddGuestsUserListtCell.class forCellReuseIdentifier:@"LiveAddGuestsUserListtCellID"];
        _roomTableView.backgroundColor = [UIColor clearColor];

        UIView *footView = [[UIView alloc] init];
        footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 24);
        _roomTableView.tableFooterView = footView;
    }
    return _roomTableView;
}

- (LiveListEmptyView *)emptyView {
    if (!_emptyView) {
        _emptyView = [[LiveListEmptyView alloc] init];
        _emptyView.hidden = YES;
        _emptyView.messageString = LocalizedString(@"co-host_empty_title");
        _emptyView.describeString = LocalizedString(@"co-host_empty_describe");
    }
    return _emptyView;
}

- (UIImageView *)bottomImageView {
    if (!_bottomImageView) {
        _bottomImageView = [[UIImageView alloc] init];
        _bottomImageView.image = [UIImage imageNamed:@"ch-host_bottom" bundleName:HomeBundleName];
    }
    return _bottomImageView;
}

@end
