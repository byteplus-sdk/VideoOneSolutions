//
//  MDPlayerContextStorage.h
//  MDPlayerKit
//

#import <Foundation/Foundation.h>
#import "MDPlayerContextMacros.h"

NS_ASSUME_NONNULL_BEGIN

@class MDPlayerContextItem;

@interface MDPlayerContextStorage : NSObject

/// should cache object in memory, defaults to yes
@property (nonatomic, assign) BOOL enableCache;

- (nullable id)objectForKey:(nonnull NSString *)key;
- (nullable id)objectForKey:(nonnull NSString *)key creator:(nullable MDPlayerContextObjectCreator)creator;
- (nonnull MDPlayerContextItem *)contextItemForKey:(nonnull NSString *)key;
- (nullable MDPlayerContextItem *)contextItemForKey:(nonnull NSString *)key creator:(nullable MDPlayerContextObjectCreator)creator;
- (nullable id)setObject:(id)object forKey:(nonnull NSString *)key;
- (void)removeObjectForKey:(nonnull NSString *)key;
- (void)removeAllObject;

@end
 
NS_ASSUME_NONNULL_END
