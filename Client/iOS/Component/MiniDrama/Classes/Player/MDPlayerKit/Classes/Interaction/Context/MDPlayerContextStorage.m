//
//  MDPlayerContextStorage.m
//  MDPlayerKit
//

#import "MDPlayerContextStorage.h"
#import "MDPlayerContextItem.h"

@interface MDPlayerContextStorage ()

@property (nonatomic, strong) NSMutableDictionary *cache;

@end

@implementation MDPlayerContextStorage

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _enableCache = YES;
        [self _openCache];
    }
    return self;
}

- (void)dealloc {
    [self _closeCache];
}

- (id)objectForKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return nil;
    }
    MDPlayerContextItem *item = [self contextItemForKey:key];

    if (![item isKindOfClass:MDPlayerContextItem.class] || ![item.key isEqualToString:key]) {
        return nil;
    }
    return item.object;
}

- (id)objectForKey:(NSString *)key creator:(MDPlayerContextObjectCreator)creator {
    if (!key || key.length <= 0) {
        return nil;
    }
    MDPlayerContextItem *item = [self contextItemForKey:key creator:creator];
    
    if (![item isKindOfClass:MDPlayerContextItem.class] || ![item.key isEqualToString:key]) {
        return nil;
    }

    return item.object;
}

- (MDPlayerContextItem *)contextItemForKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return nil;
    }
    MDPlayerContextItem *item = [self.cache objectForKey:key];
    if (!item) {
        item = [[MDPlayerContextItem alloc] init];
        item.key = key;
        [self.cache setObject:item forKey:key];
    }

    return item;
}

- (MDPlayerContextItem *)contextItemForKey:(NSString *)key creator:(MDPlayerContextObjectCreator)creator {
    if (!key || key.length <= 0) {
        return nil;
    }
    MDPlayerContextItem *item = [self contextItemForKey:key];
    if (creator) {
        item.object = creator();
    }
    
    return item;
}

- (id)setObject:(id)object forKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return nil;
    }
    MDPlayerContextItem *item = [self.cache objectForKey:key];
    if (!item) {
        item = [[MDPlayerContextItem alloc] init];
    }
    item.key = key;
    if (self.enableCache) {
        item.object = object;
    }
    [self.cache setObject:item forKey:key];
    
    [self _notify:item object:object];
    
    return item;
}

- (void)removeObjectForKey:(NSString *)key {
    if (!key || key.length <= 0) {
        return;
    }
    [self.cache removeObjectForKey:key];
}

- (void)removeAllObject {
    [self.cache removeAllObjects];
}

#pragma mark - Cache Private Method
- (void)_openCache {
    if (!_cache) {
        _cache = [NSMutableDictionary dictionary];
    }
}

- (void)_closeCache {
    if (_cache) {
        _cache = nil;
    }
}

#pragma mark - Notify Private Method
- (void)_notify:(MDPlayerContextItem *)item object:(id)object {
    [item notify:object];
}

@end
