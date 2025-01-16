//
//  MDLRUCache.h
//  MDBaseKit
//
//  Created by zyw on 2024/10/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDLRUCache : NSObject

// default capacity 200
+ (MDLRUCache *)shareInstance;

- (instancetype)initWithCapacity:(NSUInteger)capacity;

- (id)getValueForKey:(id)key;

- (void)setValue:(id)value forKey:(id)key;

@end

NS_ASSUME_NONNULL_END
