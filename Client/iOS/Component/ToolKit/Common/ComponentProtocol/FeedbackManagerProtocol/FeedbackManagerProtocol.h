// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>
@class FeedbackManagerProtocol;

NS_ASSUME_NONNULL_BEGIN

@protocol FeedbackManagerDelegate <NSObject>

- (instancetype)protocol:(FeedbackManagerProtocol *)protocol
       initWithSuperView:(UIView *)superView
               scenesDic:(NSDictionary *)scenesDic;

@end

@interface FeedbackManagerProtocol : NSObject

/**
 * @brief Initialization
 * @param superView Super view
 * @param scenesDic Scenes data
 */

- (instancetype)initWithSuperView:(UIView *)superView
                        scenesDic:(NSDictionary *)scenesDic;

@end

NS_ASSUME_NONNULL_END
