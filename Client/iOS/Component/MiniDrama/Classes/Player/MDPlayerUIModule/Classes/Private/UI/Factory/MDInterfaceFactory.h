//
//  MDInterfaceFactory.h
//  MDPlayerUIModule
//
//  Created by real on 2021/9/18.
//

@protocol MDInterfaceElementDataSource;
@protocol MDInterfaceElementDescription;
@protocol MDInterfaceCustomView;

@protocol MDInterfaceFactoryProduction <MDInterfaceCustomView>

@end

@interface MDInterfaceFactory : NSObject

+ (UIView *)sceneOfMaterial:(id<MDInterfaceElementDataSource>)scene;

+ (UIView *)elementOfMaterial:(id<MDInterfaceElementDescription>)element;

@end

