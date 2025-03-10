// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ButtonItem.h"

@implementation ButtonItem

- (instancetype)initWithSelectImg:(NSString *)selectImg unselectImg:(NSString *)unselectImg title:(NSString *)title desc:(NSString *)desc {
    if (self = [super init]) {
        self.selectImg = selectImg;
        self.unselectImg = unselectImg;
        self.title = title;
        self.desc = desc;
    }
    return self;
}

- (NSString *)tipTitle {
    if (!_tipTitle) {
        if (_desc && ![_desc isEqualToString:@""]) {
            return _desc;
        }
        return _title;
    }
    return _tipTitle;
}

- (NSString *)tipDesc {
    if (!_tipDesc) {
        return _desc;
    }
    return _tipDesc;
}

+ (instancetype)modelWithJson:(id)json {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([self respondsToSelector:@selector(yy_modelWithJSON:)]) {
        return [self performSelector:@selector(yy_modelWithJSON:) withObject:json];
    } else if ([self respondsToSelector:@selector(modelWithJSON:)]) {
        return [self performSelector:@selector(modelWithJSON:) withObject:json];
    }
#pragma clang diagnostic pop
    NSDictionary <NSString *, id>*jsonDict = nil;
    if ([json isKindOfClass:NSData.class]) {
        jsonDict = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
    } else if ([json isKindOfClass:NSString.class]) {
        jsonDict = [self modelWithJson:[json dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([json isKindOfClass:NSDictionary.class]) {
        jsonDict = json;
    }
    if (jsonDict == nil || ![jsonDict isKindOfClass:NSDictionary.class]) {
        NSAssert(NO, @"model data invalid");
        return nil;
    }
    id modelObj = [[self alloc] init];
    NSDictionary *containerMap = [self modelContainerPropertyGenericClass];
    [jsonDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id modelValue = obj;
        if ([containerMap.allKeys containsObject:key]) {
            Class containerCls = [containerMap objectForKey:key];
            if ([obj isKindOfClass:NSArray.class]) {
                if ([containerCls respondsToSelector:@selector(modelArrayWithJson:)]) {
                    modelValue = [containerCls performSelector:@selector(modelArrayWithJson:) withObject:obj];
                }
            } else {
                if ([containerCls respondsToSelector:@selector(modelWithJson:)]) {
                    modelValue = [containerCls performSelector:@selector(modelWithJson:) withObject:obj];
                }
            }
        }
        [modelObj setValue:modelValue forKey:key];
    }];
    return modelObj;
}

+ (NSArray *)modelArrayWithJson:(id)json {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    if ([NSArray respondsToSelector:@selector(yy_modelArrayWithClass:json:)]) {
        return [NSArray performSelector:@selector(yy_modelArrayWithClass:json:) withObject:self.class withObject:json];
    } else if ([NSArray respondsToSelector:@selector(modelArrayWithClass:json:)]) {
        return [NSArray performSelector:@selector(modelArrayWithClass:json:) withObject:self.class withObject:json];
    }
#pragma clang diagnostic pop
    NSArray *jsonArray = nil;
    if ([json isKindOfClass:NSData.class]) {
        jsonArray = [NSJSONSerialization JSONObjectWithData:json options:0 error:nil];
    } else if ([json isKindOfClass:NSString.class]) {
        jsonArray = [self modelWithJson:[json dataUsingEncoding:NSUTF8StringEncoding]];
    } else if ([json isKindOfClass:NSArray.class]) {
        jsonArray = json;
    }
    if (jsonArray == nil || ![jsonArray isKindOfClass:NSArray.class]) {
        NSAssert(NO, @"model data invalid");
        return @[];
    }
    NSMutableArray *modelArray = [NSMutableArray arrayWithCapacity:jsonArray.count];
    [jsonArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id modelObj = [self modelWithJson:obj];
        if (modelObj) {
            [modelArray addObject:modelObj];
        }
    }];
    return modelArray;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{};
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key { }
@end
