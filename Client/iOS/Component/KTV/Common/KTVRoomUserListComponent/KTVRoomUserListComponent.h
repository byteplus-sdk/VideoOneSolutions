//
//  KTVRoomUserListComponent.h
//  veRTC_Demo
//
//  Created by on 2021/5/19.
//  
//

#import <Foundation/Foundation.h>
#import "KTVRoomAudienceListsView.h"
#import "KTVRoomRaiseHandListsView.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVRoomUserListComponent : NSObject

- (void)showRoomModel:(KTVRoomModel *)roomModel
               seatID:(NSString *)seatID
         dismissBlock:(void (^)(void))dismissBlock;

- (void)update;

- (void)updateWithRed:(BOOL)isRed;

@end

NS_ASSUME_NONNULL_END
