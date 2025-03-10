// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef MDPlayerContextDIInterface_h
#define MDPlayerContextDIInterface_h

#import <Foundation/Foundation.h>
#import "MDPlayerContextMacros.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerContextDIService <NSObject>

/**
 * @locale zh
 * @type api
 * @brief 绑定owner提供的Service，并弱引用owner
 * @Param owner context的持有者
 * @Param protocol owner提供的Service
 */
- (void)bindOwner:(id)owner withProtocol:(Protocol *)protocol;

/**
 * @locale zh
 * @type api
 * @brief 通过Key来拿到监听的对象
 * @param key 监听Key
 */
- (nullable id)serviceForKey:(nonnull NSString *)key;
/**
 * @locale zh
 * @type api
 * @brief 通过Key来拿到监听对象，如果对象不存在通过creator动态创建
 * @param key 监听Key
 * @param creator 动态创建Block
 */
- (nullable id)serviceForKey:(nonnull NSString *)key creator:(nullable MDPlayerContextObjectCreator)creator;

/**
 * @locale zh
 * @type api
 * @brief 设置对象
 * @param object 对象
 * @param key key
 */
- (void)setService:(id)object forKey:(nonnull NSString *)key;

/**
 * @locale zh
 * @type api
 * @brief 移除对象
 * @param key key
 */
- (void)removeServiceForKey:(nonnull NSString *)key;

@end

NS_ASSUME_NONNULL_END

#endif /* MDPlayerContextDIInterface_h */
