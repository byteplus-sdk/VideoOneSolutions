// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceSlideMenuArea.h"
#import "VEInterfaceSlideMenuCell.h"
#import "VEInterfaceElementDescription.h"
#import "Masonry.h"
#import "VEEventConst.h"
#import "VEInterfaceSlideMenuPercentageCell.h"
#import "VEInterfaceSlideButtonCell.h"
#import "VEInterfaceProtocol.h"

static NSString *VEInterfaceSlideMenuCellIdentifier = @"VEInterfaceSlideMenuCellIdentifier";
static NSString *VEInterfaceSlideMenuPercentageCellIdentifier = @"VEInterfaceSlideMenuPercentageCellIdentifier";
static NSString *VEInterfaceSlideButtonCellIdentifier = @"VEInterfaceSlideButtonCellIdentifier";

NSString *const VEPlayEventChangeLoopPlayMode = @"VEPlayEventChangeLoopPlayMode";

@interface VEInterfaceSlideMenuArea () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) id<VEInterfaceElementDataSource> scene;

@property (nonatomic, strong) UITableView *menuView;

@property (nonatomic, strong) UIVisualEffectView *backView;

@property (nonatomic, strong) NSArray *menuElements;

@end

@implementation VEInterfaceSlideMenuArea

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super init];
    if (self) {
        self.scene = scene;
        [self initializeMenu];
    }
    return self;
}

- (void)initializeMenu {
    [self.menuView registerClass:[VEInterfaceSlideMenuCell class] forCellReuseIdentifier:VEInterfaceSlideMenuCellIdentifier];
    [self.menuView registerClass:[VEInterfaceSlideMenuPercentageCell class] forCellReuseIdentifier:VEInterfaceSlideMenuPercentageCellIdentifier];
    [self.menuView registerClass:[VEInterfaceSlideButtonCell class] forCellReuseIdentifier:VEInterfaceSlideButtonCellIdentifier];
    [self addSubview:self.backView];
    [self addSubview:self.menuView];
    
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.top.equalTo(self).offset(16);
        make.right.equalTo(self).offset(-16);
    }];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)fillElements:(NSArray<id<VEInterfaceElementDescription>> *)elements {
    [self checkMenuElements:elements];
    [self.menuView reloadData];
}

- (void)checkMenuElements:(NSArray<id<VEInterfaceElementDescription>> *)elements {
    NSMutableArray *menuElements = [NSMutableArray array];
    [elements enumerateObjectsUsingBlock:^(id<VEInterfaceElementDescription> elementDes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (elementDes.type == VEInterfaceElementTypeMenuNormalCell || elementDes.type == VEInterfaceElementTypeMenuPercentageCell || elementDes.type == VEInterfaceElementTypeButtonCell) {
            [menuElements addObject:elementDes];
        }
    }];
    self.menuElements = [NSArray arrayWithArray:menuElements];
}


#pragma mark ----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<VEInterfaceElementDescription> elementDes = [self.menuElements objectAtIndex:indexPath.item];
    if (elementDes.type == VEInterfaceElementTypeMenuNormalCell) {
        VEInterfaceSlideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:VEInterfaceSlideMenuCellIdentifier
                                                                         forIndexPath:indexPath];
        if (elementDes.elementDisplay) elementDes.elementDisplay(cell);
        cell.elementDescription = elementDes;
        return cell;
    } else if (elementDes.type == VEInterfaceElementTypeButtonCell) {
        VEInterfaceSlideButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:VEInterfaceSlideButtonCellIdentifier
                                                                           forIndexPath:indexPath];
          if (elementDes.elementDisplay) elementDes.elementDisplay(cell);
          cell.elementDescription = elementDes;
          return cell;
    } else {
        VEInterfaceSlideMenuPercentageCell *cell = [tableView
                                                    dequeueReusableCellWithIdentifier:VEInterfaceSlideMenuPercentageCellIdentifier forIndexPath:indexPath];
        if (elementDes.elementDisplay) elementDes.elementDisplay(cell);
        [cell updateCellWidth];
        cell.elementDescription = elementDes;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<VEInterfaceElementDescription> elementDes = [self.menuElements objectAtIndex:indexPath.item];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *eventKey = elementDes.elementAction(cell);
    if ([eventKey isKindOfClass:[NSString class]]) {
        [[self.scene eventMessageBus] postEvent:eventKey withObject:nil rightNow:YES];
    } else if ([eventKey isKindOfClass:[NSDictionary class]]) {
        NSDictionary *eventDic = (NSDictionary *)eventKey;
        [[self.scene eventMessageBus] postEvent:eventDic.allKeys.firstObject withObject:eventDic.allValues.firstObject rightNow:YES];
    }
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
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
        _menuView = [[UITableView alloc] initWithFrame:CGRectZero];
        _menuView.showsVerticalScrollIndicator = NO;
        _menuView.showsHorizontalScrollIndicator = NO;
        _menuView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _menuView.backgroundColor = [UIColor clearColor];
        _menuView.delegate = self;
        _menuView.dataSource = self;
    }
    return _menuView;
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
    [[self.scene eventMessageBus] postEvent:VEUIEventScreenClearStateChanged withObject:nil rightNow:YES];
    self.hidden = !show;
    if (show) {
        [self.menuView reloadData];
    }
}

@end
