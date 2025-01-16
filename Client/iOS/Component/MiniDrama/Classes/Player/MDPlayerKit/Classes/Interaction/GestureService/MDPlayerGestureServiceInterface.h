//
//  MDPlayerGestureServiceInterface.h
//  MDPlayerKit
//

#ifndef MDPlayerGestureServiceInterface_h
#define MDPlayerGestureServiceInterface_h

#import "MDPlayerInteractionDefine.h"
#import "MDPlayerGestureHandlerProtocol.h"

@protocol MDPlayerGestureServiceInterface <NSObject>

@property (nonatomic, strong) UIView *gestureView;

/**
 * @locale zh
 * @type api
 * @brief 添加handler，响应指定手势类型
 * @param handler 手势处理器
 * @param gestureType 手势类型，可选多个手势类型
 */
- (void)addGestureHandler:(id<MDPlayerGestureHandlerProtocol>)handler forType:(MDGestureType)gestureType;

/**
 * @locale zh
 * @type api
 * @brief 删除handler，只针对指定手势类型
 * @param handler 手势处理器
 * @param gestureType 手势类型，可选多个手势类型
 */
- (void)removeGestureHandler:(id<MDPlayerGestureHandlerProtocol>)handler forType:(MDGestureType)gestureType;

/**
 * @locale zh
 * @type api
 * @brief 便利方法：删除handler，gestureType = MDGestureTypeAll
 * @param handler 手势处理器
 */
- (void)removeGestureHandler:(id<MDPlayerGestureHandlerProtocol>)handler;

/**
 * @locale zh
 * @type api
 * @brief 便利方法：屏蔽指定手势类型
 * @param gestureType 手势类型，可选多个手势类型
 * @param scene 场景信息，方便异常调试
 */
- (id<MDPlayerGestureHandlerProtocol>)disableGestureType:(MDGestureType)gestureType scene:(NSString *)scene;

@end

#endif /* MDPlayerGestureServiceInterface_h */
