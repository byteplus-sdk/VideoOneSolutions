// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerBaseModule.h"
#import "MDPlayerBaseModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN
@interface MDPlayerBaseModuleLoader : MDPlayerBaseModule

@property (nonatomic, assign) BOOL removeModuleFix;
@property (nonatomic, assign) NSInteger loadCountPerTime;
@property (nonatomic, assign) BOOL enableScatter;

- (instancetype)init;
- (instancetype)initWithFrameScatter:(NSInteger)framesPerSecond;

#pragma mark - Override Method
- (NSArray<id<MDPlayerBaseModuleProtocol>> *)getCoreModules;
- (NSArray<id<MDPlayerBaseModuleProtocol>> *)getAsyncLoadModules;


#pragma mark - 添加、移除接口

/// add module
- (void)addModule:(id<MDPlayerBaseModuleProtocol>)module;
- (void)addModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules;
- (void)asyncAddModule:(id<MDPlayerBaseModuleProtocol>)module;
- (void)asyncAddModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules;

// remove module
- (void)removeModule:(id<MDPlayerBaseModuleProtocol>)module;
- (void)removeModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules;
- (void)asyncRemoveModule:(id<MDPlayerBaseModuleProtocol>)module;
- (void)asyncRemoveModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules;

@end

NS_ASSUME_NONNULL_END
