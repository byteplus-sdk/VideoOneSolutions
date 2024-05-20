// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VeLiveSolutionSilentPlayer : NSObject
- (void)play;
- (void)beginDownloadWithUrl:(NSString *)downloadURLString;
@end

NS_ASSUME_NONNULL_END
