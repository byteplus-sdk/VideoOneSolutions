//
//  MDInterfaceContainer.h
//  MDPlayerUIModule
//
//  Created by real on 2021/9/18.
//

@protocol MDInterfaceElementDataSource;
@protocol MDInterfaceElementDescription;

@interface MDInterfaceContainer : UIView

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene;

@end
