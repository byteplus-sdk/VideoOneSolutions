// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceFloater.h"
#import "VEInterfaceProtocol.h"
#import "VEInterfaceElementDescription.h"
#import "VEEventConst.h"
#import "VEInterfaceSelectionMenu.h"
#import "VEInterfaceSlideMenuArea.h"
#import "Masonry.h"
#import "Localizator.h"

NSString *const VEUIEventShowMoreMenu = @"VEUIEventShowMoreMenu";

NSString *const VEUIEventShowResolutionMenu = @"VEUIEventShowResolutionMenu";

NSString *const VEUIEventShowPlaySpeedMenu = @"VEUIEventShowPlaySpeedMenu";

NSString *const VEPlayEventResolutionChanged = @"VEPlayEventResolutionChanged";

NSString *const VEPlayEventPlaySpeedChanged = @"VEPlayEventPlaySpeedChanged";

@interface VEInterfaceFloater ()

@property (nonatomic, weak) id<VEInterfaceElementDataSource> scene;

@property (nonatomic, strong) VEInterfaceSlideMenuArea *slideMenu;

@property (nonatomic, strong) VEInterfaceSelectionMenu *selectionMenu; // language, defination and so on

@end

@implementation VEInterfaceFloater

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.scene = scene;
        [self.slideMenu fillElements:[scene customizedElements]];
        [self registEvents:[scene eventMessageBus]];
        [self initializeAction];
        
    }
    return self;
}

- (void)initializeAction {
    [self addTarget:self action:@selector(singleTapAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark ----- Message / Action

- (void)registEvents:(VEEventMessageBus *)eventMessageBus {
    [eventMessageBus registEvent:VEUIEventShowMoreMenu withAction:@selector(showMoreMenuAction:) ofTarget:self];
    [eventMessageBus registEvent:VEUIEventShowPlaySpeedMenu withAction:@selector(showSpeedMenuAction:) ofTarget:self];
    [eventMessageBus registEvent:VEUIEventShowResolutionMenu withAction:@selector(showResolutionMenuAction:) ofTarget:self];
}

- (void)showMoreMenuAction:(id)param {
    [self.slideMenu show:YES];
}

- (void)showSpeedMenuAction:(id)param {
    NSMutableArray<VEInterfaceDisplayItem *> *playSpeedItems = [NSMutableArray array];
    for (NSDictionary *playSpeedDic in [[self.scene eventPoster] playSpeedSet]) {
        VEInterfaceDisplayItem *item = [VEInterfaceDisplayItem new];
        item.title = playSpeedDic.allKeys.firstObject;
        if ([item.title containsString:@"1.0"]) {
            item.title = [NSString stringWithFormat:@"%@(Default)", item.title];
        }
        item.itemAction = VEPlayEventChangePlaySpeed;
        item.actionParam = playSpeedDic.allValues.firstObject;
        [playSpeedItems addObject:item];
    }
    self.selectionMenu.title = LocalizedStringFromBundle(@"play_back_speed", @"VEVodApp");
    self.selectionMenu.items = playSpeedItems;
    [self.selectionMenu show:YES];
}

- (void)showResolutionMenuAction:(id)param {
    NSMutableArray<VEInterfaceDisplayItem *> *resolutionItems = [NSMutableArray array];
    for (NSDictionary *resolutionDic in [[self.scene eventPoster] resolutionSet]) {
        VEInterfaceDisplayItem *item = [VEInterfaceDisplayItem new];
        item.title = resolutionDic.allKeys.firstObject;
        item.itemAction = VEPlayEventChangeResolution;
        item.actionParam = resolutionDic.allValues.firstObject;
        [resolutionItems addObject:item];
    }
    self.selectionMenu.title = LocalizedStringFromBundle(@"play_quality", @"VEVodApp");
    self.selectionMenu.items = resolutionItems;
    [self.selectionMenu show:YES];
}

- (void)singleTapAction {
    [self hideAllFloater];
}

- (void)hideAllFloater {
    [self.selectionMenu show:NO];
    [self.slideMenu show:NO];
}


#pragma mark ----- lazy load

- (VEInterfaceSelectionMenu *)selectionMenu {
    if (!_selectionMenu) {
        _selectionMenu = [[VEInterfaceSelectionMenu alloc] initWithScene:self.scene];
        _selectionMenu.hidden = YES;
        _selectionMenu.layer.cornerRadius = 8;
        _selectionMenu.layer.masksToBounds = YES;
        [self addSubview:_selectionMenu];
        [_selectionMenu mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(8);
            make.bottom.offset(-8);
            make.width.equalTo(@(240));
            make.trailing.equalTo(self).offset(-44);
        }];
    }
    return _selectionMenu;
}

- (VEInterfaceSlideMenuArea *)slideMenu {
    if (!_slideMenu) {
        _slideMenu = [[VEInterfaceSlideMenuArea alloc] initWithScene:self.scene];
        _slideMenu.hidden = YES;
        [self addSubview:_slideMenu];
        [_slideMenu mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.trailing.equalTo(self).offset(0);
            make.leading.equalTo(self.mas_centerX);
        }];
    }
    return _slideMenu;
}


#pragma mark ----- Response Chain

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect selectionMenuArea = [self.selectionMenu enableZone];
    CGRect slideMenuArea = [self.slideMenu enableZone];
    if (!CGRectEqualToRect(selectionMenuArea, CGRectZero) || !CGRectEqualToRect(slideMenuArea, CGRectZero)) {
        if (CGRectContainsPoint(selectionMenuArea, point)) {
            return [super hitTest:point withEvent:event];
        } else if (CGRectContainsPoint(slideMenuArea, point)) {
            return [super hitTest:point withEvent:event];
        } else {
            return self;
        }
    } else {
        return nil;
    }
}

@end
