//
//  miniDramaItemButtom.h
//  MiniDrama
//
//  Created by ByteDance on 2024/11/14.
//

#import "BaseButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MiniDramaMainItemStatus) {
    MiniDramaMainItemStatusDeactive,
    MiniDramaMainItemStatusActive
};

@interface MiniDramaItemButton : BaseButton

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong, nullable) UIViewController *bingedVC;

@end

NS_ASSUME_NONNULL_END
