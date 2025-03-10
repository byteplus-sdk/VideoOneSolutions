// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol MDInterfaceElementDescription;

@protocol MDInterfaceElementDataSource <NSObject>
// Return all the elements you want, which you will fill into the scene would be create.
- (NSArray<id<MDInterfaceElementDescription>> *)customizedElements;

@end
