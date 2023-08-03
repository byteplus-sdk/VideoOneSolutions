// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "FeedbackManagerProtocol.h"

@interface FeedbackManagerProtocol ()

@property (nonatomic, strong) id<FeedbackManagerDelegate> feedbackDelegate;

@end

@implementation FeedbackManagerProtocol

- (instancetype)initWithSuperView:(UIView *)superView
                        scenesDic:(nonnull NSDictionary *)scenesDic {
    NSObject<FeedbackManagerDelegate> *feedback = [[NSClassFromString(@"FeedbackHome") alloc] init];
    if (feedback) {
        self.feedbackDelegate = feedback;
    }
    
    if ([self.feedbackDelegate respondsToSelector:@selector(protocol:initWithSuperView:scenesDic:)]) {
        return [self.feedbackDelegate protocol:self
                             initWithSuperView:superView
                                     scenesDic:scenesDic];
    } else {
        return nil;
    }
}

@end
