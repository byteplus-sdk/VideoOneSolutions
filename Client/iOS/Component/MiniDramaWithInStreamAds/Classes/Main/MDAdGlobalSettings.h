// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0

#import <Foundation/Foundation.h>

@interface MDAdGlobalSettings : NSObject

@property (class, nonatomic, assign) BOOL adsEnabled;
@property (class, nonatomic, readonly) NSString *prerollTag;
@property (class, nonatomic, readonly) NSString *midrollTag;
@property (class, nonatomic, readonly) NSString *postrollTag;
@property (class, nonatomic, readonly) NSInteger const hideDuringAdTag;

@end
