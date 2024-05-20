// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (VELAdd)
- (NSArray *)vel_map:(id(^)(ObjectType obj))block;

- (ObjectType)vel_objectAtIndex:(NSUInteger)index;
- (void)vel_enumerateNestedArrayWithBlock:(void (NS_NOESCAPE ^)(id _Nonnull, BOOL *))block;
@end
