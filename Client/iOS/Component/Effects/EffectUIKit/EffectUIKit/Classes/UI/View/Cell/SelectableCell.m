// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SelectableCell.h"
#import <Masonry/Masonry.h>
#import "DownloadView.h"
#import "EffectCommon.h"
@interface SelectableCell ()
@property (nonatomic, strong) DownloadView *downloadView;
@end

@implementation SelectableCell

@synthesize selectableButton = _selectableButton;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)updateProgress:(CGFloat)progress complete:(BOOL)complete {
    if (self.downloadView.superview != self.selectableButton) {
        [self.selectableButton addSubview:self.downloadView];
        [self.downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.selectableButton.contentView);
            make.centerX.equalTo(self.selectableButton.contentView.mas_right);
            make.size.mas_equalTo(CGSizeMake(11, 11));
        }];
        self.downloadView.hidden = NO;
    }
    self.downloadView.downloadProgress = progress;
    self.downloadView.state = DownloadViewStateDownloading;
    if (complete) {
        self.downloadView.state = DownloadViewStateDownloaded;
        self.downloadView.hidden = YES;
        self.downloadView.downloadProgress = 0;
    } else if (self.downloadView.isHidden) {
        self.downloadView.hidden = NO;
    }
}

- (void)setSelectableConfig:(id<SelectableConfig>)selectableConfig {
    _selectableConfig = selectableConfig;
    
    if (_selectableButton) {
        [_selectableButton removeFromSuperview];
    }
    
    _selectableButton = [[SelectableButton alloc] initWithSelectableConfig:selectableConfig];
    [self.contentView insertSubview:_selectableButton atIndex:0];
    [_selectableButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (_useCellSelectedState) {
        self.selectableButton.isSelected = selected;
    }
}

- (void)setUseCellSelectedState:(BOOL)useCellSelectState {
    _useCellSelectedState = useCellSelectState;
    
    if (useCellSelectState) {
        self.selectableButton.isSelected = self.selected;
    }
}

#pragma mark - getter
- (SelectableButton *)selectableButton {
    if (_selectableButton) {
        return _selectableButton;
    }
    
    _selectableButton = [[SelectableButton alloc] initWithSelectableConfig:_selectableConfig];
    return _selectableButton;
}

- (DownloadView *)downloadView {
    if (!_downloadView) {
        _downloadView = [[DownloadView alloc] init];
        _downloadView.hidden = YES;
        _downloadView.downloadImage = [EffectCommon imageNamed:@"ic_to_download"];
    }
    return _downloadView;
}

@end
