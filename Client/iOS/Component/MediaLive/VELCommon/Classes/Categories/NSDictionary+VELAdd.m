// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NSDictionary+VELAdd.h"
#import "NSString+VELAdd.h"
@implementation NSDictionary (VELAdd)
- (NSString *)vel_getQueryEncodeSortKeys:(BOOL)sortKeys urlEncode:(BOOL)urlEncode {
    NSMutableArray *queryValues = [NSMutableArray arrayWithCapacity:self.count];
    NSArray *allKeys = self.allKeys;
    if (sortKeys) {
        allKeys = [allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2 options:NSNumericSearch];
        }];
    }
    for (NSObject *key in allKeys) {
        NSObject *value = [self objectForKey:key];
        if (urlEncode) {
            if ([value isKindOfClass:NSNull.class] || value == NSNull.null) {
                [queryValues addObject:key.description.vel_urlEncode];
            } else {
                [queryValues addObject:[NSString stringWithFormat:@"%@=%@", key.description.vel_urlEncode, value.description.vel_urlEncode]];
            }
        } else {
            if ([value isKindOfClass:NSNull.class] || value == NSNull.null) {
                [queryValues addObject:key.description];
            } else {
                [queryValues addObject:[NSString stringWithFormat:@"%@=%@", key.description, value.description]];
            }
        }
    }
    return [queryValues componentsJoinedByString:@"&"];
}

- (NSString *)vel_queryEncodeString {
    return [self vel_getQueryEncodeSortKeys:NO urlEncode:YES];
}
- (NSString *)vel_queryString {
    return [self vel_getQueryEncodeSortKeys:NO urlEncode:NO];
}
- (NSString *)vel_sortQueryEncodeString {
    return [self vel_getQueryEncodeSortKeys:YES urlEncode:YES];
}
- (NSString *)vel_sortQueryString {
    return [self vel_getQueryEncodeSortKeys:YES urlEncode:NO];
}
@end
