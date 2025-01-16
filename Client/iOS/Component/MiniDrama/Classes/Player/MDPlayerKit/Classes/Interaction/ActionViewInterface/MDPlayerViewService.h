//
//  MDPlayerViewService.h
//  MDPlayerKit
//


#import <Foundation/Foundation.h>
#import "MDPlayerActionViewInterface.h"

NS_ASSUME_NONNULL_BEGIN

@class MDPlayerModuleManager;

@interface MDPlayerViewService : NSObject <MDPlayerActionViewInterface>

// weak reference module manager 
@property (nonatomic, weak, nullable) MDPlayerModuleManager *moduleManager;

@end

NS_ASSUME_NONNULL_END
