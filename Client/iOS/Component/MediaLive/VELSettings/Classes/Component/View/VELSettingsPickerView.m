// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsPickerView.h"
@interface VELSettingsPickerView () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) VELUILabel *titleLabel;
@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, assign) CGSize menuSize;
@end
@implementation VELSettingsPickerView

- (void)initSubviewsInContainer:(UIView *)container {
    [container addSubview:self.titleLabel];
    [container addSubview:self.pickerView];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container).mas_offset(self.model.insets.top);
        make.left.equalTo(self.container).mas_offset(self.model.insets.left);
        make.bottom.equalTo(self.container).mas_offset(-self.model.insets.bottom);
    }];
    
    [self.pickerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.container).mas_offset(-self.model.margin.top);
        make.right.equalTo(self.container).mas_offset(-self.model.insets.right);
        make.bottom.equalTo(self.container).mas_offset(self.model.margin.bottom);
        make.left.greaterThanOrEqualTo(self.titleLabel.mas_right).mas_offset(8);
        make.width.mas_equalTo(80);
    }];
}

- (void)updateSubViewStateWithModel {
    [super updateSubViewStateWithModel];
    self.titleLabel.text = self.model.title;
    self.titleLabel.textAttributes = self.model.titleAttributes;
    if (self.model.selectIndex >= 0 && self.model.selectIndex < self.model.menuModels.count) {
        [self.pickerView selectRow:self.model.selectIndex inComponent:0 animated:NO];
    }
}

- (CGSize)getMenumSize {
    if (!CGSizeEqualToSize(self.menuSize, CGSizeZero)) {
        return self.menuSize;
    }
    __block CGFloat width = 0;
    __block CGFloat height = 0;
    [self.model.menuModels enumerateObjectsUsingBlock:^(VELSettingsButtonViewModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        width = MAX(width, obj.size.width);
        height = MAX(obj.size.height, 8);
    }];
    return CGSizeMake(width, height);
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return 40;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 18;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    [pickerView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.vel_height < 2) {
            obj.backgroundColor = UIColor.redColor;
        }
    }];
    VELUILabel *label = (VELUILabel *)view;
    if (label == nil || ![label isKindOfClass:VELUILabel.class]) {
        label = [[VELUILabel alloc] init];
    }
    VELSettingsButtonViewModel *vm = self.model.menuModels[row];
    label.font = [UIFont systemFontOfSize:11];
    label.text = vm.title;
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.model.menuModels.count;
}
- (VELUILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[VELUILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = UIColor.whiteColor;
    }
    return _titleLabel;
}
- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.dataSource = self;
        _pickerView.delegate = self;
        _pickerView.backgroundColor = UIColor.clearColor;
    }
    return _pickerView;
}
@end
