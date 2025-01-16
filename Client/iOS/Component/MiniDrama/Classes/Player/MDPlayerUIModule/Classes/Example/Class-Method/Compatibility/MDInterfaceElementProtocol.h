//
//  MDInterfaceElementProtocol.h
//  Pods
//
//  Created by real on 2022/1/6.
//

#import "MDInterfaceElementDescription.h"
#import "NSObject+ToElementDescription.h"

@protocol MDInterfaceElementProtocol <NSObject>

@optional

@property (nonatomic, copy) NSString *elementID;

@property (nonatomic, assign) MDInterfaceElementType type;

- (id)elementAction:(id)mayElementView;

- (void)elementNotify:(id)mayElementView :(NSString *)key :(id)obj;

- (id)elementSubscribe:(id)mayElementView;

- (void)elementWillLayout:(UIView *)elementView :(NSSet<UIView *> *)elementGroup :(UIView *)groupContainer;

- (void)elementDisplay:(UIView *)view;

@end
