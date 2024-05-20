// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"
#import <MediaLive/VELCommon.h>
@interface VELSettingsBaseViewModel ()
@property (nonatomic, strong, readwrite) NSMutableDictionary *extraInfo;
@property (nonatomic, weak, readwrite) UIView <VELSettingsUIViewProtocol> *settingView;
@property (nonatomic, copy, readwrite) NSString *identifier;
@property (nonatomic, strong) NSMapTable <NSString *, UIView <VELSettingsUIViewProtocol>*>* viewsMap;
@end
@implementation VELSettingsBaseViewModel
- (instancetype)init {
    if (self = [super init]) {
        _useCellSelect = YES;
        _backgroundColor = VELViewBackgroundColor;
        _containerBackgroundColor = [UIColor whiteColor];
        _containerSelectBackgroundColor = [UIColor whiteColor];
        _insets = UIEdgeInsetsZero;
        _hasBorder = NO;
        _borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _selectedBorderColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
        _cornerRadius = 8;
        _borderWidth = 0.5;
        _hasShadow = NO;
        _shadowColor = [UIColor blackColor];
        _shadowRadius = 3;
        _shadowOpacity = 0.05;
        _shadowOffset = CGSizeZero;
        _extraInfo = @{}.mutableCopy;
        _size = CGSizeMake(VELAutomaticDimension, VELAutomaticDimension);
        _identifier = [NSString stringWithFormat:@"%@_%p", self.class, self];
        _viewsMap = [NSMapTable strongToWeakObjectsMapTable];
    }
    return self;
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    self.settingView.enable = enable;
    [self.viewsMap.dictionaryRepresentation.allValues enumerateObjectsUsingBlock:^(UIView<VELSettingsUIViewProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.enable = enable;
    }];
}

- (CGSize)containerSize {
    return CGSizeMake(self.size.width - VELUIEdgeInsetsGetHorizontalValue(self.margin),
                      self.size.height - VELUIEdgeInsetsGetVerticalValue(self.margin));
}
- (Class <VELSettingsUIViewProtocol>)collectionCellClass {
    return [self.class collectionCellClass];
}

+ (Class<VELSettingsUIViewProtocol>)collectionCellClass {
    NSString *clsName = [self.vel_className stringByReplacingOccurrencesOfString:@"ViewModel" withString:@"CollectionCell"];
    Class cls = NSClassFromString(clsName);
    if (cls == nil) {
        cls = [VELSettingsBaseViewModel collectionCellClass];
    }
    NSAssert(cls != nil && [cls.new isKindOfClass:UICollectionViewCell.class], @"class %@ not found", clsName);
    return cls;
}

- (Class <VELSettingsUIViewProtocol>)tableViewCellClass {
    return [self.class tableViewCellClass];
}

+ (Class<VELSettingsUIViewProtocol>)tableViewCellClass {
    NSString *clsName = [self.vel_className stringByReplacingOccurrencesOfString:@"ViewModel" withString:@"TableCell"];
    Class cls = NSClassFromString(clsName);
    if (cls == nil) {
        cls = [VELSettingsBaseViewModel tableViewCellClass];
    }
    NSAssert(cls != nil && [cls.new isKindOfClass:UITableViewCell.class], @"class %@ not found", clsName);
    return cls;
}

- (UIView<VELSettingsUIViewProtocol> *)settingView {
    UIView <VELSettingsUIViewProtocol> *settingView = _settingView;
    if (!settingView) {
        settingView = [self createSettingsViewFor:nil];
    }
    _settingView = settingView;
    return settingView;
}

- (Class <VELSettingsUIViewProtocol>)getViewClass {
    return [self.class getViewClass];
}
+ (Class<VELSettingsUIViewProtocol>)getViewClass {
    NSString *clsName = [self.vel_className stringByReplacingOccurrencesOfString:@"ViewModel" withString:@"View"];
    NSAssert(NSClassFromString(clsName) != nil, @"class %@ not found", clsName);
    return NSClassFromString(clsName);
}

- (UIView<VELSettingsUIViewProtocol> *)createSettingsViewFor:(NSString *)identifier {
    if (identifier == nil) {
        identifier = @"default";
    }
    UIView <VELSettingsUIViewProtocol> *v = [self.viewsMap objectForKey:identifier];
    if (v == nil) {
        Class viewCls = [self getViewClass];
        v = [[viewCls alloc] init];
        [v setModel:self];
        [self.viewsMap setObject:v forKey:identifier];
    }
    return v;
}

- (void)syncSettings:(VELSettingsBaseViewModel *)model {
    self.backgroundColor = model.backgroundColor;
    self.containerBackgroundColor = model.containerBackgroundColor;
    self.containerSelectBackgroundColor = model.containerSelectBackgroundColor;
    self.insets = model.insets;
    self.margin = model.margin;
    self.hasBorder = model.hasBorder;
    self.borderColor = model.borderColor;
    self.selectedBorderColor = model.selectedBorderColor;
    self.cornerRadius = model.cornerRadius;
    self.borderWidth = model.borderWidth;
    self.hasShadow = model.hasShadow;
    self.shadowColor = model.shadowColor;
    self.shadowRadius = model.shadowRadius;
    self.shadowOpacity = model.shadowOpacity;
    self.shadowOffset = model.shadowOffset;
    self.useCellSelect = model.useCellSelect;
    self.size = model.size;
    self.enable = model.enable;
}

- (void)updateUI {
    [[self.viewsMap objectEnumerator].allObjects enumerateObjectsUsingBlock:^(UIView<VELSettingsUIViewProtocol> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj setModel:self];
    }];
}
- (void)clearDefault {
    self.insets = UIEdgeInsetsZero;
    self.margin = UIEdgeInsetsZero;
    self.backgroundColor = UIColor.clearColor;
    self.cornerRadius = 0;
    self.containerBackgroundColor = UIColor.clearColor;
    self.containerSelectBackgroundColor = UIColor.clearColor;
}
- (void)dealloc {
    VELLogDebug(@"Memory", @"%@ - dealloc", NSStringFromClass(self.class));
}
@end
const NSString *VELExtraInfoKeyClass = @"VELExtraInfoKeyClass";
const CGFloat VELEqualToSuper = -10086;
const CGFloat VELAutomaticDimension = -1;
