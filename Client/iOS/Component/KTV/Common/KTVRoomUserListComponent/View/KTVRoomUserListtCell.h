//
//  KTVRoomUserListtCell.h
//  veRTC_Demo
//
//  Created by on 2021/5/19.
//  
//

#import <UIKit/UIKit.h>

@class KTVRoomUserListtCell;

NS_ASSUME_NONNULL_BEGIN

@protocol KTVRoomUserListtCellDelegate <NSObject>

- (void)KTVRoomUserListtCell:(KTVRoomUserListtCell *)KTVRoomUserListtCell clickButton:(id)model;

@end

@interface KTVRoomUserListtCell : UITableViewCell

@property (nonatomic, strong) KTVUserModel *model;

@property (nonatomic, assign) NSInteger indexRow;

@property (nonatomic, weak) id<KTVRoomUserListtCellDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
