// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "FaceBeautyViewController.h"
#import "ColorFaceBeautyViewController.h"
#import <Masonry/Masonry.h>
#import "EffectDataManager.h"
#import "EffectCommon.h"
#import "EffectCommon.h"

@interface FaceBeautyViewController ()

@property (nonatomic, weak) NSMutableSet<EffectItem *> *selectNodes;
@property (nonatomic, strong) EffectDataManager *dataManager;
@property (nonatomic, strong) NSMutableArray *faceBeautyViewArray;

@end


@implementation FaceBeautyViewController

#pragma mark - public
- (instancetype)init {
    self = [super init];
    if (self) {
        [self.beautyView removeFromSuperview];
        [self.view addSubview:self.beautyView];
        [self.beautyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return self;
}

- (void)faceBeautyViewArray:(NSMutableArray *)viewArray{
    _faceBeautyViewArray = viewArray;
    [viewArray addObject:self.beautyView];
}

- (void)setItem:(EffectItem *)item {
    _item = item;
    self.beautyView.titleType = self.titleType;
    [self.beautyView setItem:item];
}

- (void)setSelectNodes:(NSMutableSet<EffectItem *> *)selectNodes dataManager:(EffectDataManager *)dataManager {
    self.selectNodes = selectNodes;
    self.dataManager = dataManager;
}

- (void)addToView:(UIView *)view {
    UIViewController *parent = [EffectCommon topViewControllerForResponder:view];
    if (self.parentViewController != parent
        && self.parentViewController != nil) {
        [self willMoveToParentViewController:nil];
        [self removeFromView];
        [self removeFromParentViewController];
        [parent addChildViewController:self];
    }
    [parent addChildViewController:self];
    [view addSubview:self.view];
    [self didMoveToParentViewController:parent];
}

- (void)removeFromView {
    [self removeFromParentViewController];
    [self.view removeFromSuperview];
    [self.lTitle removeFromSuperview];
    [self.btnBack removeFromSuperview];
}

- (void)setPlaceholderView:(UIView *)placeholderView {
    UIView *placeholderContainer = placeholderView.superview;
    if (placeholderContainer == nil) {
        return;
    }
    
    [placeholderContainer addSubview:self.lTitle];
    [placeholderContainer addSubview:self.btnBack];
    
    [self.lTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(placeholderView);
    }];
    
    [self.btnBack mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.lTitle);
        make.width.mas_equalTo(self.btnBack.mas_height);
    }];
    
    self.lTitle.text = self.item.title;
    
    [self showPlaceholder:NO];
}

- (void)setRemoveTitlePlaceholderView:(UIView *)removeTitlePlaceholderView {
    [self showPlaceholder:NO];
}

- (void)showPlaceholder:(BOOL)show {
    self.lTitle.alpha = show ? 1 : 0;
    self.btnBack.alpha = show ? 1 : 0;
}
- (void)showTitlePlaceholder:(BOOL)show {
    
}

#pragma mark - FaceBeautyViewDelegate
- (void)onItemClean:(BOOL)isHidden {
    [self onItemCleanColorListAdapter:isHidden];
}
- (void)onItemCleanColorListAdapter:(BOOL)isHidden {
    
}

- (void)onItemSelect:(EffectItem *)item {
    [self refreshWithNewItem:item];
    
    if ([self.titleType isEqualToString:EffectUIKitFeature_ar_lipstick]) {
        for (int i=0; i<self.faceBeautyViewArray.count; i++) {
            FaceBeautyView *view = self.faceBeautyViewArray[i];
            if (self.beautyView != view) {
                [view cleanSelect];
            }
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(faceBeautyViewController:didClickItem:)]) {
        [self.delegate faceBeautyViewController:self didClickItem:item];
    }
}

- (void)refreshWithNewItem:(EffectItem *)item {
    if (item.ID == EffectUIKitNodeTypeClose) {
        // close button, remove all the children of item's parent
        [self removeOrAddItem:self.selectNodes item:item.parent add:NO];
        [self.beautyView resetSelect];
        self.item.selectChild = nil;
    } else {
        if (![self.selectNodes containsObject:item]) {
            NSMutableArray *itemIntensity = nil;
            // remove it's brother if not enable multi select
            EffectItem *brotherItem = self.item;
            while (item.children == nil && brotherItem != nil && !brotherItem.enableMultiSelect) {
                for (EffectItem *brotherChild in [brotherItem.allChildren arrayByAddingObject:brotherItem]) {
                    if (brotherChild.selectChild != nil) {
                        EffectItem *itemToRemove = brotherChild.selectChild;
                        
                        // do reuse intensity from it's brother if should
                        if (brotherChild.reuseChildrenIntensity && itemIntensity == nil) {
                            itemIntensity = itemToRemove.intensityArray;
                        }
                        
                        [self removeOrAddItem:self.selectNodes item:itemToRemove add:NO];
                        
                        [brotherChild reset];
                        
                        [brotherChild updateState];
                    }
                }
                brotherItem = brotherItem.parent;
            }
            
            if (item.lastIntensityArray != nil) {
                itemIntensity = item.lastIntensityArray;
            }
            self.item.selectChild = item;
            if (itemIntensity == nil) {
                // if has default intensity, set it to item
                itemIntensity = [self.dataManager defaultIntensity:item.ID];
            }
            if (itemIntensity != nil && item.intensityArray != nil) {
                for (int i = 0; i < itemIntensity.count && i < item.intensityArray.count; i++) {
                    item.intensityArray[i] = itemIntensity[i];
                }
            }
            // feature button, add the specific item
            [self removeOrAddItem:self.selectNodes item:item add:YES];
        }
        self.item.selectChild = item;
    }
    // reset ui state
    [self.beautyView resetSelect];
}

- (void)reloadData {
    [self.beautyView reloadData];
}
#pragma mark - private
- (void)removeOrAddItem:(NSMutableSet *)set item:(EffectItem *)item add:(BOOL)add {
    if (add) {
        if (item.availableItem != nil) {
            [set addObject:item];
        }
        [item updateState];
    } else {
        // reset intensity
        [item reset];
        // update ui state if can
        [item updateState];
        // remove from selectNodes
        [set removeObject:item];
        // do the same in children
        if (item.children) {
            for (EffectItem *i in item.children) {
                [self removeOrAddItem:self.selectNodes item:i add:add];
            }
        }
    }
}
- (void)didClickOptionBack:(UIView *)sender {
    [self.delegate faceBeautyViewController:self didClickBack:sender];
}

#pragma mark - getter
- (FaceBeautyView *)beautyView {
    if (!_beautyView) {
        _beautyView = [FaceBeautyView new];
        _beautyView.delegate = self;
    }
    return _beautyView;
}

- (UILabel *)lTitle {
    if (_lTitle == nil) {
        _lTitle = [UILabel new];
        _lTitle.textColor = [UIColor whiteColor];
        _lTitle.font = [UIFont systemFontOfSize:15];
        _lTitle.textAlignment = NSTextAlignmentCenter;
        _lTitle.alpha = 0;
    }
    return _lTitle;
}

- (UIButton *)btnBack {
    if (!_btnBack) {
        _btnBack = [UIButton new];
        [_btnBack setImage:[EffectCommon imageNamed:@"ic_arrow_left"] forState:UIControlStateNormal];
        _btnBack.backgroundColor = [UIColor clearColor];
        _btnBack.alpha = 0;
        _btnBack.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
        [_btnBack addTarget:self action:@selector(didClickOptionBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnBack;
}

@end
