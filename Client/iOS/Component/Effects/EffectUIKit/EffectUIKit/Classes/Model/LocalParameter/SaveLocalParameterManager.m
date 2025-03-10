// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "SaveLocalParameterManager.h"
#import "BubbleTipManager.h"
static NSString * const SaveLocal_NodesKey             = @"nodes";
static NSString * const SaveLocal_PathKey              = @"path";
static NSString * const SaveLocal_IntensityArrayKey    = @"intensityArray";
static NSString * const SaveLocal_IntensityKey         = @"intensity";
static NSString * const SaveLocal_IntensityIndexKey    = @"intensityIndex";
static NSString * const SaveLocal_SelectedColorIndexKey= @"selectedColorIndex";
static NSString * const SaveLocal_IDKey                = @"ID";
static NSString * const _UNKNOWN_ITEM_KEY                = @"UnKnown";

@implementation SaveLocalParameterManager

+ (void)saveDataWith:(id)data andKey:(NSString *)key {
    if (![data isKindOfClass:[NSSet class]]) {
        if ([data isKindOfClass:NSArray.class]) {
            data = [NSSet setWithArray:data];
        } else {
            data = [NSSet setWithObject:data];
        }
    }
    [self featureBeautyAndProSaveDataWith:data andKey:key];
}

+ (void)featureBeautyAndProSaveDataWith:(NSSet *)data andKey:(NSString *)key {
    NSMutableDictionary  *saveParameter  = [NSMutableDictionary dictionary];
    if (!saveParameter) {
        saveParameter = [NSMutableDictionary dictionary];
    }
    
    for (EffectItem *subItem in data) {
        NSString *itemKey = [self getItemSavedKey:subItem];
        if ([itemKey isEqualToString:_UNKNOWN_ITEM_KEY]) {
            continue;
        }
        [saveParameter setValue:[self getItemSavedDict:subItem]
                         forKey:itemKey];
    }
    [self saveLocalJsonToDocument:saveParameter andKey:key];
}

+ (NSMutableDictionary *)getItemSavedDict:(EffectItem *)subItem {
    NSMutableDictionary *node = [NSMutableDictionary dictionary];
    [node setValue:@(subItem.ID)                forKey:SaveLocal_IDKey];
    [node setValue:@(subItem.intensity)         forKey:SaveLocal_IntensityKey];
    [node setValue:@(subItem.intensityIndex)    forKey:SaveLocal_IntensityIndexKey];
    [node setValue:subItem.intensityArray       forKey:SaveLocal_IntensityArrayKey];
    if (subItem.model != nil) {
        [node setValue:subItem.model.path       forKey:SaveLocal_PathKey];
        [node setValue:@([subItem.colorset indexOfObject:subItem.selectedColor]) forKey:SaveLocal_SelectedColorIndexKey];
    } else {
        [node setValue:subItem.resourcePath     forKey:SaveLocal_PathKey];
    }
    return node;
}

+ (NSString *)getItemSavedKey:(EffectItem *)subItem {
    NSString *itemKey = _UNKNOWN_ITEM_KEY;
    if (subItem.model != nil) {
        itemKey = [NSString stringWithFormat:@"%zd_%@",subItem.ID,subItem.model.path];
    } else if (subItem.resourcePath != nil) {
        itemKey = [NSString stringWithFormat:@"%zd_%@",subItem.ID, subItem.resourcePath];
    }
    return itemKey;
}

+ (NSArray<EffectItem *> *)reloadLocalDataWith:(EffectDataManager *)effectDataManager WithKey:(NSString *)key {
    NSDictionary *localDictionary = [self readLoadLocalJsonWithKey:key];
    if (localDictionary) {
        NSDictionary  *saveParameter  = localDictionary;
        NSMutableArray<EffectItem *> *array = [NSMutableArray array];
        [effectDataManager.effectCategoryModelArray.copy enumerateObjectsUsingBlock:^(EffectUIKitCategoryModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj.item resetToDefault];
            [effectDataManager resetLastDefaultValueFor:obj.item];
            [obj.item.allChildren.copy enumerateObjectsUsingBlock:^(EffectItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *itemKey = [self getItemSavedKey:obj];
                if ([itemKey isEqualToString:_UNKNOWN_ITEM_KEY]) {
                    return;;
                }
                NSDictionary *savedParam = [saveParameter objectForKey:itemKey];
                if (savedParam) {
                    if (obj.showIntensityBar) {
                        NSArray <NSNumber *>* savedIntensity = savedParam[SaveLocal_IntensityArrayKey];
                        if (savedIntensity != nil && obj.intensityArray != nil) {
                            NSInteger  count = 0;
                            for (int i = 0; i < savedIntensity.count && i < obj.intensityArray.count; i++) {
                                NSNumber *number = savedIntensity[i];
                                obj.intensityArray[i] = number;
                                if ([number floatValue] == (obj.enableNegative ? 0.5 : 0)) {
                                    count++;
                                }
                            }
                            if ( count == obj.intensityArray.count ) {
                                return;
                            }
                        }
                        
                        NSInteger intensityIndex = [savedParam[SaveLocal_IntensityIndexKey] integerValue];
                        obj.intensityIndex = 0;
                        if (intensityIndex >= 0 && intensityIndex < obj.intensityArray.count) {
                            obj.intensityIndex = intensityIndex;
                        }
                        obj.intensity = [savedParam[SaveLocal_IntensityKey] floatValue];
                    }
                    NSInteger colorIndex = [savedParam[SaveLocal_SelectedColorIndexKey] integerValue];
                    if (obj.colorset.count > 0 && colorIndex < obj.colorset.count) {
                        obj.selectedColor = obj.colorset[colorIndex];
                    }
                    obj.localSave = YES;
                    EffectItem *selectObj = obj;
                    EffectItem *parent = selectObj.parent;
                    while (parent != nil && !parent.enableMultiSelect) {
                        parent.selectChild = selectObj;
                        selectObj = parent;
                        parent = parent.parent;
                    }
                    [array addObject:obj];
                }
            }];
        }];
        return array;
    } else {
        return (effectDataManager.defaultEffectOn ? effectDataManager.buttonItemArrayWithDefaultIntensity : @[]);
    }
}

+ (void)updateNodeIntensityValue:(EffectItem *)item  WithKey:(NSString *)key {
    if (item.selectChild) {
        item = item.selectChild;
    }
    NSMutableDictionary *localDictionary = [NSMutableDictionary dictionaryWithDictionary:[self readLoadLocalJsonWithKey:key]];
    if (localDictionary == nil) {
        return;
    }
    NSString *itemKey = [self getItemSavedKey:item];
    if ([itemKey isEqualToString:_UNKNOWN_ITEM_KEY]) {
        return;
    }
    if ([localDictionary objectForKey:itemKey]) {
        [localDictionary setObject:[self getItemSavedDict:item] forKey:itemKey];
        [self saveLocalJsonToDocument:localDictionary andKey:key];
    }
}

+ (void)deleteFilesWithKey:(NSString *)key {
    [super deleteFilesWithKey:key];
}

@end
