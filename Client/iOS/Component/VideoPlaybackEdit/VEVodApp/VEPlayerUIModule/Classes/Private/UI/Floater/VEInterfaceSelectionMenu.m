// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSelectionMenu.h"
#import "VEEventConst.h"
#import "Masonry.h"
#import "VEInterfaceProtocol.h"
#import "UIColor+String.h"

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


#pragma mark ----- variable setter

- (void)setItem:(VEInterfaceDisplayItem *)item currentPoster:(VEEventPoster *)currentPoster {
    _item = item;
    self.titleLabel.text = item.title;
    if ([item.itemAction isEqualToString:VEPlayEventChangeResolution]) {
        NSInteger currentResolution = [currentPoster currentResolution];
        self.highlightBackgroundView.hidden = !([item.actionParam integerValue] == currentResolution);
    } else if ([item.itemAction isEqualToString:VEPlayEventChangePlaySpeed]) {
        CGFloat currentSpeed = [currentPoster currentPlaySpeed];
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

@implementation VEInterfaceDisplayItem

@end

API_AVAILABLE(ios(8.0))
@interface VEInterfaceSelectionMenu () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<VEInterfaceElementDataSource> scene;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *menuView;

@property (nonatomic, strong) UIVisualEffectView *backView;

@end

@implementation VEInterfaceSelectionMenu

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.scene = scene;
        [self initializeElements];
        [[scene eventMessageBus] registEvent:VEPlayEventChangePlaySpeed withAction:@selector(shouldReload:) ofTarget:self];
        [[scene eventMessageBus] registEvent:VEPlayEventChangeResolution withAction:@selector(shouldReload:) ofTarget:self];
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

#pragma mark ----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEInterfaceSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:VESelectionMenuCellIdentifier];
    [cell setItem:[self.items objectAtIndex:indexPath.row] currentPoster:[self.scene eventPoster]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VEInterfaceDisplayItem *item = [self.items objectAtIndex:indexPath.row];
    [[self.scene eventMessageBus] postEvent:item.itemAction withObject:item.actionParam rightNow:YES];
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


#pragma mark ----- VEInterfaceFloaterPresentProtocol

- (CGRect)enableZone {
    if (self.hidden) {
        return CGRectZero;
    } else {
        return self.frame;
    }
}

- (void)show:(BOOL)show {
    [[self.scene eventPoster] setScreenIsClear:show];
    [[self.scene eventMessageBus] postEvent:VEUIEventScreenClearStateChanged withObject:VEPlayEventResolutionChanged rightNow:YES];
    self.hidden = !show;
    if (show) {
        [self.menuView reloadData];
    }
}


@end


