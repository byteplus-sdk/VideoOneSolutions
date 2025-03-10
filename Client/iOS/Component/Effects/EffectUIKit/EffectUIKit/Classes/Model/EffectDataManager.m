// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "EffectDataManager.h"
#import "EffectUIResourceHelper.h"
#import <ToolKit/Localizator.h>
#import <ToolKit/ToolKit.h>
#define EffectUIKitUIBundlePath [NSBundle.mainBundle pathForResource:@"EffectUIKit" ofType:@"bundle"]
#define EffectUIKitUIBundle [NSBundle bundleWithPath:EffectUIKitUIBundlePath]

static inline NSString *EffectUIKitLocalizedString(NSString * key, NSString * comment) {
    NSString *lan = [NSLocale.currentLocale objectForKey:NSLocaleLanguageCode];
    if (@available(iOS 10.0, *)) {
        lan = NSLocale.currentLocale.languageCode;
    }
    lan = [Localizator getCurrentLanguage];
    NSString *lanBundlePath = [EffectUIKitUIBundle pathForResource:@"zh-Hans" ofType:@"lproj"];
    NSArray <NSString *> *supportLocalized = [EffectUIKitUIBundle localizations];
    if ([lan isEqualToString:@"zh"]) {
        lan = @"zh-Hans";
    }
    if ([supportLocalized containsObject:lan]) {
        lanBundlePath = [EffectUIKitUIBundle pathForResource:lan ofType:@"lproj"];
    }
    NSBundle *lanBundle = [NSBundle bundleWithPath:lanBundlePath];
    return [lanBundle localizedStringForKey:key value:@"" table:@"EffectUIKit"];
}

typedef NS_ENUM(NSInteger, EffectUIKitUIPart) {
    EffectUIKitUIPart_1      = 1,
    EffectUIKitUIPart_2      = 2,
    EffectUIKitUIPart_3      = 3,
    EffectUIKitUIPart_4      = 4,
    EffectUIKitUIPart_5      = 5,
    EffectUIKitUIPart_6      = 6,
};

@interface EffectDataManager ()
// 风格妆功能项
@property (nonatomic, strong) NSArray<TextSwitchItem *> *styleMakeupSwitchItems;
@property (nonatomic, assign) EffectUIKitNode type;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, EffectItem *> *savedItems;

@end


@implementation EffectDataManager

