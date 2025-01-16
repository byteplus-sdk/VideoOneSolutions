//
//  MDInterfaceFloater.h
//  MDPlayerUIModule
//
//  Created by real on 2021/11/1.
//

@protocol MDInterfaceElementDataSource;
@protocol MDInterfaceElementDescription;

@protocol MDInterfaceFloaterPresentProtocol <NSObject>

- (CGRect)enableZone;

- (void)show:(BOOL)show;

@end

@interface MDInterfaceFloater : UIControl

- (instancetype)initWithScene:(id<MDInterfaceElementDataSource>)scene;

@end
