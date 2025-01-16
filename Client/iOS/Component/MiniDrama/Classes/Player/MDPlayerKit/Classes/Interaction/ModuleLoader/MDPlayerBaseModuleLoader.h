//
//  MDPlayerBaseModuleLoader.h
//  MDPlayerKit
//

#import "MDPlayerBaseModule.h"
#import "MDPlayerBaseModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 播放器内置基础 ModuleLoader，支持Module 异步打散加载
@interface MDPlayerBaseModuleLoader : MDPlayerBaseModule

@property (nonatomic, assign) BOOL removeModuleFix;
/// 异步加载频控，一个loop加载Module个数，默认为1
@property (nonatomic, assign) NSInteger loadCountPerTime;
/// 是否开始打散加载, 默认为NO
@property (nonatomic, assign) BOOL enableScatter;

- (instancetype)init;
- (instancetype)initWithFrameScatter:(NSInteger)framesPerSecond;

#pragma mark - Override Method

/// 核心模块，会在moduleDidLoad时机同步加载
- (NSArray<id<MDPlayerBaseModuleProtocol>> *)getCoreModules;

/// 异步加载模块，会在viewDidLoad时机开始异步加载
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
