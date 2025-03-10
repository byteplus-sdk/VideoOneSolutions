//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "BytedEffectProtocol.h"
#import <EffectUIKit/EffectUIKit.h>
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface EffectBeautyComponent : NSObject <BytedEffectComponentDelegate>{
    EffectUIManager *_effectUIManager;
}

@property (nonatomic, strong) EffectUIManager *effectUIManager;

@property (nonatomic, strong) EffectUIResourceHelper *resourceHelper;

@property (nonatomic, assign) BOOL useCache;

- (void)showError:(id)error;

- (BOOL)initEffectSDK;

@end

NS_ASSUME_NONNULL_END
