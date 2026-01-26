// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSelectionMenu.h"
#import "Masonry.h"
#import "UIColor+String.h"
#import "VEEventConst.h"
#import "VEInterfaceProtocol.h"
#import "VESettingModel.h"
#import "VESettingManager.h"
#import "VEPlayerUtility.h"
#import <TTSDKFramework/TTSDKFramework.h>
#import <Foundation/Foundation.h>

static NSString *VESelectionMenuCellIdentifier = @"VESelectionMenuCellIdentifier";

@interface VEInterfaceSelectionCell : UITableViewCell

@property (nonatomic, strong) VEInterfaceDisplayItem *item;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIView *highlightBackgroundView;

@end

@implementation VEInterfaceSelectionCell

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
        make.leading.equalTo(self.contentView).offset(12);
        make.trailing.equalTo(self.contentView).offset(-12);
    }];
}

#pragma mark----- variable setter

- (void)setItem:(VEInterfaceDisplayItem *)item {
    _item = item;
    self.titleLabel.text = item.title;
}

#pragma mark----- lazy load

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

@implementation VEInterfaceDisplayItem

@end

API_AVAILABLE(ios(8.0))
@interface VEInterfaceSelectionMenu () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<VEInterfaceElementDataSource> scene;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *menuView;

@property (nonatomic, strong) UIVisualEffectView *backView;

@property (nonatomic, assign) BOOL isAbrEnable;

@property (nonatomic, strong) VEInterfaceDisplayItem *abrItem;

@end

@implementation VEInterfaceSelectionMenu

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.scene = scene;
        [self initializeElements];
        [[scene eventMessageBus] registEvent:VEPlayEventChangePlaySpeed withAction:@selector(shouldReload:) ofTarget:self];
        [[scene eventMessageBus] registEvent:VEPlayEventChangeResolution withAction:@selector(shouldReload:) ofTarget:self];
        [[scene eventMessageBus] registEvent:VEPlayEventChangeSubtitle withAction:@selector(shouldReload:) ofTarget:self];
        VESettingModel *abr = [[VESettingManager universalManager] settingForKey:VESettingKeyUniversalABRConfig];
        _isAbrEnable = abr.open;
        _isAbrUsed = abr.open;
    }
    return self;
}

- (void)initializeElements {
    [self.menuView registerClass:[VEInterfaceSelectionCell class] forCellReuseIdentifier:VESelectionMenuCellIdentifier];
    [self addSubview:self.backView];
    [self addSubview:self.menuView];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(20);
    }];

    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(72);
        make.left.right.bottom.equalTo(self);
    }];
}

- (void)reloadData {
    [self.menuView reloadData];
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

#pragma mark----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.isAbrEnable ? self.items.count + 1 : self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    VEInterfaceSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:VESelectionMenuCellIdentifier];
    VEInterfaceDisplayItem *tempItem = NULL;
    NSInteger currentResolution = [self.scene.eventPoster currentResolution];
    if (index < self.items.count) {
        tempItem = [self.items objectAtIndex:indexPath.row];
        [cell setItem:tempItem];
    }else if (index == self.items.count) {
        self.abrItem = [[VEInterfaceDisplayItem alloc] init];
        self.abrItem.title = [NSString stringWithFormat:@"ABR(%@)", [VEPlayerUtility transferResolutionTitleByType:currentResolution]];
        self.abrItem.itemAction = VEPlayEventChangeResolution;
        self.abrItem.actionParam = @(TTVideoEngineResolutionTypeABRAuto);
        cell.item = self.abrItem;
        tempItem = self.abrItem;
    }
    
    if ([tempItem.itemAction isEqualToString:VEPlayEventChangeResolution]) {
        if (self.isAbrUsed) {
            cell.highlightBackgroundView.hidden = !([tempItem.actionParam integerValue] == TTVideoEngineResolutionTypeABRAuto);
        }else {
            cell.highlightBackgroundView.hidden = !([tempItem.actionParam integerValue] == currentResolution);
        }
    } else if ([tempItem.itemAction isEqualToString:VEPlayEventChangePlaySpeed]) {
        CGFloat currentSpeed = [self.scene.eventPoster currentPlaySpeed];
        cell.highlightBackgroundView.hidden = !([tempItem.actionParam floatValue] == currentSpeed);
    } else if ([tempItem.itemAction isEqualToString:VEPlayEventChangeSubtitle]) {
        id subtitle = tempItem.actionParam;
        id sutitleScene = self.scene;
        NSInteger currentLanguangeId = [[sutitleScene valueForKeyPath:@"manager.currentSubtitleId"] integerValue];
        cell.highlightBackgroundView.hidden = !([[subtitle valueForKey:@"subtitleId"] integerValue] == currentLanguangeId);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (index < self.items.count) {
        VEInterfaceDisplayItem *item = [self.items objectAtIndex:indexPath.row];
        [[self.scene eventMessageBus] postEvent:item.itemAction withObject:item.actionParam rightNow:YES];
        self.isAbrUsed = NO;
    }else if (index == self.items.count) {
        [[self.scene eventMessageBus] postEvent:self.abrItem.itemAction withObject:self.abrItem.actionParam rightNow:YES];
        self.isAbrUsed = YES;
    }

    [self show:NO];
}

#pragma mark----- lazy load

- (UIVisualEffectView *)backView {
    if (!_backView) {
        if (@available(iOS 8.0, *)) {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            _backView = [[UIVisualEffectView alloc] initWithEffect:blur];
        }
    }
    return _backView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor colorFromHexString:@"#B4B7BC"];
        _titleLabel.font = [UIFont systemFontOfSize:12];
    }
    return _titleLabel;
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

- (void)setItems:(NSMutableArray<VEInterfaceDisplayItem *> *)items {
    _items = items;
    [self reloadData];
}

- (void)shouldReload:(id)param {
    [self reloadData];
}

#pragma mark----- VEInterfaceFloaterPresentProtocol

- (CGRect)enableZone {
    if (self.hidden) {
        return CGRectZero;
    } else {
        return self.frame;
    }
}

- (void)show:(BOOL)show {
    [[self.scene eventPoster] setScreenIsClear:show];
    self.hidden = !show;
    if (show) {
        [self.menuView reloadData];
    }
}

@end
