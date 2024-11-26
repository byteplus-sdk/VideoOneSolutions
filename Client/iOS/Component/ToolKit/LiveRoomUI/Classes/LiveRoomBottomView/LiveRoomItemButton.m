// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRoomItemButton.h"
#import <ToolKit/ToolKit.h>
#import <Masonry/Masonry.h>

@interface LiveRoomItemButton ()

@property (nonatomic, strong) UILabel *desLabel;

@property (nonatomic, strong) UIView *tipView;

@end

@implementation LiveRoomItemButton

- (instancetype)initWithState:(LiveRoomItemButtonState)state {
    self = [super init];
    if (self) {
        _currentState = state;
        self.clipsToBounds = NO;

        [self addSubview:self.desLabel];
        [self.desLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(@(16));
        }];

        [self addSubview:self.tipView];
        [self.tipView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(8, 8));
            make.top.equalTo(self);
            make.right.equalTo(self);
        }];

        [self updateState:state];
    }
    return self;
}

- (void)updateState:(LiveRoomItemButtonState)state {
    NSString *imageName = @"";
    self.desLabel.hidden = YES;

    switch (state) {
        case LiveRoomItemButtonStateAddGuests:
            imageName = @"add_guests";
            break;
        case LiveRoomItemButtonStatePK:
            imageName = @"co_host";
            break;
        case LiveRoomItemButtonStateChat:
            imageName = @"InteractiveLive_input";
            self.desLabel.hidden = NO;
            self.desLabel.text = LocalizedStringFromBundle(@"placeholder_message", ToolKitBundleName);
            break;
        case LiveRoomItemButtonStateBeauty:
            imageName = @"beauty";
            break;
        case LiveRoomItemButtonStateData:
            imageName = @"bottom_data";
            break;
        case LiveRoomItemButtonStateMore:
            imageName = @"bottom_more";
            break;
        case LiveRoomItemButtonStateGift:
            imageName = @"bottom_gift";
            break;
        case LiveRoomItemButtonStateLike:
            imageName = @"bottom_like";
            break;
        case LiveRoomItemButtonStateReport:
            imageName = @"bottom_report";
            break;

        default:
            break;
    }

    if (NOEmptyStr(imageName)) {
        [self setBackgroundImage:[UIImage imageNamed:imageName bundleName:@"LiveRoomUI"] forState:UIControlStateNormal];
    }
}

#pragma mark - Publish Action

- (void)setIsUnread:(BOOL)isUnread {
    _isUnread = isUnread;

    self.tipView.hidden = isUnread ? NO : YES;
}

- (void)setTouchStatus:(LiveRoomItemTouchStatus)touchStatus {
    _touchStatus = touchStatus;
    NSString *imageName = @"";
    switch (_currentState) {
        case LiveRoomItemButtonStateAddGuests:
            if (touchStatus == LiveRoomItemTouchStatusClose) {
                imageName = @"add_guests";
            } else if (touchStatus == LiveRoomItemTouchStatusIng) {
                imageName = @"add_guests_ing";
            } else {
                imageName = @"add_guests";
            }
            break;
        case LiveRoomItemButtonStatePK:
            if (touchStatus == LiveRoomItemTouchStatusClose) {
                imageName = @"co_host_ing";
            } else if (touchStatus == LiveRoomItemTouchStatusIng) {
                imageName = @"co_host";
            } else {
                imageName = @"co_host";
            }
        default:
            break;
    }
    if (NOEmptyStr(imageName)) {
        [self setBackgroundImage:[UIImage imageNamed:imageName bundleName:@"LiveRoomUI"] forState:UIControlStateNormal];
    }
}

#pragma mark - Getter

- (UIView *)tipView {
    if (!_tipView) {
        _tipView = [[UIView alloc] init];
        _tipView.backgroundColor = [UIColor colorFromHexString:@"#F5B433"];
        _tipView.layer.cornerRadius = 4;
        _tipView.layer.masksToBounds = YES;
        _tipView.hidden = YES;
    }
    return _tipView;
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc] init];
        _desLabel.textColor = [UIColor colorFromRGBHexString:@"#FFFFFF" andAlpha:0.5 * 255];
        _desLabel.font = [UIFont systemFontOfSize:14];
        _desLabel.hidden = YES;
    }
    return _desLabel;
}

@end
