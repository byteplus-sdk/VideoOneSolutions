//
//  KTVPickSongListView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import <UIKit/UIKit.h>
#import "KTVPickSongTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVPickSongListView : UIView

@property (nonatomic, copy) NSArray<KTVSongModel*> *dataArray;
@property (nonatomic, copy) void(^pickSongBlock)(KTVSongModel *songModel);

- (instancetype)initWithType:(KTVSongListViewType)type;

- (void)refreshView;

@end

NS_ASSUME_NONNULL_END
