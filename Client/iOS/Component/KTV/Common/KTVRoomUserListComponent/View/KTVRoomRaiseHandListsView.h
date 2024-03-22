//
//  KTVRoomRaiseHandListsView.h
//  veRTC_Demo
//
//  Created by on 2021/5/19.
//  
//

#import <UIKit/UIKit.h>
#import "KTVRoomUserListtCell.h"
@class KTVRoomRaiseHandListsView;

NS_ASSUME_NONNULL_BEGIN

static NSString *const KClearRedNotification = @"KClearRedNotification";

@protocol KTVRoomRaiseHandListsViewDelegate <NSObject>

- (void)KTVRoomRaiseHandListsView:(KTVRoomRaiseHandListsView *)KTVRoomRaiseHandListsView clickButton:(KTVUserModel *)model;

@end

@interface KTVRoomRaiseHandListsView : UIView

@property (nonatomic, copy) NSArray<KTVUserModel *> *dataLists;

@property (nonatomic, weak) id<KTVRoomRaiseHandListsViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
