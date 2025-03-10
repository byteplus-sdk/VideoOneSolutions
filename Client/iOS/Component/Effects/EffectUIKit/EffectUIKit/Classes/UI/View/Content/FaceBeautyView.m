// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "FaceBeautyView.h"
#import "EffectCommon.h"
#import <Masonry/Masonry.h>
#import "RectangleSelectableView.h"
#import "EffectCollectionFlowLayout.h"
#import "LightUpSelectableView.h"
#import "EffectCollectionView.h"
@interface FaceBeautyView () <UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, strong) EffectItem *item;
@property (nonatomic, strong, readonly) NSArray<EffectItem *> *items;
@property (nonatomic, strong) EffectCollectionView *cv;
@property (nonatomic, strong) NSIndexPath *selectIndex;
@end


@implementation FaceBeautyView

#pragma mark - public
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.cv];
        [self.cv mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)setTitleType:(NSString *)titleType {
    _titleType = titleType;
    if ([titleType isEqualToString:EffectUIKitFeature_ar_hair_dye] || [titleType isEqualToString:EffectUIKitFeature_ar_lipstick]) {
        [self.cv mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
    }
}

- (void)setItem:(EffectItem *)item {
    _item = item;
    
    [self.cv reloadData];
    [self resetSelect];
}

- (void)reloadData {
    [self.cv reloadData];
}
- (void)resetSelect {
    if (self.selectIndex != nil) {
        [self.cv deselectItemAtIndexPath:self.selectIndex animated:NO];
    }
    int selectIndex = 0;
    BOOL iconSelectBool = YES;
    for (int i = 0; i < self.items.count; i++) {
        EffectItem *firstItem = self.items[i];
        if (self.items[i] == self.item.selectChild) {
            selectIndex = i;
        }
        if (self.item.selectChild == nil) {
            for (int j = 0; j < firstItem.intensityArray.count; j++) {
                float intensityFloat = firstItem.intensityArray[j].floatValue;
                if (firstItem.enableNegative == YES) {
                    if (intensityFloat != 0.5) {
                        iconSelectBool = NO;
                    }
                }
                else {
                    if (intensityFloat != 0) {
                        iconSelectBool = NO;
                    }
                }
            }
            for (EffectItem *innerItem in firstItem.children) {
                for (int z = 0; z < innerItem.intensityArray.count; z++) {
                    float intensityFloat = innerItem.intensityArray[z].floatValue;
                    if (innerItem.enableNegative == YES) {
                        if (intensityFloat != 0.5) {
                            iconSelectBool = NO;
                        }
                    }
                    else {
                        if (intensityFloat != 0) {
                            iconSelectBool = NO;
                        }
                    }
                }
            }
        }
    }
    if (iconSelectBool) {
        self.selectIndex = [NSIndexPath indexPathForRow:selectIndex inSection:0];
        [self.cv selectItemAtIndexPath:self.selectIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    } else if (self.item.children.firstObject.ID == EffectUIKitNodeTypeClose && !self.item.hasIntensity) {
        self.selectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.cv selectItemAtIndexPath:self.selectIndex animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)cleanSelect {
    self.selectIndex = [NSIndexPath indexPathForRow:0 inSection:0];
    self.item.selectChild = nil;
    [self.cv reloadData];
    [self.cv selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    [self.delegate onItemClean:YES];
}

- (void)hiddenColorListAdapter:(BOOL)isHidden {
    [self.delegate onItemClean:isHidden];
}

- (void)onClose {
    self.item.selectChild = nil;
    [self.cv reloadData];
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndex != indexPath) {
        [self.cv deselectItemAtIndexPath:self.selectIndex animated:NO];
    }
    self.selectIndex = indexPath;
    [self.delegate onItemSelect:self.items[indexPath.row]];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.titleType isEqualToString:EffectUIKitFeature_ar_hair_dye] || [self.titleType isEqualToString:EffectUIKitFeature_ar_lipstick]) {
        return CGSizeMake((66), (97));
    }
    return CGSizeMake((60), (66));
}

#pragma mark - UICollectionViewDataSource
-(NSInteger )numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    EffectItem *item = self.items[indexPath.row];
    SelectableCell *c = [collectionView dequeueReusableCellWithReuseIdentifier:@"SelectableCell" forIndexPath:indexPath];

    if ([self.titleType isEqualToString:EffectUIKitFeature_ar_hair_dye] || [self.titleType isEqualToString:EffectUIKitFeature_ar_lipstick]) {
        [c setSelectableConfig:[RectangleSelectableConfig
                                   initWithImageName:item.selectImg imageSize:CGSizeMake((66), (66))]];
    } else {
        [c  setSelectableConfig:[LightUpSelectableConfig
                                initWithUnselectImage:item.selectImg
                                imageSize:CGSizeMake((36), (36))]];
        item.cell = c;
        [item updateState];
    }

    if ([self.titleType isEqualToString:EffectUIKitFeature_ar_hair_dye]) {
        item.cell = c;
    }
    c.selectableButton.title = item.title;
    c.useCellSelectedState = YES;
    return c;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer.view == self.cv && [otherGestureRecognizer.view isKindOfClass:UIScrollView.class]) {
        return NO;
    }
    return YES;
}
#pragma mark - getter
- (EffectCollectionView *)cv {
    if (!_cv) {
        EffectCollectionFlowLayout *fl = [EffectCollectionFlowLayout new];
        fl.mode = EffectUIKitCollectionLayoutModeLeft;
        fl.sectionInset = UIEdgeInsetsMake((8), (16), (8), (16));
        fl.scrollDirection = UICollectionViewScrollDirectionVertical;
        fl.minimumLineSpacing = (20);
//        fl.minimumInteritemSpacing = (120);
        _cv = [[EffectCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:fl];
        [_cv registerClass:[SelectableCell class] forCellWithReuseIdentifier:@"SelectableCell"];
        _cv.backgroundColor = [UIColor clearColor];
        _cv.showsHorizontalScrollIndicator = NO;
        _cv.showsVerticalScrollIndicator = NO;
        _cv.allowsMultipleSelection = NO;
        _cv.dataSource = self;
        _cv.delegate = self;
//        _cv.panGestureRecognizer.delegate = self;
    }
    return _cv;
}

- (NSArray<EffectItem *> *)items {
    if (self.item.children) {
        return self.item.children;
    }
    return [NSArray arrayWithObject:self.item];
}

@end
