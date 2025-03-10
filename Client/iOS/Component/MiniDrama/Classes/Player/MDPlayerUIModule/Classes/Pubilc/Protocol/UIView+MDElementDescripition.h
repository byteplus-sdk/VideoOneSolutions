// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol MDInterfaceElementDescription;

@interface UIView (MDElementDescripition)

// If you use protocol 'MDInterfaceElementDescription' created a element(__kind of UIView), then you can get the element description of you previous input in UIView's propertys.
@property (nonatomic, strong) id<MDInterfaceElementDescription> elementDescription;
// To fast get elementID of property 'elementDescription', elementID == elementDescription.elementID;
@property (nonatomic, strong, readonly) NSString *elementID;

@end
