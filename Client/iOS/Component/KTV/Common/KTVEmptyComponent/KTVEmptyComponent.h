//
//  KTVEmptyComponent.h
//  veRTC_Demo
//
//  Created by on 2021/12/3.
//  
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTVEmptyComponent : NSObject

- (instancetype)initWithView:(UIView *)view 
                        rect:(CGRect)rect
                       image:(UIImage *)image
                     message:(NSString *)message;

- (void)updateMessageLabelTextColor:(UIColor *)color;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
