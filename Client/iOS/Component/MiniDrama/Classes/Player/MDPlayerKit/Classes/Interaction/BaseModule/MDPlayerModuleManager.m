// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerModuleManager.h"
#import "MDPlayerContext.h"
#import "MDPlayerBaseModule.h"
#import "MDDelegateMultiplexer.h"
#import "NSDictionary+BTDAdditions.h"
#import "NSArray+BTDAdditions.h"
#import "BTDMacros.h"
#import "MDPlayerContextKeyDefine.h"

@interface MDPlayerModuleManager ()

@property (nonatomic, weak) MDPlayerContext *playerContext;

@property (nonatomic, strong) MDDelegateMultiplexer *viewLifeCycleDelegate;

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<MDPlayerBaseModuleProtocol>> *playerModulesDictionary;

@property (nonatomic, assign) BOOL isViewLoaded;

@property (nonatomic, assign) BOOL hasControlTemplate;

@property (nonatomic, strong) id data;

@end

@implementation MDPlayerModuleManager

#pragma mark - Life cycle
- (instancetype)initWithPlayerContext:(MDPlayerContext *)playerContext {
    if (self = [super init]) {
        _playerContext = playerContext;
    }
    return self;
}

#pragma mark - Public Mehtod
- (void)addModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)moduleObjects {
    if (BTD_isEmptyArray(moduleObjects)) {
        return;
    }
    [[[moduleObjects btd_map:^id _Nullable(id<MDPlayerBaseModuleProtocol> module) {
        if ([module conformsToProtocol:@protocol(MDPlayerBaseModuleProtocol)]) {
            module.context = self.playerContext;
            return module;
        }
        return nil;
    }] btd_map:^id _Nullable(id<MDPlayerBaseModuleProtocol> module) {
        NSString *key = NSStringFromClass(module.class);
        if (!module || BTD_isEmptyString(key)) {
            return nil;
        }
        if (self.data) {
            module.data = self.data;
        }
        [self.playerModulesDictionary btd_setObject:module forKey:key];
        [self.viewLifeCycleDelegate addDelegate:module];
        [module moduleDidLoad];
        return module;
    }] enumerateObjectsUsingBlock:^(NSObject<MDPlayerBaseModuleProtocol> *module, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.isViewLoaded && [module respondsToSelector:@selector(viewDidLoad)]) {
            [module viewDidLoad];
        }
        if (self.hasControlTemplate && [module respondsToSelector:@selector(controlViewTemplateDidUpdate)]) {
            [module controlViewTemplateDidUpdate];
        }
    }];
}

- (void)addModuleByClzz:(Class)clzz {
    NSString *key = [self getPlayerModuleKeyByClzz:clzz];
    if (BTD_isEmptyString(key)) {
        return;
    }
    id<MDPlayerBaseModuleProtocol> module = [[clzz alloc] init];
    [self addModule:module forKey:key];
}

- (void)addModule:(id<MDPlayerBaseModuleProtocol>)module {
    NSString *key = [self getPlayerModuleKeyByClzz:module.class];
    if (BTD_isEmptyString(key)) {
        return;
    }
    [self addModule:module forKey:key];
}

- (void)removeModule:(id<MDPlayerBaseModuleProtocol>)module {
    if ([module isKindOfClass:MDPlayerBaseModule.class] && ![(MDPlayerBaseModule *)module isLoaded]) {
        return;
    }
    NSString *key = [self getPlayerModuleKeyByClzz:module.class];
    if (BTD_isEmptyString(key)) {
        return;
    }
    [self removeModule:module forKey:key];
}

- (void)removeModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules {
    if (BTD_isEmptyArray(modules)) {
        return;
    }
    for (id<MDPlayerBaseModuleProtocol> module in modules) {
        if ([module conformsToProtocol:@protocol(MDPlayerBaseModuleProtocol)]) {
            NSString *key = NSStringFromClass(module.class);
            self.playerModulesDictionary[key] = nil;
            [self.viewLifeCycleDelegate removeDelegate:module];
            [module moduleDidUnLoad];
            module.context = nil;
        }
    }
}

- (void)removeModuleByClzz:(Class)clzz {
    NSString *key = [self getPlayerModuleKeyByClzz:clzz];
    if (BTD_isEmptyString(key)) {
        return;
    }
    [self removeModule:nil forKey:key];
}

- (void)removeAllModules {
    for (NSString *key in [self.playerModulesDictionary allKeys]) {
        id<MDPlayerBaseModuleProtocol> baseModule = [self.playerModulesDictionary objectForKey:key];
        if (baseModule) {
            [self removeModule:baseModule forKey:key];
        }
    }
    [_playerModulesDictionary removeAllObjects];
    self.viewLifeCycleDelegate = nil;
}

