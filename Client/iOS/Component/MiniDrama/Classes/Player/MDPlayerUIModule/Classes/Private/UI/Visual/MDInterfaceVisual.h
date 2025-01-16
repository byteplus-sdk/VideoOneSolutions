//
//  MDInterfaceVisual.h
//  MDPlayerUIModule
//
//  Created by real on 2021/9/24.
//

@protocol MDInterfaceElementDataSource;
@protocol MDInterfaceElementDescription;

@interface MDInterfaceVisual : UIView

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene;

@end
