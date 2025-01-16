//
//  MDPlayerGestureDisableHandler.h
//  MDPlayerKit
//


#import <Foundation/Foundation.h>
#import "MDPlayerGestureHandlerProtocol.h"

NS_ASSUME_NONNULL_BEGIN

/// 专门用于屏蔽指定手势类型
@interface MDPlayerGestureDisableHandler : NSObject <MDPlayerGestureHandlerProtocol>

@property (nonatomic, assign, readonly) MDGestureType gestureType;
@property (nonatomic, copy, readonly) NSString *scene;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGestureType:(MDGestureType)gestureType scene:(NSString *)scene NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
