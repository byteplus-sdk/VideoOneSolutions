//
//  AIUITabItemView.h
//  AIChat
//
//  Created by ByteDance on 2025/3/17.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, AISettingTableCellViewType) {
    AISettingTableCellViewTypeArrow = 1,
    AISettingTableCellViewTypeCheckMark,
    AISettingTableCellViewTypeButton,
};

typedef NS_ENUM(NSInteger, AISettingTableCellSubtitleLayout) {
    AISettingTableCellSubtitleLayoutHorizental = 1,
    AISettingTableCellSubtitleLayoutVertical,
};

typedef NS_ENUM(NSInteger, AITableSettingViewControllerType) {
    AITableSettingViewControllerTypeNone = 0,
    AITableSettingViewControllerTypeWelcome,
    AITableSettingViewControllerTypePrompt,
    AITableSettingViewControllerTypeVoice,
    AITableSettingViewControllerTypeLLM,
    AITableSettingViewControllerTypeASR
};

NS_ASSUME_NONNULL_BEGIN

@protocol AISettingTableCellViewDelegate <NSObject>

@optional

- (void)onClickButton:(NSString *)value;

@end
// model
@interface AISettingTableCellModel : NSObject

@property (nonatomic, strong, nullable) UIImage *image;

@property (nonatomic, copy, nullable) NSString *imageURL;

@property (nonatomic, strong) NSString *title;

@property (nonatomic, strong, nullable) NSString *subTitle;

@property (nonatomic, assign) AISettingTableCellSubtitleLayout subTitlelayout;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, assign) BOOL isActive;

@property (nonatomic, copy) NSString *link;

@property (nonatomic, assign) AITableSettingViewControllerType vcType;

@end

// customView
@interface AISettingItemView : UIView

- (instancetype)initWithType:(AISettingTableCellViewType)styleType;

@property (nonatomic, strong) AISettingTableCellModel *model;

@property (nonatomic, assign) BOOL isSelected;

@property (nonatomic, weak) id<AISettingTableCellViewDelegate> delegate;

@end

// arrow cell
@interface AISettingTableCellArrowView : UITableViewCell

@property (nonatomic, strong) AISettingTableCellModel *model;

@property (nonatomic, strong) AISettingItemView *itemView;

@property (nonatomic, weak) id<AISettingTableCellViewDelegate> delegate;

@end

// buttonCell
@interface AISettingTableCellButtonView : UITableViewCell<AISettingTableCellViewDelegate>

@property (nonatomic, strong) AISettingTableCellModel *model;

@property (nonatomic, strong) AISettingItemView *itemView;

@property (nonatomic, weak) id<AISettingTableCellViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
