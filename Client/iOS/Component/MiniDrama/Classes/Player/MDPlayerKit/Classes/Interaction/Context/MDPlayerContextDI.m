//
//  MDPlayerContextDI.m
//  MDPlayerKit
//

#import "MDPlayerContextDI.h"
#import "MDPlayerContextStorage.h"
#import "BTDMacros.h"

@interface MDPlayerContextDI ()

@property (nonatomic, weak) id owner;

@property (nonatomic, copy) NSString *ownerServiceKey;

@property (nonatomic, strong) MDPlayerContextStorage *diStorage;

@end

@implementation MDPlayerContextDI

- (void)bindOwner:(id)owner withProtocol:(Protocol *)protocol {
    self.owner = owner;
    if (protocol) {
        self.ownerServiceKey = NSStringFromProtocol(protocol);
    } else {
        self.ownerServiceKey = nil;
    }
}

- (id)serviceForKey:(NSString *)key {
    if (BTD_isEmptyString(key)) {
        NSAssert(NO, @"player context di key is null");
        return nil;
    }
    BTDAssertMainThread();
    if ([NSThread isMainThread]) {
        if (self.owner && [self.ownerServiceKey isEqualToString:key]) {
            return self.owner;
        }
        return [self.diStorage objectForKey:key];
    } else {
        return nil;
    }
}

- (id)serviceForKey:(NSString *)key creator:(MDPlayerContextObjectCreator)creator {
    if (BTD_isEmptyString(key)) {
        NSAssert(NO, @"player context di key is null");
        return nil;
    }
    BTDAssertMainThread();
    if ([NSThread isMainThread]) {
        return [self.diStorage objectForKey:key creator:creator];
    } else {
        return nil;
    }
}

- (void)setService:(id)object forKey:(NSString *)key {
    if (BTD_isEmptyString(key)) {
        NSAssert(NO, @"player context di key is null");
        return;
    }
    BTDAssertMainThread();
    MDPlayerContextRunOnMainThread(^{
        [self.diStorage setObject:object forKey:key];
    });
}

- (void)removeServiceForKey:(NSString *)key {
    if (BTD_isEmptyString(key)) {
        NSAssert(NO, @"player context di key is null");
        return;
    }
    BTDAssertMainThread();
    MDPlayerContextRunOnMainThread(^{
        [self.diStorage removeObjectForKey:key];
    });
}

#pragma mark - Setter & Getter
- (MDPlayerContextStorage *)diStorage {
    if (!_diStorage) {
        _diStorage = [[MDPlayerContextStorage alloc] init];
    }
    return _diStorage;
}

@end
