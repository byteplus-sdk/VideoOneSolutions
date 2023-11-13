// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRoomBottomView.h"
#import "UIView+Fillet.h"

@interface LiveRoomBottomView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) BottomRoleStatus roleStatus;
@property (nonatomic, strong) NSMutableArray *buttonLists;

@end

@implementation LiveRoomBottomView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        self.backgroundColor = [UIColor clearColor];

        [self addSubview:self.contentView];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)buttonAction:(LiveRoomItemButton *)sender {
    if ([self.delegate respondsToSelector:@selector(liveRoomBottomView:itemButton:roleStatus:)]) {
        [self.delegate liveRoomBottomView:self itemButton:sender roleStatus:self.roleStatus];
    }
}

#pragma mark - Publish Action

- (void)updateButtonStatus:(LiveRoomItemButtonState)status
               touchStatus:(LiveRoomItemTouchStatus)touchStatus {
    if (self.buttonLists.count <= 0) {
        return;
    }
    LiveRoomItemButton *itemButton = nil;
    for (LiveRoomItemButton *tempItemButton in self.buttonLists) {
        if (tempItemButton.currentState == status) {
            itemButton = tempItemButton;
            break;
        }
    }
    if (itemButton) {
        itemButton.touchStatus = touchStatus;
    }
}

- (void)updateButtonStatus:(LiveRoomItemButtonState)status
                  isUnread:(BOOL)isUnread {
    if (self.buttonLists.count <= 0) {
        return;
    }
    LiveRoomItemButton *itemButton = nil;
    for (LiveRoomItemButton *tempItemButton in self.buttonLists) {
        if (tempItemButton.currentState == status) {
            itemButton = tempItemButton;
            break;
        }
    }
    if (itemButton) {
        itemButton.isUnread = isUnread;
    }
}

- (void)updateButtonRoleStatus:(BottomRoleStatus)status {
    _roleStatus = status;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    switch (status) {
        case BottomRoleStatusAudience:
            [list addObject:@(LiveRoomItemButtonStateChat)];
            [list addObject:@(LiveRoomItemButtonStateAddGuests)];
            [list addObject:@(LiveRoomItemButtonStateGift)];
            [list addObject:@(LiveRoomItemButtonStateLike)];
            [list addObject:@(LiveRoomItemButtonStateReport)];
            break;

        case BottomRoleStatusGuests:
            [list addObject:@(LiveRoomItemButtonStateChat)];
            [list addObject:@(LiveRoomItemButtonStateAddGuests)];
            [list addObject:@(LiveRoomItemButtonStateGift)];
            [list addObject:@(LiveRoomItemButtonStateLike)];
            [list addObject:@(LiveRoomItemButtonStateReport)];
            break;

        case BottomRoleStatusHost:
            [list addObject:@(LiveRoomItemButtonStateAddGuests)];
            [list addObject:@(LiveRoomItemButtonStatePK)];
            [list addObject:@(LiveRoomItemButtonStateChat)];
            [list addObject:@(LiveRoomItemButtonStateBeauty)];
            [list addObject:@(LiveRoomItemButtonStateMore)];
            break;

        default:
            break;
    }
    [self addSubviewAndConstraints:[list copy]];
}

- (LiveRoomItemTouchStatus)getButtonTouchStatus:(LiveRoomItemButtonState)buttonState {
    LiveRoomItemTouchStatus touchStatus = LiveRoomItemTouchStatusNone;
    if (self.buttonLists.count <= 0) {
        return touchStatus;
    }
    LiveRoomItemButton *itemButton = nil;
    for (LiveRoomItemButton *tempItemButton in self.buttonLists) {
        if (tempItemButton.currentState == buttonState) {
            itemButton = tempItemButton;
            break;
        }
    }
    if (itemButton) {
        touchStatus = itemButton.touchStatus;
    }
    return touchStatus;
}

#pragma mark - Private Action
- (void)addSubviewAndConstraints:(NSArray *)list {
    [self.contentView removeAllSubviews];
    [self.buttonLists removeAllObjects];

    for (int i = 0; i < list.count; i++) {
        NSNumber *stateNumber = list[i];
        LiveRoomItemButton *button = [[LiveRoomItemButton alloc] initWithState:stateNumber.integerValue];
        [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.buttonLists addObject:button];
        [self.contentView addSubview:button];
    }

    CGFloat itemWidth = 36;
    CGFloat leadSpacing = 12;
    CGFloat fixedSpacing = 8;
    CGFloat chatWidth = SCREEN_WIDTH - (leadSpacing * 2) - ((list.count - 1) * (itemWidth + fixedSpacing));
    for (int i = 0; i < list.count; i++) {
        LiveRoomItemButton *button = self.buttonLists[i];
        LiveRoomItemButton *aboveButton = nil;
        if (i > 0) {
            aboveButton = self.buttonLists[i - 1];
        }
        NSNumber *stateNumber = list[i];
        [button mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (stateNumber.integerValue == LiveRoomItemButtonStateChat) {
                make.width.mas_equalTo(chatWidth);
            } else {
                make.width.mas_equalTo(itemWidth);
            }
            if (aboveButton) {
                make.left.equalTo(aboveButton.mas_right).offset(fixedSpacing);
            } else {
                make.left.mas_equalTo(leadSpacing);
            }
            make.top.bottom.equalTo(self.contentView);
        }];
    }
}

#pragma mark - Getter

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}

- (NSMutableArray *)buttonLists {
    if (!_buttonLists) {
        _buttonLists = [[NSMutableArray alloc] init];
    }
    return _buttonLists;
}

@end
