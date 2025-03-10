// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "DocumentSaveManager.h"
#import "EffectDataManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface SaveLocalParameterManager : DocumentSaveManager

+ (void)saveDataWith:(id)data andKey:(NSString *)key;

+ (NSArray<EffectItem *> *)reloadLocalDataWith:(EffectDataManager *)effectDataManager WithKey:(NSString *)key;

+ (void)updateNodeIntensityValue:(EffectItem *)item  WithKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
