// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDInterfaceElementDescriptionImp.h"

@interface NSObject (ToElementDescription)

- (MDInterfaceElementDescriptionImp *)elementDescription;

- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup;

@end

