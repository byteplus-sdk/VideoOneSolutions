//
//  KTVSeatItemView.h
//  veRTC_Demo
//
//  Created by on 2021/11/29.
//  
//

#import <UIKit/UIKit.h>
@class KTVSeatModel;
@class KTVSongModel;

@interface KTVSeatItemView : UIView

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) KTVSeatModel *seatModel;

@property (nonatomic, copy) void (^clickBlock)(KTVSeatModel *seatModel);

- (void)updateCurrentSongModel:(KTVSongModel *)songModel;

@end
