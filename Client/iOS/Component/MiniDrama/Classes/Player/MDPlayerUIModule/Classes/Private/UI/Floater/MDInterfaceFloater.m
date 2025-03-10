// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceFloater.h"
#import "MDInterfaceProtocol.h"
#import "MDInterfaceElementDescription.h"
#import "MDEventConst.h"
#import "MDInterfaceSelectionMenu.h"
#import "MDInterfaceSlideMenuArea.h"
#import <Masonry/Masonry.h>

NSString *const MDUIEventShowMoreMenu = @"MDUIEventShowMoreMenu";

NSString *const MDUIEventShowResolutionMenu = @"MDUIEventShowResolutionMenu";

NSString *const MDUIEventShowPlaySpeedMenu = @"MDUIEventShowPlaySpeedMenu";

NSString *const MDUIEventShowEpisodesView = @"MDUIEventShowEpisodesView";

NSString *const MDPlayEventResolutionChanged = @"MDPlayEventResolutionChanged";

NSString *const MDPlayEventPlaySpeedChanged = @"MDPlayEventPlaySpeedChanged";

NSString *const MDPlayEventEpisodesChanged = @"MDPlayEventEpisodesChanged";

NSString *const MDPlayEventShowSubtitleMenu = @"MDPlayEventShowSubtitleMenu";

NSString *const MDPlayEventSmartSubtitleChanged = @"MDPlayEventSmartSubtitleChanged";

@interface MDInterfaceFloater ()

@property (nonatomic, strong) MDInterfaceSlideMenuArea *slideMenu;

@property (nonatomic, strong) MDInterfaceSelectionMenu *selectionMenu; // language, defination and so on

@end

@implementation MDInterfaceFloater

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self.slideMenu fillElements:[scene customizedElements]];
        [self registEvents];
        [self initializeAction];
        
    }
    return self;
}

- (void)initializeAction {
    [self addTarget:self action:@selector(singleTapAction) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark ----- Message / Action

- (void)registEvents {
    [[MDEventMessageBus universalBus] registEvent:MDUIEventShowMoreMenu withAction:@selector(showMoreMenuAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventShowPlaySpeedMenu withAction:@selector(showSpeedMenuAction:) ofTarget:self];
    [[MDEventMessageBus universalBus] registEvent:MDUIEventShowResolutionMenu withAction:@selector(showResolutionMenuAction:) ofTarget:self];
}

- (void)showMoreMenuAction:(id)param {
    [self.slideMenu show:YES];
}

- (void)showSpeedMenuAction:(id)param {
    NSMutableArray<MDInterfaceDisplayItem *> *playSpeedItems = [NSMutableArray array];
    for (NSDictionary *playSpeedDic in [[MDEventPoster currentPoster] playSpeedSet]) {
        MDInterfaceDisplayItem *item = [MDInterfaceDisplayItem new];
        item.title = playSpeedDic.allKeys.firstObject;
        item.itemAction = MDPlayEventChangePlaySpeed;
        item.actionParam = playSpeedDic.allValues.firstObject;
        [playSpeedItems addObject:item];
    }
    self.selectionMenu.items = playSpeedItems;
    [self.selectionMenu show:YES];
}

- (void)showResolutionMenuAction:(id)param {
    NSMutableArray<MDInterfaceDisplayItem *> *resolutionItems = [NSMutableArray array];
    for (NSDictionary *resolutionDic in [[MDEventPoster currentPoster] resolutionSet]) {
        MDInterfaceDisplayItem *item = [MDInterfaceDisplayItem new];
        item.title = resolutionDic.allKeys.firstObject;
        item.itemAction = MDPlayEventChangeResolution;
        item.actionParam = resolutionDic.allValues.firstObject;
        [resolutionItems addObject:item];
    }
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

- (MDInterfaceSelectionMenu *)selectionMenu {
    if (!_selectionMenu) {
        _selectionMenu = [MDInterfaceSelectionMenu new];
        _selectionMenu.hidden = YES;
        [self addSubview:_selectionMenu];
        [_selectionMenu mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.trailing.equalTo(self).offset(0);
            make.leading.equalTo(self.mas_centerX);
        }];
    }
    return _selectionMenu;
}

- (MDInterfaceSlideMenuArea *)slideMenu {
    if (!_slideMenu) {
        _slideMenu = [MDInterfaceSlideMenuArea new];
        _slideMenu.hidden = YES;
        _slideMenu.layer.cornerRadius = 8;
        _slideMenu.layer.masksToBounds = YES;
        [self addSubview:_slideMenu];
        [_slideMenu mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.offset(8);
            make.bottom.offset(-8);
            make.leading.equalTo(self.mas_centerX);
            make.right.equalTo(self.mas_safeAreaLayoutGuideRight);
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