- (instancetype)initWithType:(EffectUIKitType)type {
    self = [super init];
    if (self) {
        _effectType = type;
        _savedItems = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - public

- (EffectItem *)buttonItem:(EffectUIKitNode)type {
    if ([self.savedItems.allKeys containsObject:@(type)]) {
        return self.savedItems[@(type)];
    }
    
    EffectItem *item = nil;
    switch (type) {
        case EffectUIKitNodeTypeBeautyFace:
            item = [self beautyFaceItem];
            break;
        case EffectUIKitNodeTypeFilter:
            item = [self filters];
            break;
        case EffectUIKitNodeTypeSticker:
            item = [self stickers];
            break;
        default:
            break;
    }
    
    [self.savedItems setObject:item forKey:@(type)];
    return item;
}

- (NSArray<EffectUIKitCategoryModel *> *)effectCategoryModelArray {
    if (_effectCategoryModelArray == nil) {
        NSString *versionString = [NSString stringWithFormat:@"%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
        _effectCategoryModelArray = @[
            [EffectUIKitCategoryModel categoryWithType:EffectUIKitNodeTypeBeautyFace title:EffectUIKitLocalizedString(@"tab_face_beautification", nil) item:[self buttonItem:EffectUIKitNodeTypeBeautyFace]],
            [EffectUIKitCategoryModel categoryWithType:EffectUIKitNodeTypeFilter title:EffectUIKitLocalizedString(@"tab_filter", nil) item:[self buttonItem:EffectUIKitNodeTypeFilter]],
            [EffectUIKitCategoryModel categoryWithType:EffectUIKitNodeTypeSticker title:EffectUIKitLocalizedString(@"sticker", nil) item:[self buttonItem:EffectUIKitNodeTypeSticker]]
        ];
    }
    return _effectCategoryModelArray;
}


- (NSArray<EffectItem *> *)bundleResourceFilterArray {
    static dispatch_once_t onceToken;
    static NSArray *filterArr;
    dispatch_once(&onceToken, ^{
        NSError *error;
        NSString *resourcePath = [[[EffectUIResourceHelper alloc] init] filterPath:@"../"];
        NSArray *filterCategoryResourcePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:resourcePath error:&error];
        for (NSString *path in filterCategoryResourcePaths) {
            NSString *fullPath = [resourcePath stringByAppendingPathComponent:path];
            NSArray *filterResourcePaths = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:fullPath error:&error];
            NSMutableArray <EffectItem *>*filterArray = [NSMutableArray array];
            filterResourcePaths = [filterResourcePaths sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            for (NSString *filterPath in filterResourcePaths) {
                EffectItem *filter = [EffectItem new];
                filter.resourcePath = filterPath;
                [filterArray addObject:filter];
            }
            if ([path isEqualToString:@"Filter"]) {
                filterArr = filterArray;
            }
        }
    });
    return filterArr;
}


- (NSArray<EffectItem *> *)getFilterArray {
    NSString *path = [EffectUIKitUIBundle pathForResource:@"FilterData" ofType:@"json"];
    if (path == nil || ![NSFileManager.defaultManager fileExistsAtPath:path]) {
        return @[];
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSError* error;
    NSArray * jsonarray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error != nil) {
        VOLogE(VOEffectUIKit, @"Error occur when parse custom.json, error is %@", error);
        return @[];
    }
    NSMutableArray <NSString *>* localFilterResPaths = [NSMutableArray arrayWithCapacity:self.bundleResourceFilterArray.count];
    [self.bundleResourceFilterArray enumerateObjectsUsingBlock:^(EffectItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.resourcePath != nil && obj.resourcePath.length > 0) {
            [localFilterResPaths addObject:obj.resourcePath];
        }
    }];
    NSArray <EffectItem *>*items = [EffectItem modelArrayWithJson:jsonarray];
    for (EffectItem *item in items) {
        item.enableMultiSelect = NO;
        [self configFilterItem:item parent:nil];
    }
    items = [self getLocalFilter:items withLocalResources:localFilterResPaths];
    NSMutableArray <EffectItem *> * allFilters = [NSMutableArray arrayWithCapacity:10];
    /// close
    [allFilters addObject:items.firstObject];
    /// all filter
    [items enumerateObjectsUsingBlock:^(EffectItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.ID != EffectUIKitNodeTypeClose) {
            [obj.allChildren enumerateObjectsUsingBlock:^(EffectItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.ID != EffectUIKitNodeTypeClose) {
                    [allFilters addObject:obj];
                }
            }];
        }
    }];
//    if (items.count == 2 && (items.firstObject.ID == EffectUIKitNodeTypeClose)) {
//        if (items.lastObject.children.count > 0) {
//            items = items.lastObject.children;
//        }
//    }
    return allFilters;
}

- (NSArray *)getLocalFilter:(NSArray *)items withLocalResources:(NSArray <NSString *>*)resources {
    NSMutableArray *filterItems = [NSMutableArray arrayWithCapacity:items.count];
    for (EffectItem *item in items) {
        if (item.ID == EffectUIKitNodeTypeClose) {
            [filterItems addObject:item];
        } else if (item.children == nil && item.resourcePath != nil && [resources containsObject:item.resourcePath]) {
            [filterItems addObject:item];
        } else {
            item.children = [self getLocalFilter:item.children withLocalResources:resources];
            if (item.children.count == 1 && item.children.firstObject.ID != EffectUIKitNodeTypeClose) {
                [filterItems addObject:item];
            } else if (item.children.count > 1) {
                [filterItems addObject:item];
            }
        }
    }
    return filterItems;
}

- (void)configFilterItem:(EffectItem *)item parent:(EffectItem *)parent {
    item.title = EffectUIKitLocalizedString(item.title, nil);
    item.showIntensityBar = YES;
    item.parent = parent;
    if (item.children != nil) {
        item.enableMultiSelect = NO;
        for (EffectItem *child in item.children) {
            [self configFilterItem:child parent:item];
        }
    }
}


