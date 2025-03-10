// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "DownloadableSelectableCell.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"

@interface DownloadableSelectableCell ()

@end

@implementation DownloadableSelectableCell

@synthesize selectableButton = _selectableButton;
@synthesize downloadView = _downloadView;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.downloadView];
        
        [self.downloadView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake((12), (12)));
        }];
    }
    return self;
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
    
    [self.downloadView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake((12), (12)));
        make.leading.mas_equalTo(self).offset(selectableConfig.imageSize.width - (12) - 4);
        make.top.mas_equalTo(self).offset(selectableConfig.imageSize.height - (12) - 4);
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
    if (_downloadView) {
        return _downloadView;
    }
    
    _downloadView = [DownloadView new];
    _downloadView.downloadImage = [EffectCommon imageNamed:@"ic_to_download"];
    return _downloadView;
}

@end
