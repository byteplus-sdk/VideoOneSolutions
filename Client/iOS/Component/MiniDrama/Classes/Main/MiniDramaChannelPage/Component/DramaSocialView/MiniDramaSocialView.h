//
//  MiniDramaSocialView.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MiniDramaBaseVideoModel.h"
#import "MDInterfaceElementDescription.h"

NS_ASSUME_NONNULL_BEGIN

@interface MiniDramaSocialView : UIStackView <MDInterfaceCustomView>

@property (nonatomic, strong) MiniDramaBaseVideoModel *videoModel;

- (void)handleDoubleClick:(CGPoint)location;

- (void)handleDoubleClick:(CGPoint)location inView:(__kindof UIView *)view;

@end

NS_ASSUME_NONNULL_END