- (NSMutableArray<NSNumber *> *)defaultIntensity:(EffectUIKitNode)ID {
    NSObject *defaultIntensity = [self.defaultValue objectForKey:[NSNumber numberWithInteger:ID]];
    if ([defaultIntensity isKindOfClass:[NSNumber class]]) {
        return [NSMutableArray arrayWithObject:(NSNumber *)defaultIntensity];
    } else if ([defaultIntensity isKindOfClass:[NSArray class]]) {
        return [NSMutableArray arrayWithArray:(NSArray *)defaultIntensity];
    }
    return nil;
}

- (NSMutableArray<NSNumber *> *)defaultIntensityMax:(EffectUIKitNode)ID {
    NSObject *defaultIntensity = [self.defaultMaxValue objectForKey:[NSNumber numberWithInteger:ID]];
    if (defaultIntensity == nil) {
        NSMutableArray *intensity = [self defaultIntensity:ID].mutableCopy ?: @[@0, @0].mutableCopy;
        for (int i = 0; i < intensity.count; i++) {
            intensity[i] = @(1);
        }
        [self.defaultMaxValue setObject:intensity forKey:@(ID)];
        defaultIntensity = intensity;
    }
    if ([defaultIntensity isKindOfClass:[NSNumber class]]) {
        return [NSMutableArray arrayWithObject:(NSNumber *)defaultIntensity];
    } else if ([defaultIntensity isKindOfClass:[NSArray class]]) {
        return [NSMutableArray arrayWithArray:(NSArray *)defaultIntensity];
    }
    return nil;
}

- (NSMutableArray<NSNumber *> *)defaultIntensityMin:(EffectUIKitNode)ID {
    NSObject *defaultIntensity = [self.defaultMinValue objectForKey:[NSNumber numberWithInteger:ID]];
    if (defaultIntensity == nil) {
        NSMutableArray *intensity = [self defaultIntensity:ID].mutableCopy ?: @[@0, @0].mutableCopy;
        for (int i = 0; i < intensity.count; i++) {
            intensity[i] = @(0);
        }
        [self.defaultMinValue setObject:intensity forKey:@(ID)];
        defaultIntensity = intensity;
    }
    if ([defaultIntensity isKindOfClass:[NSNumber class]]) {
        return [NSMutableArray arrayWithObject:(NSNumber *)defaultIntensity];
    } else if ([defaultIntensity isKindOfClass:[NSArray class]]) {
        return [NSMutableArray arrayWithArray:(NSArray *)defaultIntensity];
    }
    return nil;
}

- (void)resetLastDefaultValueFor:(EffectItem *)item {
    NSArray <NSNumber *>*defaultIntensity = [self defaultIntensity:item.ID];
    [item.allChildren enumerateObjectsUsingBlock:^(EffectItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.ID != EffectUIKitNodeTypeClose) {
            NSArray <NSNumber *>*defaultArr = [self defaultIntensity:obj.ID] ?: defaultIntensity;
            if (defaultArr == nil) {
                defaultArr = (obj.enableNegative || item.enableNegative) ? @[@(0.5), @(0.5)] : @[@0, @0];
            }
            obj.lastIntensityArray = defaultArr.mutableCopy;
        }
    }];
}

- (NSArray<EffectItem *> *)buttonItemArrayWithDefaultIntensity {
    EffectItem *beautyFace = [self buttonItem:EffectUIKitNodeTypeBeautyFace];
    EffectItem *beautyFaceSelect = beautyFace.selectChild;
    [beautyFace resetToDefault];
    [self resetLastDefaultValueFor:beautyFace];
    
    [[self buttonItem:EffectUIKitNodeTypeFilter] resetToDefault];
    [self resetLastDefaultValueFor:[self buttonItem:EffectUIKitNodeTypeFilter]];
    
    
    [[self buttonItem:EffectUIKitNodeTypeSticker] resetToDefault];
    [self resetLastDefaultValueFor:[self buttonItem:EffectUIKitNodeTypeSticker]];
    
    beautyFace.selectChild = beautyFaceSelect;
    NSMutableArray<EffectItem *> *array = [NSMutableArray array];
    for (EffectItem *item in beautyFace.allChildren) {
        if ([self isDefaultEffect:item.ID]) {
            [array addObject:item];
        }
    }
    
    for (EffectItem *model in array) {
        NSArray *defaultIntensity = [self defaultIntensity:model.ID];
        if (defaultIntensity != nil && model.intensityArray != nil) {
            for (int i = 0; i < defaultIntensity.count && i < model.intensityArray.count; i++) {
                model.intensityArray[i] = defaultIntensity[i];
            }
            model.lastIntensityArray = model.intensityArray.mutableCopy;
        }
    }
    return array;
}



