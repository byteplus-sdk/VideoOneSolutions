//
//  RTCJoinRTS.h
//  App
//
//  Created by ByteDance on 2024/6/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RTCJoinRTS : NSObject

+ (void)joinRTS:(UIViewController *)vc block:(void (^)(BOOL result))block;

@end

NS_ASSUME_NONNULL_END
