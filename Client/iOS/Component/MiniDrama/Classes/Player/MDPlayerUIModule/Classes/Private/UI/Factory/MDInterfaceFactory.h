// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@protocol MDInterfaceElementDataSource;
@protocol MDInterfaceElementDescription;
@protocol MDInterfaceCustomView;

@protocol MDInterfaceFactoryProduction <MDInterfaceCustomView>

@end

@interface MDInterfaceFactory : NSObject

+ (UIView *)sceneOfMaterial:(id<MDInterfaceElementDataSource>)scene;

+ (UIView *)elementOfMaterial:(id<MDInterfaceElementDescription>)element;

@end