- (void)resetAllItem {
    for (EffectItem *item in [self.savedItems allValues]) {
        [item reset];
    }
}
+ (NSArray<TextSwitchItem *> *)styleMakeupSwitchItems {
    return @[
        [TextSwitchItem initWithTitle:EffectUIKitLocalizedString(@"style_makeup_filter", nil)
                             pointColor:[UIColor colorWithRed:48.0/255.0 green:216.0/255.0 blue:219.0/255.0 alpha:1]
                     highlightTextColor:[UIColor whiteColor]
                        normalTextColor:[UIColor colorWithWhite:1 alpha:0.8]],
        [TextSwitchItem initWithTitle:EffectUIKitLocalizedString(@"style_makeup_makeup", nil)
                             pointColor:[UIColor colorWithRed:251.0/255.0 green:176.0/255.0 blue:46.0/255.0 alpha:1]
                     highlightTextColor:[UIColor whiteColor]
                        normalTextColor:[UIColor colorWithWhite:1 alpha:0.8]],
    ];
}
- (NSArray<TextSwitchItem *> *)styleMakeupSwitchItems {
    if (_styleMakeupSwitchItems) {
        return _styleMakeupSwitchItems;
    }
    
    _styleMakeupSwitchItems = @[
        [TextSwitchItem initWithTitle:EffectUIKitLocalizedString(@"style_makeup_filter", nil)
                             pointColor:[UIColor colorWithRed:48.0/255.0 green:216.0/255.0 blue:219.0/255.0 alpha:1]
                     highlightTextColor:[UIColor whiteColor]
                        normalTextColor:[UIColor colorWithWhite:1 alpha:0.8]],
        [TextSwitchItem initWithTitle:EffectUIKitLocalizedString(@"style_makeup_makeup", nil)
                             pointColor:[UIColor colorWithRed:251.0/255.0 green:176.0/255.0 blue:46.0/255.0 alpha:1]
                     highlightTextColor:[UIColor whiteColor]
                        normalTextColor:[UIColor colorWithWhite:1 alpha:0.8]],
    ];
    return _styleMakeupSwitchItems;
}

- (NSDictionary<NSNumber *,NSObject *> *)defaultValue {
    if (self.effectType == EffectUIKitTypeLite || self.effectType == EffectUIKitTypeLiteNotAsia) {
        return [EffectDataManager defaultLiteValue];
    }
    return [EffectDataManager defaultStandardValue];
}

