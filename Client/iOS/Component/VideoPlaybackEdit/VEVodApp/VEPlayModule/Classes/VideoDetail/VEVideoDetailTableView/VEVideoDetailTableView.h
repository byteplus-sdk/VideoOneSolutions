//
//  VEVideoDetailTableView.h
//  AFNetworking
//
//  Created by bytedance on 2023/10/30.
//

#import <UIKit/UIKit.h>
#import "VEVideoDetailCell.h"
@class VEVideoDetailTableView;

NS_ASSUME_NONNULL_BEGIN

@protocol VEVideoDetailTableViewDelegate <NSObject>

- (void)tableView:(VEVideoDetailTableView *)tableView didSelectRowAtModel:(VEVideoModel *)model;

- (void)tableView:(VEVideoDetailTableView *)tableView loadDataWithMore:(BOOL)result;

@end

@interface VEVideoDetailTableView : UIView

@property (nonatomic, copy) NSArray<VEVideoModel *> *dataLists;

@property (nonatomic, weak) id<VEVideoDetailTableViewDelegate> delegate;

- (void)endRefreshingWithNoMoreData;

- (void)endRefresh;

@end

NS_ASSUME_NONNULL_END
