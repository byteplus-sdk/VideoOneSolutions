// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectItem.h"
#import "EffectDataManager.h"

@implementation EffectItem


+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(ComposerNodeModel *)model {
    EffectItem *item = [[self alloc] initWithSelectImg:selectImg unselectImg:unselectImg title:title desc:desc];
    item.ID = ID;
    item.model = model;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(ComposerNodeModel *)model showIntensityBar:(BOOL)showIntensityBar {
    EffectItem *item = [[self alloc] initWithSelectImg:selectImg unselectImg:unselectImg title:title desc:desc];
    item.ID = ID;
    item.model = model;
    item.showIntensityBar = showIntensityBar;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(ComposerNodeModel *)model tipTitle:(NSString *)tipTitle {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc model:model];
    item.tipTitle = tipTitle;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(ComposerNodeModel *)model tipTitle:(NSString *)tipTitle colorset:(NSArray *)colorset {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc model:model];
    item.tipTitle = tipTitle;
    item.colorset = colorset;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(ComposerNodeModel *)model tipTitle:(NSString *)tipTitle colorset:(NSArray *)colorset type:(EffectUIKitTpye)type {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc model:model];
    item.tipTitle = tipTitle;
    item.colorset = colorset;
    item.type = type;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(ComposerNodeModel *)model tipTitle:(NSString *)tipTitle showIntensityBar:(BOOL)showIntensityBar {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc model:model];
    item.tipTitle = tipTitle;
    item.showIntensityBar = showIntensityBar;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(ComposerNodeModel *)model tipTitle:(NSString *)tipTitle showIntensityBar:(BOOL)showIntensityBar type:(EffectUIKitTpye)type {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc model:model];
    item.tipTitle = tipTitle;
    item.showIntensityBar = showIntensityBar;
    item.type = type;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc model:(ComposerNodeModel *)model enableNegative:(BOOL)enableNegative {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc model:model];
    item.enableNegative = enableNegative;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc children:(NSArray<EffectItem *> *)children {
    EffectItem *item = [[self alloc] initWithSelectImg:selectImg unselectImg:unselectImg title:title desc:desc];
    item.ID = ID;
    item.children = children;
    for (EffectItem *i in children) {
        i.parent = item;
    }
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc children:(NSArray<EffectItem *> *)children enableMultiSelect:(BOOL)enableMultiSelect {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc children:children];
    item.enableMultiSelect = enableMultiSelect;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc children:(NSArray<EffectItem *> *)children enableMultiSelect:(BOOL)enableMultiSelect colorset:(NSArray *)colorset {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc children:children];
    item.enableMultiSelect = enableMultiSelect;
    item.colorset = colorset;
    return item;
}

+ (instancetype)initWithID:(EffectUIKitNode)ID selectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc children:(NSArray<EffectItem *> *)children enableMultiSelect:(BOOL)enableMultiSelect showIntensityBar:(BOOL)showIntensityBar {
    EffectItem *item = [self initWithID:ID selectImg:selectImg unselectImg:unselectImg title:title desc:desc children:children];
    item.enableMultiSelect = enableMultiSelect;
    item.showIntensityBar = showIntensityBar;
    return item;
}

+ (instancetype)initWithId:(EffectUIKitNode)ID image:(NSString *)image title:(NSString *)title resourcePath:(nonnull NSString *)resourcePath tip:(nonnull NSString *)tip {
    EffectItem *item = [self initWithID:ID selectImg:image unselectImg:image title:title desc:@"" model:nil];
    item.tipTitle = tip;
    item.resourcePath = resourcePath;
    item.showIntensityBar = NO;
    return item;
}

+ (instancetype)initWithId:(EffectUIKitNode)ID {
    EffectItem *item = [[self alloc] initWithSelectImg:nil unselectImg:nil title:nil desc:nil];
    item.ID = ID;
    return item;
}

+ (instancetype)initWithId:(EffectUIKitNode)ID children:(NSArray<EffectItem *> *)children {
    EffectItem *item = [[self alloc] initWithSelectImg:nil unselectImg:nil title:nil desc:nil];
    item.ID = ID;
    item.children = children;
    for (EffectItem *i in children) {
        i.parent = item;
    }
    return item;
}

+ (instancetype)initWithId:(EffectUIKitNode)ID children:(NSArray<EffectItem *> *)children enableMultiSelect:(BOOL)enableMultiSelect {
    EffectItem *item = [self initWithId:ID children:children];
    item.enableMultiSelect = enableMultiSelect;
    return item;
}
- (instancetype)init {
    if (self = [super init]) {
        [self setupDefault];
    }
    return self;
}

- (instancetype)initWithSelectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc {
    if (self = [super init]) {
        [self setupDefault];
        self.selectImg = selectImg;
        self.unselectImg = unselectImg;
        self.title = title;
        self.desc = desc;
    }
    return self;
}

- (void)setupDefault {
    self.selectImg = @"";
    self.unselectImg = @"";
    self.title = @"";
    self.desc = @"";
    self.enableMultiSelect = YES;
    self.enableNegative = NO;
    self.reuseChildrenIntensity = NO;
    self.showIntensityBar = YES;
    __weak __typeof__(self)weakSelf = self;
    self.progressBlock = ^(CGFloat progress) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self.cell updateProgress:progress complete:NO];
    };
    self.completionBlock = ^(BOOL success, NSError * _Nonnull error) {
        __strong __typeof__(weakSelf)self = weakSelf;
        [self.cell updateProgress:1 complete:YES];
    };
}