+ (nullable NSArray <NSNumber *>*)conflictTypesFor:(EffectUIKitNode)nodeType {
    switch (nodeType) {
        case EffectUIKitNodeTypeFilter:
            return @[@(EffectUIKitNodeTypeStyleMakeup), @(EffectUIKitNodeTypeStyleMakeup3D)];
            break;
        case EffectUIKitNodeTypeStyleMakeup:
            return @[@(EffectUIKitNodeTypeFilter), @(EffectUIKitNodeTypeStyleMakeup3D)];
            break;
        case EffectUIKitNodeTypeStyleMakeup3D:
            return @[@(EffectUIKitNodeTypeFilter), @(EffectUIKitNodeTypeStyleMakeup)];
            break;
        default:
            return nil;
            break;
    }
    return nil;
}
#pragma mark - private
+ (NSDictionary<NSNumber *,NSObject *> *)defaultStandardValue {
    static dispatch_once_t onceToken;
    static NSDictionary *dic;
    dispatch_once(&onceToken, ^{
        dic = @{
            // face
            @(EffectUIKitNodeTypeBeautyFaceSmooth): @(0.53),
            @(EffectUIKitNodeTypeBeautyFaceWhiten): @(0.38),
            @(EffectUIKitNodeTypeBeautyFaceSharp): @(0.35),
            @(EffectUIKitNodeTypeBeautyFaceClarity): @(0.23),
            // reshape
            @(EffectUIKitNodeTypeBeautyReshapeFaceOverall): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeFaceSmall): @(0.0),
            @(EffectUIKitNodeTypeBeautyReshapeFaceCut): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeCheek): @(0.65),
            @(EffectUIKitNodeTypeBeautyReshapeJaw): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeChin): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeForehead): @(0.7),
            @(EffectUIKitNodeTypeBeautyReshapeRemoveSmileFolds): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeEyeSize): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeEyeRotate): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeEyeSpacing): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeEyeMove): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeRemovePouch): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeBrightenEye): @(0.4),
            @(EffectUIKitNodeTypeBeautyReshapeNoseSize): @(0.65),
            @(EffectUIKitNodeTypeBeautyReshapeNoseWing): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeMovNose): @(0.6),
            @(EffectUIKitNodeTypeBeautyReshapeMouthZoom): @(0.6),
            @(EffectUIKitNodeTypeBeautyReshapeMouthSmile): @(0.0),
            @(EffectUIKitNodeTypeBeautyReshapeMouthMove): @(0.65),
            @(EffectUIKitNodeTypeBeautyReshapeWhitenTeeth): @(0.3),
            // body
            @(EffectUIKitNodeTypeBeautyBodyThin): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodyLegLong): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodyShrinkHead): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodySlimLeg): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodySlimWaist): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodyEnlargeBreast): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodyEnhanceHip): @(0.5),
            @(EffectUIKitNodeTypeBeautyBodyEnhanceNeck): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodySlimArm): @(0.0),
            // makeup
            @(EffectUIKitNodeTypeMakeupLip): @[@(0.5), @(0), @(0), @(0)],
            @(EffectUIKitNodeTypeMakeupBlusher): @[@(0.5), @(0), @(0), @(0)],
            @(EffectUIKitNodeTypeMakeupFacial): @(0.5),
            @(EffectUIKitNodeTypeMakeupEyebrow): @[@(0.3), @(0), @(0), @(0)],
            @(EffectUIKitNodeTypeMakeupEyeshadow): @(0.5),
            @(EffectUIKitNodeTypeMakeupEyelash): @[@(0.5), @(0), @(0), @(0)],
            @(EffectUIKitNodeTypeMakeupEyeLight): @(0.5),
            @(EffectUIKitNodeTypeMakeupPupil): @(0.5),
            @(EffectUIKitNodeTypeMakeupEyePlump): @(0.5),
            @(EffectUIKitNodeTypeMakeupHair): @(0.5),
            // filter
            @(EffectUIKitNodeTypeFilter): @(0.8),
            // style makeup
            @(EffectUIKitNodeTypeStyleMakeup): @[@(0.8), @(0.8)],
            @(EffectUIKitNodeTypeStyleHairColorA): @(0.8),
            @(EffectUIKitNodeTypeStyleHairColorB): @(0.8),
            @(EffectUIKitNodeTypeStyleHairColorC): @(0.8),
            @(EffectUIKitNodeTypeStyleHairColorD): @(0.8),
        };
    });
    return dic;
}

