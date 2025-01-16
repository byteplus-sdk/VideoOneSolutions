//
//  MDPlayerViewLifeCycleProtocol.h
//  MDPlayerKit
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerViewLifeCycleProtocol <NSObject>

- (void)viewDidLoad;

- (void)controlViewTemplateDidUpdate;

@end

NS_ASSUME_NONNULL_END
