//
//  MDPlayerGestureWrapper.h
//  MDPlayerKit
//


#import <Foundation/Foundation.h>
#import "MDPlayerInteractionDefine.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerGestureHandlerProtocol;

@interface MDPlayerGestureWrapper : NSObject

@property (nonatomic, strong, readonly) UIGestureRecognizer *gestureRecognizer;

@property (nonatomic, assign, readonly) MDGestureType gestureType;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer gestureType:(MDGestureType)gestureType NS_DESIGNATED_INITIALIZER;

- (void)addGestureHandler:(id<MDPlayerGestureHandlerProtocol>)handler;

- (void)removeGestureHandler:(id<MDPlayerGestureHandlerProtocol>)handler;

@end

NS_ASSUME_NONNULL_END
