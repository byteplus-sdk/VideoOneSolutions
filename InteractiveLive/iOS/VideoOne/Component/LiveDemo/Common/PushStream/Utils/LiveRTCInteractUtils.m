// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveRTCInteractUtils.h"

@implementation LiveRTCInteractUtils
+ (NSString *)setPriorityForUrl:(NSString *)url {
    NSString *timeStr = [NSString stringWithFormat:@"%ld", time(NULL)];
    NSString *name = @"pri";
    if (!url || !name || !timeStr)
        return nil;
    NSURLComponents *components = [NSURLComponents componentsWithString:url];
    NSMutableArray<NSURLQueryItem *> *queryItems = [components queryItems] ? [components queryItems].mutableCopy : [NSMutableArray array];
    __block BOOL bExist = NO;
    [queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem* obj, NSUInteger idx, BOOL *stop) {
        if ([obj.name isEqual:name]) {
            bExist = YES;
            [queryItems removeObject:obj];
            *stop = YES;
        }
    }];
    NSURLQueryItem *session_id_item = [NSURLQueryItem queryItemWithName:name value:timeStr];
    [queryItems addObject:session_id_item];
    components.queryItems = queryItems;
    return [components.URL absoluteString];
}

@end
