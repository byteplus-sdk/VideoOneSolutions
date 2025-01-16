//
//  MDInterfaceSensor.h
//  MDPlayerUIModule
//
//  Created by real on 2021/9/25.
//

@protocol MDInterfaceElementDataSource;
@protocol MDInterfaceElementDescription;

@interface MDInterfaceSensor : UIView

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene;

- (void)performClearScreenLater;

@end
