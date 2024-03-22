//
//  KTVRoomTopSeatView.m
//  veRTC_Demo
//
//  Created by on 2021/11/30.
//  
//

#import "KTVRoomTopSeatView.h"

@interface KTVRoomTopSeatView ()

@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UISwitch *switchView;

@end


@implementation KTVRoomTopSeatView

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateSeatSwitch:) name:NotificationUpdateSeatSwitch object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resultSeatSwitch) name:NotificationResultSeatSwitch object:nil];
        
        self.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.messageLabel];
        [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.mas_equalTo(0);
            make.width.mas_lessThanOrEqualTo(100);
        }];
        
        [self addSubview:self.switchView];
        [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.left.equalTo(self.messageLabel.mas_right).offset(4);
            make.right.equalTo(self);
        }];
    }
    return self;
}

- (void)switchViewChanged:(UISwitch *)sender {
    sender.userInteractionEnabled = NO;
    if (self.clickSwitchBlock) {
        self.clickSwitchBlock(sender.on);
    }
}

- (void)updateSeatSwitch:(NSNotification *)notification {
    if ([notification.object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)notification.object;
        [self.switchView setOn:number.boolValue animated:YES];
    }
}

- (void)resultSeatSwitch {
    self.switchView.userInteractionEnabled = YES;
}

#pragma mark - Getter

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[UILabel alloc] init];
        _messageLabel.text = LocalizedString(@"label_switch_apply_title");
        _messageLabel.font = [UIFont systemFontOfSize:14];
        _messageLabel.textColor = [UIColor whiteColor];
        _messageLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _messageLabel;
}

- (UISwitch *)switchView {
    if (!_switchView) {
        _switchView = [[UISwitch alloc] init];
        _switchView.onTintColor = [UIColor colorFromHexString:@"#165DFF"];
        [_switchView addTarget:self action:@selector(switchViewChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

@end