- (void)updateState {
    if (_cell) {
        if ([_cell isKindOfClass:[SelectableCell class]] ) {
            BOOL hasIntensity = self.hasIntensity;
            for (EffectItem *effectItem in self.parent.children) {
                if ([effectItem.cell isEqual:_cell]) {
                    for (EffectItem *Item in self.children) {
                        if (Item.cell.selectableButton.isPointOn == YES && Item.ID != EffectUIKitNodeTypeClose) {
                            hasIntensity = YES;
                            break;
                        }
                    }
                }
            }
            _cell.selectableButton.isPointOn = hasIntensity;
        }
        
        if (self.parent != nil) {
            [self.parent updateState];
        }
    }
}

- (CGFloat)intensity {
    if (self.lastIntensityArray != nil) {
        return [self.lastIntensityArray[self.intensityIndex] floatValue];
    }
    return [self.intensityArray[self.intensityIndex] floatValue];
}

- (void)setIntensity:(CGFloat)intensity {
    self.intensityArray[self.intensityIndex] = @(intensity);
    if (self.lastIntensityArray == nil) {
        self.lastIntensityArray = self.intensityArray.mutableCopy;
    } else {
        self.lastIntensityArray[self.intensityIndex] = @(intensity);
    }
}

- (void)reset {
    self.selectChild = nil;
    self.selectedColor = nil;
    if (self.model != nil) {
        _intensityArray = [NSMutableArray arrayWithCapacity:self.model.keyArray.count];
        for (int i = 0; i < self.model.keyArray.count; i++) {
            [_intensityArray addObject:[NSNumber numberWithFloat: self.enableNegative ? 0.5 : 0]];
        }
    } else {
        _intensityArray = @[[NSNumber numberWithFloat: self.enableNegative ? 0.5 : 0]].mutableCopy;
    }
    if (self.children != nil) {
        for (EffectItem *child in self.children) {
            [child reset];
        }
    }
    
    self.cell.selectableButton.isPointOn = NO;
    self.selected = NO;
}
- (void)resetToDefault {
    [self reset];
    [self.allChildren enumerateObjectsUsingBlock:^(EffectItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.lastIntensityArray = obj.intensityArray.mutableCopy;
        obj.intensity = obj.intensityArray.firstObject.floatValue;
    }];
}

- (NSArray<EffectItem *> *)allChildren {
    NSMutableArray<EffectItem *> *all = [NSMutableArray array];
    if (self.children != nil) {
        for (EffectItem *child in self.children) {
            [all addObject:child];
            [all addObjectsFromArray:child.allChildren];
        }
    }
    return [all copy];
}

- (BOOL)hasIntensity {
    BOOL hasIntensity = NO;
    BOOL checkIntensity = self.showIntensityBar && (self.parent.selectChild == self || self.parent.enableMultiSelect);
    /// 有子项，但是没有选中
    if (self.children != nil && self.selectChild == nil) {
        checkIntensity = NO;
    }
    if (self.children != nil) {
        for (EffectItem *child in self.children) {
            hasIntensity |= child.hasIntensity;
        }
    } else if (self.availableItem != self) {
        return self.availableItem.hasIntensity;
    } else if (checkIntensity) {
        for (NSNumber *intensity in self.intensityArray) {
            float inte = [intensity floatValue];
            if (self.enableNegative ? inte != 0.5 : inte > 0) {
                hasIntensity = YES;
                break;
            }
        }
    }
    return hasIntensity;
}

- (void)updateProgress:(CGFloat)progress complete:(BOOL)complete {
    [self.cell updateProgress:progress complete:complete];
}

#pragma mark - setter & getter
- (void)setModel:(ComposerNodeModel *)model {
    _model = model;
    [self reset];
}

- (void)setEnableNegative:(BOOL)enableNegative {
    _enableNegative = enableNegative;
    [self reset];
}

- (EffectUIKitNode)validID {
    if (self.ID != EffectUIKitNodeTypeClose) {
        return self.ID;
    }
    return self.parent.validID;
}

- (NSArray<NSNumber *> *)validIntensity {
    if (self.selectChild == nil) {
        return self.intensityArray;
    } else {
        return self.selectChild.validIntensity;
    }
}

- (NSMutableArray<NSNumber *> *)validIntensityMax {
    if (self.selectChild == nil) {
        return self.intensityMaxArray;
    } else {
        return self.selectChild.validIntensityMax;
    }
}

- (NSMutableArray<NSNumber *> *)validIntensityMin {
    if (self.selectChild == nil) {
        return self.intensityMinArray;
    } else {
        return self.selectChild.validIntensityMin;
    }
}

- (EffectItem *)availableItem {
    if (self.children == nil) {
        return self.ID == EffectUIKitNodeTypeClose ? nil : self;
    }
    return self.selectChild != nil ? self.selectChild.availableItem : nil;
}


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"children": [EffectItem class] };
}

@end

@interface EffectUIKitCategoryModel ()
@property (nonatomic, strong, readwrite) EffectItem *item;
@end

@implementation  EffectUIKitCategoryModel

+ (instancetype)categoryWithType:(EffectUIKitNode)type title:(NSString *)title item:(nonnull EffectItem *)item {
    return [[self alloc] initWithType:type title:title item:item];
}

- (instancetype)initWithType:(EffectUIKitNode)type title:(NSString *)title item:(nonnull EffectItem *)item {
    if (self = [super init]) {
        _type = type;
        _title = title;
        _item = item;
    }
    return self;
}

@end
