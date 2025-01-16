//
//  MDInterfaceSlideMenuPercentageCell.h
//  MiniDrama
//
//  Created by ByteDance on 2024/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MDInterfaceSlideMenuPercentageCell : UITableViewCell

@property (nonatomic, strong) UIImageView *iconImgView;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, assign) CGFloat percentage;

- (void)updateCellWidth;

@end

NS_ASSUME_NONNULL_END
