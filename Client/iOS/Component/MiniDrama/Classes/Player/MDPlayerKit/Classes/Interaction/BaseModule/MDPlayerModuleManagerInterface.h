//
//  MDPlayerModuleManagerInterface.h
//  MDPlayerKit
//

#import <Foundation/Foundation.h>
#import "MDPlayerBaseModuleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerModuleManagerInterface <NSObject>

- (void)addModule:(id<MDPlayerBaseModuleProtocol>)module;

- (void)removeModule:(id<MDPlayerBaseModuleProtocol>)module;

- (void)addModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules;

- (void)removeModules:(NSArray<id<MDPlayerBaseModuleProtocol>> *)modules;

- (void)addModuleByClzz:(Class)clzz;

- (void)addModulesByClzzArray:(NSArray<Class> *)clzzArray;

- (void)removeModuleByClzz:(Class)clzz;

- (void)removeAllModules;

- (void)setupData:(id)data;

@end

NS_ASSUME_NONNULL_END