- (id<MDPlayerBaseModuleProtocol>)moduleByClzz:(Class)clzz {
    NSString *key = [self getPlayerModuleKeyByClzz:clzz];
    if (BTD_isEmptyString(key)) {
        return nil;
    }
    return [_playerModulesDictionary btd_objectForKey:key default:nil];
}

- (NSArray<id<MDPlayerBaseModuleProtocol>> *)allModules {
    return _playerModulesDictionary.allValues;
}

- (void)addModulesByClzzArray:(NSArray<Class> *)clzzArray {
    if (BTD_isEmptyArray(clzzArray)) {
        return;
    }
    [[[clzzArray btd_map:^id _Nullable(Class  _Nonnull clazz) {
        id<MDPlayerBaseModuleProtocol> module = [[clazz alloc] init];
        if ([module conformsToProtocol:@protocol(MDPlayerBaseModuleProtocol)]) {
            module.context = self.playerContext;
            return module;
        } else {
            return nil;
        }
    }] btd_map:^id _Nullable(id<MDPlayerBaseModuleProtocol>  _Nonnull module) {
        NSString *key = NSStringFromClass(module.class);
        if (!module || BTD_isEmptyString(key)) {
            return nil;
        }
        if (self.data) {
            module.data = self.data;
        }
        [self.playerModulesDictionary btd_setObject:module forKey:key];
        [self.viewLifeCycleDelegate addDelegate:module];
        [module moduleDidLoad];
        return module;
    }] enumerateObjectsUsingBlock:^(id<MDPlayerBaseModuleProtocol> _Nonnull module, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.isViewLoaded && [module respondsToSelector:@selector(viewDidLoad)]) {
            [module viewDidLoad];
        }
        if (self.hasControlTemplate && [module respondsToSelector:@selector(controlViewTemplateDidUpdate)]) {
            [module controlViewTemplateDidUpdate];
        }
    }];
}

- (void)setupData:(id)data {
    self.data = data;
    [self.playerModulesDictionary.allValues enumerateObjectsUsingBlock:^(id<MDPlayerBaseModuleProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.data = data;
    }];
}

#pragma mark - Protocol Mehtod
#pragma mark -- MDPlayerViewLifeCycleProtocol Delegate

- (void)viewDidLoad {
    self.isViewLoaded = YES;
    [((id<MDPlayerBaseModuleProtocol>)self.viewLifeCycleDelegate) viewDidLoad];
}

- (void)controlViewTemplateDidUpdate {
    self.hasControlTemplate = YES;
    [((id<MDPlayerBaseModuleProtocol>)self.viewLifeCycleDelegate) controlViewTemplateDidUpdate];
    [self.playerContext post:nil forKey:MDPlayerContextKeyControlTemplateChanged];
}
#pragma mark - Private Mehtod
- (NSString *)getPlayerModuleKeyByClzz:(Class)clzz {
    NSString *key = NSStringFromClass(clzz);
    if (BTD_isEmptyString(key)) {
        return nil;
    } else {
        return key;
    }
}

- (void)addModule:(id<MDPlayerBaseModuleProtocol>)module forKey:(NSString *)key {
    if (!module || ![module conformsToProtocol:@protocol(MDPlayerBaseModuleProtocol)] || BTD_isEmptyString(key)) {
        return;
    }
    if (self.data) {
        module.data = self.data;
    }
    [self.playerModulesDictionary btd_setObject:module forKey:key];
    module.context = self.playerContext;
    [self.viewLifeCycleDelegate addDelegate:module];
    [module moduleDidLoad];
    if (self.isViewLoaded && [module respondsToSelector:@selector(viewDidLoad)]) {
        [module viewDidLoad];
    }
    if (self.hasControlTemplate && [module respondsToSelector:@selector(controlViewTemplateDidUpdate)]) {
        [module controlViewTemplateDidUpdate];
    }
}

- (void)removeModule:(id<MDPlayerBaseModuleProtocol>)module forKey:(NSString *)key {
    module = module ? module : [_playerModulesDictionary btd_objectForKey:key default:nil];
    [_playerModulesDictionary removeObjectForKey:key];
    [_viewLifeCycleDelegate removeDelegate:module];
    [module moduleDidUnLoad];
}

#pragma mark - Setter & Getter

- (NSMutableDictionary<NSString *,id<MDPlayerBaseModuleProtocol> > *)playerModulesDictionary {
    if (!_playerModulesDictionary) {
        _playerModulesDictionary = [NSMutableDictionary dictionary];
    }
    return _playerModulesDictionary;
}

- (MDDelegateMultiplexer *)viewLifeCycleDelegate {
    if (!_viewLifeCycleDelegate) {
        _viewLifeCycleDelegate = [[MDDelegateMultiplexer alloc] initWithProtocol:@protocol(MDPlayerBaseModuleProtocol)];
    }
    return _viewLifeCycleDelegate;
}

@end
