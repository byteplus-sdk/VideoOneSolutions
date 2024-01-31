// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VEInterfaceElementDescriptionImp.h"

@interface NSObject (ToElementDescription)

- (VEInterfaceElementDescriptionImp *)elementDescription;

- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup;

@end
