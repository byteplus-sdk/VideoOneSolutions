// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NSArray+VELAdd.h"

@implementation NSArray (VELAdd)

- (NSArray *)vel_map:(id (^)(id))block {
    NSUInteger n = self.count;
    if (n == 0) {
        return @[];
    }
    NSMutableArray *arr = [NSMutableArray arrayWithCapacity:n];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        id mapObj = block(obj);
        if (mapObj) {
            [arr addObject:mapObj];
        }
    }];
    return [NSArray arrayWithArray:arr];
}

- (id)vel_objectAtIndex:(NSUInteger)index {
    return index < self.count ? self[index] : nil;
}

- (void)vel_enumerateNestedArrayWithBlock:(void (NS_NOESCAPE ^)(id _Nonnull, BOOL *))block {
    BOOL stop = NO;
    for (NSInteger i = 0; i < self.count; i++) {
        id object = self[i];
        if ([object isKindOfClass:[NSArray class]]) {
            [((NSArray *)object) vel_enumerateNestedArrayWithBlock:block];
        } else {
            block(object, &stop);
        }
        if (stop) {
            return;
        }
    }
}

@end
