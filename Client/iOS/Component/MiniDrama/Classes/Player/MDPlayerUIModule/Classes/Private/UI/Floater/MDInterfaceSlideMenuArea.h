// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceArea.h"
#import "MDInterfaceFloater.h"
#import "MDInterfaceElementDescription.h"

@interface MDInterfaceSlideMenuArea : MDInterfaceArea <MDInterfaceFloaterPresentProtocol>

- (void)fillElements:(NSArray<id<MDInterfaceElementDescription>> *)elements;

@end