+ (NSDictionary<NSNumber *,NSObject *> *)defaultLiteValue {
    static dispatch_once_t onceToken;
    static NSDictionary *dic;
    dispatch_once(&onceToken, ^{
        dic = @{
            // face
            @(EffectUIKitNodeTypeBeautyFaceSmooth): @(0.53),
            @(EffectUIKitNodeTypeBeautyFaceWhiten): @(0.38),
            @(EffectUIKitNodeTypeBeautyFaceSharp): @(0.35),
            @(EffectUIKitNodeTypeBeautyFaceClarity): @(0.23),
            
            @(EffectUIKitNodeTypeBeautyReshapeBrightenEye): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeRemovePouch): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeRemoveSmileFolds): @(0.35),
            @(EffectUIKitNodeTypeBeautyReshapeWhitenTeeth): @(0.35),
            // reshape
            @(EffectUIKitNodeTypeBeautyReshapeFaceOverall): @(0.35),
            @(EffectUIKitNodeTypeBeautyReshapeFaceSmall): @(0.0),
            @(EffectUIKitNodeTypeBeautyReshapeFaceCut): @(0.0),
            @(EffectUIKitNodeTypeBeautyReshapeEyeSize): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeEyeRotate): @(0.0),
            @(EffectUIKitNodeTypeBeautyReshapeCheek): @(0.2),
            @(EffectUIKitNodeTypeBeautyReshapeJaw): @(0.4),
            @(EffectUIKitNodeTypeBeautyReshapeNoseWing): @(0.7),
            @(EffectUIKitNodeTypeBeautyReshapeMovNose): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeChin): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeForehead): @(0.5),
            @(EffectUIKitNodeTypeBeautyReshapeMouthZoom): @(0.65),
            @(EffectUIKitNodeTypeBeautyReshapeMouthSmile): @(0.0),
            @(EffectUIKitNodeTypeBeautyReshapeEyeSpacing): @(0.15),
            @(EffectUIKitNodeTypeBeautyReshapeEyeMove): @(0.0),
            @(EffectUIKitNodeTypeBeautyReshapeMouthMove): @(0.0),
            @(EffectUIKitNodeTypeMakeupEyePlump): @(0.35),
            // body
            //            @(EffectUIKitNodeTypeBeautyBodyThin): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodyLegLong): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodyShrinkHead): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodySlimLeg): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodySlimWaist): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodyEnlargeBreast): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodyEnhanceHip): @(0.5),
            @(EffectUIKitNodeTypeBeautyBodyEnhanceNeck): @(0.0),
            @(EffectUIKitNodeTypeBeautyBodySlimArm): @(0.0),
            // makeup
            @(EffectUIKitNodeTypeMakeupLip): @(0.5),
            @(EffectUIKitNodeTypeMakeupBlusher): @(0.2),
            @(EffectUIKitNodeTypeMakeupFacial): @(0.35),
            @(EffectUIKitNodeTypeMakeupEyebrow): @(0.35),
            @(EffectUIKitNodeTypeMakeupEyeshadow): @(0.35),
            @(EffectUIKitNodeTypeMakeupPupil): @(0.4),
            @(EffectUIKitNodeTypeMakeupHair): @(0.5),
            // filter
            @(EffectUIKitNodeTypeFilter): @(0.8),
            // style makeup
            @(EffectUIKitNodeTypeStyleMakeup): @[@(0.8), @(0.8)],
        };
    });
    return dic;
}

- (NSMutableDictionary<NSNumber *,NSObject *> *)defaultMaxValue {
    if (self.effectType == EffectUIKitTypeLite || self.effectType == EffectUIKitTypeLiteNotAsia) {
        return [EffectDataManager defaultLiteMaxValue];
    }
    return [EffectDataManager defaultStandardMaxValue];
}


- (NSMutableDictionary<NSNumber *,NSObject *> *)defaultMinValue {
    if (self.effectType == EffectUIKitTypeLite || self.effectType == EffectUIKitTypeLiteNotAsia) {
        return [EffectDataManager defaultLiteMinValue];
    }
    return [EffectDataManager defaultStandardMinValue];
}


+ (NSMutableDictionary<NSNumber *,NSObject *> *)defaultStandardMaxValue {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *dic;
    dispatch_once(&onceToken, ^{
        dic = @{}.mutableCopy;
    });
    return dic;
}


+ (NSMutableDictionary<NSNumber *,NSObject *> *)defaultStandardMinValue {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *dic;
    dispatch_once(&onceToken, ^{
        dic = @{}.mutableCopy;
    });
    return dic;
}

