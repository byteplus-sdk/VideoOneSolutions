//
//  MDPlayerBaseModuleProtocol.h
//  MDPlayerKit
//

#import <Foundation/Foundation.h>
#import "MDPlayerViewLifeCycleProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class MDPlayerContext;

@protocol MDPlayerBaseModuleProtocol <MDPlayerViewLifeCycleProtocol>

@property (nonatomic, weak) MDPlayerContext *context;

@property (nonatomic, strong) id data;

- (void)moduleDidLoad;

- (void)moduleDidUnLoad;

@end


NS_ASSUME_NONNULL_END
