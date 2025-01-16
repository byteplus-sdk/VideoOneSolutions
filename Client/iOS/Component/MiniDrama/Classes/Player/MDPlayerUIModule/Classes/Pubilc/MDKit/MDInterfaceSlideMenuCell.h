//
//  MDInterfaceSlideMenuCell.h
//  MDPlayerUIModule
//
//  Created by real on 2021/11/16.
//

@interface MDInterfaceSlideMenuCell : UITableViewCell

@property (nonatomic, strong) UIButton *leftButton;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UILabel *titleLabel;

- (void)highlightLeftButton:(BOOL)left;

@end
