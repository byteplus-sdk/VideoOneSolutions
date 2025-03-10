// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerBaseModuleLoader.h"
#import "MDPlayerModuleManagerInterface.h"
#import "MDFrameScatterPerform.h"
#import "MDLoopScatterPerform.h"
#import "NSArray+BTDAdditions.h"
#import "BTDMacros.h"

@interface MDPlayerBaseModuleLoader ()

@property (nonatomic, weak) id<MDPlayerModuleManagerInterface> moduleManager;

@property (nonatomic, strong) id<MDScatterPerformProtocol> scatterPerform;

@end

@implementation MDPlayerBaseModuleLoader
MDPlayerContextDILink(moduleManager, MDPlayerModuleManagerInterface, self.context);

#pragma mark - Life Cycle
- (instancetype)init {
    self = [super init];
    if (self) {
        _scatterPerform = [[MDLoopScatterPerform alloc] init];
        [self configScatter];
    }
    return self;
}

- (instancetype)initWithFrameScatter:(NSInteger)framesPerSecond {
    self = [super init];
    if (self) {
        MDFrameScatterPerform *scatter = [[MDFrameScatterPerform alloc] init];
        scatter.framesPerSecond = framesPerSecond;
        _scatterPerform = scatter;
        [self configScatter];
    }
    return self;
}

- (void)moduleDidLoad {
    [super moduleDidLoad];
    NSArray *coreModules = [[self getCoreModules] copy];
    if (coreModules.count > 0) {
        [self.moduleManager addModules:coreModules];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scatterPerform loadObjects:[self getAsyncLoadModules]];
}

- (void)moduleDidUnLoad {
    [super moduleDidUnLoad];
    [self.scatterPerform invalidate];
}

#pragma mark - Getter & Setter
- (NSInteger)loadCountPerTime {
    return self.scatterPerform.loadCountPerTime;
}

- (void)setLoadCountPerTime:(NSInteger)loadCountPerTime {
    self.scatterPerform.loadCountPerTime = loadCountPerTime;
}

- (BOOL)enableScatter {
    return self.scatterPerform.enable;
}

- (void)setEnableScatter:(BOOL)enableScatter {
    self.scatterPerform.enable = enableScatter;
}

#pragma mark - Override Method
- (NSArray<id<MDPlayerBaseModuleProtocol>> *)getCoreModules {
    return @[];
}

- (NSArray<id<MDPlayerBaseModuleProtocol>> *)getAsyncLoadModules {
    return @[];
}

#pragma mark - Public Mehtod
- (void)addModule:(id<MDPlayerBaseModuleProtocol>)module {
    if (module) {
        [self.moduleManager addModule:module];
    }
}

- (void)addModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules {
    [self.moduleManager addModules:modules];
}

- (void)asyncAddModule:(id<MDPlayerBaseModuleProtocol>)module {
    if (module) {
        [self.scatterPerform loadObjects:@[module]];
    }
}

- (void)asyncAddModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules {
    [self.scatterPerform loadObjects:modules];
}

- (void)removeModule:(id<MDPlayerBaseModuleProtocol>)module {
    if (module) {
        [self.moduleManager removeModule:module];
        if (self.removeModuleFix) {
            [self.scatterPerform removeLoadObjects:@[module]];
        } else {
            [self.scatterPerform unloadObjects:@[module]];
        }
    }
}

- (void)removeModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules {
    [self.moduleManager removeModules:modules];
    if (self.removeModuleFix) {
        [self.scatterPerform removeLoadObjects:modules];
    } else {
        [self.scatterPerform unloadObjects:modules];
    }
}

- (void)asyncRemoveModule:(id<MDPlayerBaseModuleProtocol>)module {
    if (module) {
        [self.scatterPerform unloadObjects:@[module]];
    }
}

- (void)asyncRemoveModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules {
    [self.scatterPerform unloadObjects:modules];
}

#pragma mark - Private Mehtod
- (void)configScatter {
    @weakify(self);
    _scatterPerform.performBlock = ^(NSArray *objects, BOOL load) {
        @strongify(self);
        objects = [objects btd_filter:^BOOL(id  _Nonnull obj) {
            if ([obj isKindOfClass:[MDPlayerBaseModule class]]) {
                return ((MDPlayerBaseModule *)obj).isLoaded != load;
            }
            return YES;
        }];
        if (BTD_isEmptyArray(objects)) {
            return;
        }
        if (load) {
            [self addModules:objects];
        } else {
            [self removeModules:objects];
        }
    };
}

@end
