//
//  KTVMusicTopView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <UIKit/UIKit.h>
#import "KTVSongModel.h"


NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicTopView : UIView

@property (nonatomic, assign) NSTimeInterval time;

- (void)updateWithSongModel:(KTVSongModel *)songModel
             loginUserModel:(KTVUserModel *)loginUserModel;

@end

NS_ASSUME_NONNULL_END
