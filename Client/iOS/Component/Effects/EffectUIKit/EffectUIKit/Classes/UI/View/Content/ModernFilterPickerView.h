// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <UIKit/UIKit.h>
@class EffectItem, EffectItem, ModernFilterPickerView;

@protocol ModernFilterPickerViewDelegate <NSObject>

- (void)filterPicker:(ModernFilterPickerView *)pickerView didSelectFilter:(EffectItem *)filter;

@end

@interface ModernFilterPickerView : UIView

@property (nonatomic, weak) id<ModernFilterPickerViewDelegate> delegate;

- (void)refreshWithFilters:(NSArray <EffectItem *>*)filters;
- (void)setAllCellsUnSelected;
- (void)setSelectItem:(NSString *)filterPath;

@end
