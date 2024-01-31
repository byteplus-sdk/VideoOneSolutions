// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceArea.h"
#import "VEInterfaceFloater.h"

@interface VEInterfaceSlideMenuArea : VEInterfaceArea <VEInterfaceFloaterPresentProtocol>

- (instancetype)initWithScene:(id<VEInterfaceElementDataSource>)scene;

- (void)fillElements:(NSArray<id<VEInterfaceElementDescription>> *)elements;

@end
