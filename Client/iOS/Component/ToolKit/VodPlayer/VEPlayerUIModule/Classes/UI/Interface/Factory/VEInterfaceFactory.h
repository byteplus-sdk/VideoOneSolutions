// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceElementDescription.h"

FOUNDATION_EXPORT NSInteger const VEInterfaceSubtitleTag;
FOUNDATION_EXPORT NSInteger const VEInterfaceButtonTag;
FOUNDATION_EXPORT NSInteger const VEInterfaceProgressViewTag;

@protocol VEInterfaceElementDataSource;
@protocol VEInterfaceElementDescription;

@class VEEventMessageBus;
@class VEEventPoster;

@protocol VEInterfaceFactoryProduction <VEInterfaceCustomView>

@end

@interface VEInterfaceFactory : NSObject

+ (UIView *)sceneOfMaterial:(id<VEInterfaceElementDataSource>)scene;

+ (UIView *)elementOfMaterial:(id<VEInterfaceElementDescription>)element scene:(id<VEInterfaceElementDataSource>)scene;

@end