+ (NSMutableDictionary<NSNumber *,NSObject *> *)defaultLiteMaxValue {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *dic;
    dispatch_once(&onceToken, ^{
        dic = @{}.mutableCopy;
    });
    return dic;
}
+ (NSMutableDictionary<NSNumber *,NSObject *> *)defaultLiteMinValue {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *dic;
    dispatch_once(&onceToken, ^{
        dic = @{}.mutableCopy;
    });
    return dic;
}

- (BOOL)isDefaultEffect:(EffectUIKitNode)ID {
    return [[self defaultItems] containsObject:[NSNumber numberWithInteger:ID]];
}

- (NSArray<NSNumber *> *)defaultItems {
    static dispatch_once_t onceToken;
    static NSArray *lite_arr;
    static NSArray *standard_arr;
    dispatch_once(&onceToken, ^{
        lite_arr = @[
            @(EffectUIKitNodeTypeBeautyFaceSmooth),
            @(EffectUIKitNodeTypeBeautyFaceWhiten),
            @(EffectUIKitNodeTypeBeautyFaceSharp),
            @(EffectUIKitNodeTypeBeautyReshapeFaceOverall),
            @(EffectUIKitNodeTypeBeautyReshapeEyeSize),
        ];
        standard_arr = @[
            @(EffectUIKitNodeTypeBeautyFaceSmooth),
            @(EffectUIKitNodeTypeBeautyFaceWhiten),
            @(EffectUIKitNodeTypeBeautyFaceSharp),
            @(EffectUIKitNodeTypeBeautyReshapeFaceOverall),
            @(EffectUIKitNodeTypeBeautyReshapeEyeSize),
        ];
    });
    return [self isLite] ? lite_arr : standard_arr;
}

- (EffectItem *)beautyFaceItem {
    NSString *beautyPath = [self beautyPath];
    NSMutableArray *items = [NSMutableArray array];
    [items addObject:[EffectItem
                      initWithID:EffectUIKitNodeTypeClose
                      selectImg:@"iconCloseButtonSelected.png"
                      unselectImg:@"iconCloseButtonNormal.png"
                      title:EffectUIKitLocalizedString(@"close", nil)
                      desc:@""
                      model:nil]];
    
    
    [items addObject:[EffectItem
                      initWithID:EffectUIKitNodeTypeBeautyFaceWhiten
                      selectImg:@"iconFaceBeautyWhiteningSelected.png"
                      unselectImg:@"iconFaceBeautyWhiteningNormal.png"
                      title:EffectUIKitLocalizedString(@"beauty_face_whiten", nil)
                      desc:@""
                      model:[ComposerNodeModel initWithPath:beautyPath key:@"whiten"]]];
    [items addObject:[EffectItem
                      initWithID:EffectUIKitNodeTypeBeautyFaceSmooth
                      selectImg:@"iconFaceBeautySkinSelected.png"
                      unselectImg:@"iconFaceBeautySkinNormalx.png"
                      title:EffectUIKitLocalizedString(@"beauty_face_smooth", nil)
                      desc:@""
                      model:[ComposerNodeModel initWithPath:beautyPath key:@"smooth"]]];
    /// add 瘦脸(Face Size)、大眼(Eye Size)
    [items addObject:[EffectItem
                      initWithID:EffectUIKitNodeTypeBeautyReshapeFaceOverall
                      selectImg:@"iconFaceOverallSelect"
                      unselectImg:@"iconFaceOverallNormal"
                      title:EffectUIKitLocalizedString(@"beauty_face_size", nil)
                      desc:@""
                      model:[ComposerNodeModel initWithPath:[self reshapePath] key:@"Internal_Deform_Overall"]
                      enableNegative:YES]];
    
    [items addObject:[EffectItem
                      initWithID:EffectUIKitNodeTypeBeautyReshapeEyeSize
                      selectImg:@"iconEyeSizeSelect"
                      unselectImg:@"iconEyeSizeNormal"
                      title:EffectUIKitLocalizedString(@"beauty_eye_size", nil)
                      desc:@""
                      model:[ComposerNodeModel initWithPath:[self reshapePath] key:@"Internal_Deform_Eye"]]];
    
    
    [items addObject:[EffectItem
                      initWithID:EffectUIKitNodeTypeBeautyFaceSharp
                      selectImg:@"iconFaceBeautySharpSelected.png"
                      unselectImg:@"iconFaceBeautySharpNormal.png"
                      title:EffectUIKitLocalizedString(@"beauty_face_sharpen", nil)
                      desc:@""
                      model:[ComposerNodeModel initWithPath:beautyPath key:@"sharp"]]];
    
    
    [items addObject:[EffectItem
                      initWithID:EffectUIKitNodeTypeBeautyFaceClarity
                      selectImg:@"iconFaceBeautyClaritySelected.png"
                      unselectImg:@"iconFaceBeautyClarityNormal.png"
                      title:EffectUIKitLocalizedString(@"beauty_face_clarity", nil)
                      desc:@""
                      model:[ComposerNodeModel initWithPath:beautyPath key:@"clear"]]];
    return [EffectItem initWithId:EffectUIKitNodeTypeBeautyFace
                         children: [items copy]];
}

