//
//  KTVPickSongTableViewCell.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <UIKit/UIKit.h>
@class KTVSongModel;
NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KTVSongListViewType) {
    KTVSongListViewTypeOnline,
    KTVSongListViewTypePicked,
};

@interface KTVPickSongTableViewCell : UITableViewCell

@property (nonatomic, assign) KTVSongListViewType type;
@property (nonatomic, strong) KTVSongModel *songModel;
@property (nonatomic, copy) void(^pickSongBlock)(KTVSongModel *model);

@end

NS_ASSUME_NONNULL_END
