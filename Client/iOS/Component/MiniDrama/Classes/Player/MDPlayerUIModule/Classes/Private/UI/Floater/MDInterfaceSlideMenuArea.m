// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceSlideMenuArea.h"
#import "MDInterfaceSlideMenuCell.h"
#import "MDInterfaceSlideMenuPercentageCell.h"
#import "MDInterfaceSlideButtonCell.h"
#import <Masonry/Masonry.h>
#import "MDEventConst.h"

static NSString *MDInterfaceSlideMenuCellIdentifier = @"MDInterfaceSlideMenuCellIdentifier";
static NSString *MDInterfaceSlideMenuPercentageCellIdentifier = @"MDInterfaceSlideMenuPercentageCellIdentifier";
static NSString *MDInterfaceSlideButtonCellIdentifier = @"MDInterfaceSlideButtonCellIdentifier";

NSString *const MDPlayEventChangeLoopPlayMode = @"MDPlayEventChangeLoopPlayMode";
NSString *const MDPlayEventChangeSREnable = @"MDPlayEventChangeSREnable";

@interface MDInterfaceSlideMenuArea () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *menuView;

@property (nonatomic, strong) UIVisualEffectView *backView;

@property (nonatomic, strong) NSArray *menuElements;

@end

@implementation MDInterfaceSlideMenuArea

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initializeMenu];
    }
    return self;
}

- (void)initializeMenu {
    [self.menuView registerClass:[MDInterfaceSlideMenuCell class] forCellReuseIdentifier:MDInterfaceSlideMenuCellIdentifier];
    [self.menuView registerClass:[MDInterfaceSlideMenuPercentageCell class] forCellReuseIdentifier:MDInterfaceSlideMenuPercentageCellIdentifier];
    [self.menuView registerClass:[MDInterfaceSlideButtonCell class] forCellReuseIdentifier:MDInterfaceSlideButtonCellIdentifier];
    
    self.menuView.delegate = self;
    [self addSubview:self.backView];
    [self addSubview:self.menuView];
    [self.menuView reloadData];
    [self.menuView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.offset(0);
        make.leading.offset(16);
        make.trailing.offset(-16);
    }];
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)fillElements:(NSArray<id<MDInterfaceElementDescription>> *)elements {
    [self checkMenuElements:elements];
    [self.menuView reloadData];
}

- (void)checkMenuElements:(NSArray<id<MDInterfaceElementDescription>> *)elements {
    NSMutableArray *menuElements = [NSMutableArray array];
    [elements enumerateObjectsUsingBlock:^(id<MDInterfaceElementDescription> elementDes, NSUInteger idx, BOOL * _Nonnull stop) {
        if (elementDes.type == MDInterfaceElementTypeMenuNormalCell
            || elementDes.type == MDInterfaceElementTypeMenuPercentageCell
            || elementDes.type == MDInterfaceElementTypeMenuButtonCell) {
            [menuElements addObject:elementDes];
        }
    }];
    self.menuElements = [NSArray arrayWithArray:menuElements];
}


#pragma mark----- UITableView Delegate & DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"moreMenu Count: %ld", self.menuElements.count);
    return self.menuElements.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MDInterfaceElementDescription> elementDes = [self.menuElements objectAtIndex:indexPath.item];
    if (elementDes.type == MDInterfaceElementTypeMenuNormalCell) {
        MDInterfaceSlideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:MDInterfaceSlideMenuCellIdentifier
                                                                         forIndexPath:indexPath];
        if (elementDes.elementDisplay) elementDes.elementDisplay(cell);
        cell.elementDescription = elementDes;
        return cell;
    } else if (elementDes.type == MDInterfaceElementTypeMenuButtonCell) {
        MDInterfaceSlideButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:MDInterfaceSlideButtonCellIdentifier
                                                                           forIndexPath:indexPath];
        if (elementDes.elementDisplay) elementDes.elementDisplay(cell);
        cell.elementDescription = elementDes;
        return cell;
    } else {
        MDInterfaceSlideMenuPercentageCell *cell = [tableView
            dequeueReusableCellWithIdentifier:MDInterfaceSlideMenuPercentageCellIdentifier
                                 forIndexPath:indexPath];
        if (elementDes.elementDisplay) elementDes.elementDisplay(cell);
        [cell updateCellWidth];
        cell.elementDescription = elementDes;
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id<MDInterfaceElementDescription> elementDes = [self.menuElements objectAtIndex:indexPath.item];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *eventKey = elementDes.elementAction(cell);
    if ([eventKey isKindOfClass:[NSString class]]) {
        [[MDEventMessageBus universalBus] postEvent:eventKey withObject:nil rightNow:YES];
    } else if ([eventKey isKindOfClass:[NSDictionary class]]) {
        NSDictionary *eventDic = (NSDictionary *)eventKey;
        [[MDEventMessageBus universalBus] postEvent:eventDic.allKeys.firstObject withObject:eventDic.allValues.firstObject rightNow:YES];
    }
    [tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

#pragma mark ----- lazy load

- (UIVisualEffectView *)backView {
    if (!_backView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _backView = [[UIVisualEffectView alloc] initWithEffect:blur];
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
    if (show) {
        [self.menuView reloadData];
    }
}

@end