- (EffectItem *)filters {
    return [EffectItem initWithId:EffectUIKitNodeTypeFilter children:[self getFilterArray] enableMultiSelect:NO];
}

- (EffectItem *)stickers {
    EffectItem *stickerItem = [EffectItem initWithId:(EffectUIKitNodeTypeSticker) children:@[
        [EffectItem initWithID:EffectUIKitNodeTypeClose
                       selectImg:@"iconCloseButtonSelected.png"
                     unselectImg:@"iconCloseButtonNormal.png"
                           title:EffectUIKitLocalizedString(@"close", nil)
                            desc:@""
                           model:nil showIntensityBar:NO],
        [EffectItem initWithId:EffectUIKitNodeTypeSticker
                           image:@"heimaoyanjing"
                           title:EffectUIKitLocalizedString(@"sticker_heimaoyanjing", nil)
                    resourcePath:@"heimaoyanjing"
                             tip:@""],
        [EffectItem initWithId:EffectUIKitNodeTypeSticker
                           image:@"huahua"
                           title:EffectUIKitLocalizedString(@"sticker_huahua", nil)
                    resourcePath:@"huahua"
                             tip:@""],
        [EffectItem initWithId:EffectUIKitNodeTypeSticker
                           image:@"aixinpiaoluo"
                           title:EffectUIKitLocalizedString(@"stickers_aixinpiaola", nil)
                    resourcePath:@"aixinpiaola"
                             tip:@""],
        [EffectItem initWithId:EffectUIKitNodeTypeSticker
                           image:@"icon_aidou"
                           title:EffectUIKitLocalizedString(@"style_makeup_aidou", nil)
                    resourcePath:@"aidou"
                             tip:@""],
        [EffectItem initWithId:EffectUIKitNodeTypeSticker
                           image:@"icon_qise"
                           title:EffectUIKitLocalizedString(@"style_makeup_qise", nil)
                    resourcePath:@"qise"
                             tip:@""]
    ] enableMultiSelect:NO];
    stickerItem.showIntensityBar = NO;
    return stickerItem;
}


- (NSString *)beautyPath {
    return [self isLite] ? @"/beauty_IOS_lite" : @"/beauty_IOS_standard";
}

- (NSString *)reshapePath {
    return [self isLite] ? @"/reshape_lite" : @"/reshape_standard";
}

- (BOOL)hasWhiten {
    switch (self.effectType) {
        case EffectUIKitTypeLiteNotAsia:
        case EffectUIKitTypeStandardNotAsia:
            return NO;
        case EffectUIKitTypeLite:
        case EffectUIKitTypeStandard:
            return YES;
    }
}

- (BOOL)hasDoubleEyelid {
    switch (self.effectType) {
        case EffectUIKitTypeLiteNotAsia:
        case EffectUIKitTypeStandardNotAsia:
            return NO;
        case EffectUIKitTypeLite:
        case EffectUIKitTypeStandard:
            return YES;
    }
}

- (BOOL)isLite {
    switch (self.effectType) {
        case EffectUIKitTypeLite:
        case EffectUIKitTypeLiteNotAsia:
            return YES;
        case EffectUIKitTypeStandard:
        case EffectUIKitTypeStandardNotAsia:
            return NO;
    }
}
@end
