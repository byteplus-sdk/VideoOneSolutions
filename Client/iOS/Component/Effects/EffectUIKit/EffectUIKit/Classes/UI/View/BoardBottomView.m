// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "BoardBottomView.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"

@interface BoardBottomView ()

@property (nonatomic, strong) UIButton *btnClose;
@property (nonatomic, strong) UIButton *btnReset;

@end

@implementation BoardBottomView

- (instancetype)init {
    self = [super init];
    if (self) {
        CGFloat RECORD_WIDTH = (44);
        CGFloat BACK_BTN_WIDTH = (44);
        
        [self addSubview:self.btnRecord];
        [self addSubview:self.btnClose];
        [self addSubview:self.btnReset];
        
        self.btnRecord.layer.cornerRadius = RECORD_WIDTH / 2;
        [self.btnRecord mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
            make.width.height.mas_equalTo(RECORD_WIDTH);
        }];
        
        [self.btnClose mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.leading.equalTo(self).offset(50);
            make.width.height.mas_equalTo(BACK_BTN_WIDTH);
        }];
        
        [self.btnReset mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self);
            make.trailing.equalTo(self).offset(-50);
            make.width.height.mas_equalTo(BACK_BTN_WIDTH);
        }];
    }
    return self;
}

- (void)didClickBoard:(UIView *)sender {
    if (sender == self.btnRecord) {
        [self.delegate boardBottomView:self didTapRecord:sender];
    } else if (sender == self.btnClose) {
        [self.delegate boardBottomView:self didTapClose:sender];
    } else if (sender == self.btnReset) {
        [self.delegate boardBottomView:self didTapReset:sender];
    }
}

- (void)setDelegate:(id<BoardBottomViewDelegate>)delegate {
    _delegate = delegate;
    
    BOOL showReset = [delegate respondsToSelector:@selector(boardBottomViewShowReset:)] && [delegate boardBottomViewShowReset:self];
    self.btnReset.hidden = !showReset;
}

#pragma mark - getter
- (UIButton *)btnRecord {
    if (_btnRecord == nil) {
        _btnRecord = [[UIButton alloc] init];
        [_btnRecord setImage:[EffectCommon imageNamed:@"ic_record"] forState:UIControlStateNormal];
        [_btnRecord addTarget:self action:@selector(didClickBoard:) forControlEvents:UIControlEventTouchUpInside];
        _btnRecord.backgroundColor = [UIColor colorWithWhite:1 alpha:0.15];
    }
    return _btnRecord;
}

- (UIButton *)btnClose {
    if (_btnClose == nil) {
        _btnClose = [[UIButton alloc] init];
        [_btnClose setImage:[EffectCommon imageNamed:@"ic_arrow_down"] forState:UIControlStateNormal];
        [_btnClose addTarget:self action:@selector(didClickBoard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnClose;
}

- (UIButton *)btnReset {
    if (_btnReset == nil) {
        _btnReset = [[UIButton alloc] init];
        _btnReset.hidden = YES;
        [_btnReset setImage:[EffectCommon imageNamed:@"ic_refresh"] forState:UIControlStateNormal];
        [_btnReset addTarget:self action:@selector(didClickBoard:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnReset;
}

@end
