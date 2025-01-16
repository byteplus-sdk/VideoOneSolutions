//
//  MDInterfaceArea.h
//  MDPlayerUIModule
//
//  Created by real on 2021/9/18.
//

#import "UIView+MDElementDescripition.h"
@protocol MDInterfaceElementDescription;

@interface MDInterfaceArea : UIView

@property (nonatomic, assign) NSInteger zIndex;

- (instancetype)initWithElements:(NSArray<id<MDInterfaceElementDescription>> *)elements;

- (BOOL)isEnableZone:(CGPoint)point;

- (void)invalidateLayout;

// deprecated

- (void)screenAction;

- (void)show:(BOOL)show animated:(BOOL)animated;

@end
