//
//  KTVHostAvatarView.h
//  veRTC_Demo
//
//  Created by on 2021/11/29.
//  
//

#import <UIKit/UIKit.h>
#import "KTVUserModel.h"
@class KTVSongModel;

NS_ASSUME_NONNULL_BEGIN

@interface KTVHostAvatarView : UIView

@property (nonatomic, strong) KTVUserModel *userModel;

- (void)updateHostVolume:(NSNumber *)volume;

- (void)updateHostMic:(KTVUserMic)userMic;

- (void)updateCurrentSongModel:(KTVSongModel *)songModel;

@end

NS_ASSUME_NONNULL_END
