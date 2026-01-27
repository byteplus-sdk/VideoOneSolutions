// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceSelectionMenu.h"
#import "MDEventConst.h"
#import "VESettingModel.h"
#import "VESettingManager.h"
#import "MDPlayerUtility.h"
#import <Masonry/Masonry.h>
#import <TTSDKFramework/TTSDKFramework.h>

static NSString *MDSelectionMenuCellIdentifier = @"MDSelectionMenuCellIdentifier";

@interface MDInterfaceSelectionCell : UITableViewCell

@property (nonatomic, strong) MDInterfaceDisplayItem *item;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *highlightBackgroundView;

@property (nonatomic, weak) MDInterfaceSelectionMenu *superMenu;

@end

@implementation MDInterfaceSelectionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initializeElements];
    }
    return self;
}

- (void)initializeElements {
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.highlightBackgroundView];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
    [self.highlightBackgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(5);
        make.bottom.equalTo(self.contentView).offset(-5);
        make.leading.equalTo(self.contentView).offset(15);
        make.trailing.equalTo(self.contentView).offset(-15);
    }];
}


#pragma mark ----- variable setter

- (void)setItem:(MDInterfaceDisplayItem *)item {
    _item = item;
    self.titleLabel.text = item.title;
    if ([item.itemAction isEqualToString:MDPlayEventChangeResolution]) {
        if (self.superMenu.isAbrUsed) {
            self.highlightBackgroundView.hidden = !([item.actionParam integerValue] == TTVideoEngineResolutionTypeABRAuto);
        }else {
            NSInteger currentResolution = [[MDEventPoster currentPoster] currentResolution];
            self.highlightBackgroundView.hidden = !([item.actionParam integerValue] == currentResolution);
        }
    } else if ([item.itemAction isEqualToString:MDPlayEventChangePlaySpeed]) {
        CGFloat currentSpeed = [[MDEventPoster currentPoster] currentPlaySpeed];
        self.highlightBackgroundView.hidden = !([item.actionParam floatValue] == currentSpeed);
    }
}


#pragma mark ----- lazy load

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont systemFontOfSize:15.0];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.highlightedTextColor = [UIColor blueColor];
        _titleLabel.backgroundColor = [UIColor clearColor];
    }
    return _titleLabel;
}

- (UIView *)highlightBackgroundView {
    if (!_highlightBackgroundView) {
        _highlightBackgroundView = [UIView new];
        _highlightBackgroundView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.12];
        _highlightBackgroundView.layer.borderColor = [[UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3] CGColor];
        _highlightBackgroundView.layer.borderWidth = 1;
        _highlightBackgroundView.layer.cornerRadius = 1;
        _highlightBackgroundView.hidden = YES;
    }
    return _highlightBackgroundView;
}

@end

@implementation MDInterfaceDisplayItem

@end

API_AVAILABLE(ios(8.0))
@interface MDInterfaceSelectionMenu () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuView;

@property (nonatomic, strong) UIVisualEffectView *backView;

@property (nonatomic, assign) BOOL isAbrEnable;

@property (nonatomic, strong) MDInterfaceDisplayItem *abrItem;

@end

@implementation MDInterfaceSelectionMenu

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeElements];
        [[MDEventMessageBus universalBus] registEvent:MDPlayEventChangePlaySpeed withAction:@selector(shouldReload:) ofTarget:self];
        [[MDEventMessageBus universalBus] registEvent:MDPlayEventChangeResolution withAction:@selector(shouldReload:) ofTarget:self];
        VESettingModel *abr = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalABRConfig];
        _isAbrEnable = abr.open;
        _isAbrUsed = abr.open;
    }
    return self;
}

- (void)initializeElements {
    [self.menuView registerClass:[MDInterfaceSelectionCell class] forCellReuseIdentifier:MDSelectionMenuCellIdentifier];
    [self addSubview:self.backView];
    [self addSubview:self.menuView];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).offset(10);
    }];
}

- (void)reloadData {
    [self.menuView reloadData];
}

#pragma mark ----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isAbrEnable ? self.items.count + 1 : self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    MDInterfaceSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:MDSelectionMenuCellIdentifier];
    cell.superMenu = self;
    if (index < self.items.count) {
        cell.item = [self.items objectAtIndex:indexPath.row];
    }else if (index == self.items.count) {
        self.abrItem = [[MDInterfaceDisplayItem alloc] init];
        NSInteger currentResolution = [[MDEventPoster currentPoster] currentResolution];
        self.abrItem.title = [NSString stringWithFormat:@"ABR(%@)", [MDPlayerUtility transferResolutionTitleByType:currentResolution]];
        self.abrItem.itemAction = MDPlayEventChangeResolution;
        self.abrItem.actionParam = @(TTVideoEngineResolutionTypeABRAuto);
        cell.item = self.abrItem;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return ((tableView.frame.size.height - 20.0) / 5);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (index < self.items.count) {
        MDInterfaceDisplayItem *item = [self.items objectAtIndex:indexPath.row];
        [[MDEventMessageBus universalBus] postEvent:item.itemAction withObject:item.actionParam rightNow:YES];
        self.isAbrUsed = NO;
    }else if (index == self.items.count) {
        [[MDEventMessageBus universalBus] postEvent:self.abrItem.itemAction withObject:self.abrItem.actionParam rightNow:YES];
        self.isAbrUsed = YES;
    }
    [self show:NO];
}

#pragma mark ----- lazy load

- (UIVisualEffectView *)backView {
    if (!_backView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _backView = [[UIVisualEffectView alloc] initWithEffect:blur];
        }
    }
    return _backView;
}

- (UITableView *)menuView {
    if (!_menuView) {
        _menuView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _menuView.backgroundColor = [UIColor clearColor];
        _menuView.delegate = self;
        _menuView.dataSource = self;
        _menuView.showsVerticalScrollIndicator = NO;
        _menuView.showsHorizontalScrollIndicator = NO;
        _menuView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _menuView;
}

- (void)setItems:(NSMutableArray<MDInterfaceDisplayItem *> *)items {
    _items = items;
    [self reloadData];
}

- (void)shouldReload:(id)param {
    [self reloadData];
}


#pragma mark ----- MDInterfaceFloaterPresentProtocol

- (CGRect)enableZone {
    if (self.hidden) {
        return CGRectZero;
    } else {
        return self.frame;
    }
}

- (void)show:(BOOL)show {
    [[MDEventPoster currentPoster] setScreenIsClear:show];
    [[MDEventMessageBus universalBus] postEvent:MDUIEventScreenClearStateChanged withObject:nil rightNow:YES];
    self.hidden = !show;
}


@end


