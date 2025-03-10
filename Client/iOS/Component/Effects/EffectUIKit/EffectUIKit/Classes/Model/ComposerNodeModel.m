// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ComposerNodeModel.h"

@implementation ComposerNodeModel

+ (instancetype)initWithPath:(NSString *)path keyArray:(NSArray<NSString *> *)keyArray tag:(NSString *)tag {
    ComposerNodeModel *model = [self initWithPath:path keyArray:keyArray];
    model.tag = tag;
    return model;
}

+ (instancetype)initWithPath:(NSString *)path keyArray:(NSArray<NSString *> *)keyArray {
    ComposerNodeModel *model = [[self alloc] init];
    model.path = path;
    model.keyArray = keyArray;
    return model;
}

+ (instancetype)initWithPath:(NSString *)path key:(NSString *)key {
    ComposerNodeModel *model = [[self alloc] init];
    model.path = path;
    model.keyArray = key == nil ? [NSArray array] : [NSArray arrayWithObject:key];
    return model;
}

@end
