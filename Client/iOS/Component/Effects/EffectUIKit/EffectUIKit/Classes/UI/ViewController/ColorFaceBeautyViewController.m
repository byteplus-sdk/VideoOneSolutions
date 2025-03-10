// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ColorFaceBeautyViewController.h"
#import "ColorListAdapter.h"
#import <Masonry/Masonry.h>
#import "EffectCommon.h"
#import <ToolKit/ToolKit.h>

@interface ColorFaceBeautyViewController () <ColorListAdapterDelegate>

@property (nonatomic, strong) NSArray<EffectColorItem *> *colorset;
@property (nonatomic, strong) ColorListAdapter *colorListAdapter;
@property (nonatomic, weak) EffectItem *lastItem;

@end

@implementation ColorFaceBeautyViewController

- (void)setItem:(EffectItem *)item {
    [super setItem:item];
    _colorset = item.colorset;
    _colorListAdapter = [[ColorListAdapter alloc] initWithColorset:_colorset];
    _colorListAdapter.delegate = self;
}

#pragma mark - public
- (void)setPlaceholderView:(UIView *)placeholderView {
    [super setPlaceholderView:placeholderView];
    
    UIView *placeholderContainer = placeholderView.superview;
    if (placeholderContainer == nil) {
        return;
    }
    
    [self.colorListAdapter addToContainer:placeholderContainer placeholder:placeholderView];
    
    if (self.item.selectChild == nil || self.item.selectChild.ID == EffectUIKitNodeTypeClose) {
        self.colorListAdapter.collectionView.hidden = YES;
        self.lTitle.hidden = NO;
    } else {
        self.colorListAdapter.collectionView.hidden = NO;
        self.lTitle.hidden = YES;
        EffectItem *item = self.item.selectChild;
        [self.colorListAdapter refreshWith:item.colorset];
        [self.colorListAdapter selectItem:[item.colorset indexOfObject:item.selectedColor]];
    }
}

- (void)setRemoveTitlePlaceholderView:(UIView *)removeTitlePlaceholderView {
    [super setRemoveTitlePlaceholderView:removeTitlePlaceholderView];
    
    UIView *placeholderContainer = removeTitlePlaceholderView.superview;
    if (placeholderContainer == nil) {
        return;
    }
    
    [self.colorListAdapter addToContainer:placeholderContainer placeholder:removeTitlePlaceholderView];
    self.colorListAdapter.collectionView.hidden = NO;
    EffectItem *item = self.item;
    [self.colorListAdapter refreshWith:item.colorset];
    [self.colorListAdapter selectItem:[item.colorset indexOfObject:item.selectedColor]];
}

- (void)removeFromView {
    [super removeFromView];
    [self.colorListAdapter.collectionView removeFromSuperview];
}

- (void)showPlaceholder:(BOOL)show {
    [super showPlaceholder:show];
    self.colorListAdapter.collectionView.alpha = show ? 1 : 0;
}



#pragma mark - FaceBeautyViewDelegate
- (void)onItemCleanColorListAdapter:(BOOL)isHidden {
    EffectItem *item = self.item.selectChild;
    if (item == nil) {
        [self.colorListAdapter refreshWith:nil];
    }
    self.colorListAdapter.collectionView.hidden = isHidden;
}
- (void)refreshWithNewItem:(EffectItem *)item {
    EffectItem *oldItem;
    if ([self.titleType isEqualToString:EffectUIKitFeature_ar_hair_dye]) {
        oldItem = item;
    }
    else {
        oldItem = self.item.selectChild;
    }
    EffectColorItem *oldColor = oldItem == nil ? nil : oldItem.selectedColor;
    [super refreshWithNewItem:item];
    if (item.ID == EffectUIKitNodeTypeClose || item.colorset == nil) {
        self.lTitle.hidden = NO;
        self.colorListAdapter.collectionView.hidden = YES;
    } else {
        
        if (oldColor != nil) {
            [self updateItemColor:item withIndex:[item.colorset indexOfObject:oldColor]];
        }
        if (item.selectedColor == nil) {
            
            [self colorListAdapter:nil didSelectedAt:0];
        }
        
        
        self.lTitle.hidden = YES;
        self.colorListAdapter.collectionView.hidden = NO;
        [self.colorListAdapter refreshWith:item.colorset];
        [self.colorListAdapter selectItem:[item.colorset indexOfObject:item.selectedColor]];
    }
}

#pragma mark - ColorListAdapterDelegate
- (void)colorListAdapter:(ColorListAdapter *)adapter didSelectedAt:(NSInteger)index {
    EffectItem *selectItem = self.item.selectChild;
    if (selectItem == nil) {
        return;
    }
    [self updateItemColor:selectItem withIndex:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceBeautyViewController:didClickItem:)]) {
        [self.delegate faceBeautyViewController:self didClickItem:selectItem];
    }
}

#pragma mark - private
- (void)updateItemColor:(EffectItem *)selectItem withIndex:(NSInteger)index {
    if (index < 0 || index >= selectItem.colorset.count) {
        VOLogE(VOEffectUIKit,@"invalid index %ld in %@", (long)index, selectItem.colorset);
        return;
    }
    
    EffectColorItem *color = selectItem.colorset[index];
    
    ComposerNodeModel *model = selectItem.model;
    if (model == nil || model.keyArray.count != selectItem.intensityArray.count) {
        VOLogE(VOEffectUIKit,@"invalid model and intensity array");
        return;
    }
    
    for (int i = 0; i < model.keyArray.count; ++i) {
        if ([model.keyArray[i] isEqualToString:@"R"]) {
            selectItem.intensityArray[i] = [NSNumber numberWithFloat:color.red];
        } else if ([model.keyArray[i] isEqualToString:@"G"]) {
            selectItem.intensityArray[i] = [NSNumber numberWithFloat:color.green];
        } else if ([model.keyArray[i] isEqualToString:@"B"]) {
            selectItem.intensityArray[i] = [NSNumber numberWithFloat:color.blue];
        }
    }
    selectItem.selectedColor = color;
}

@end
