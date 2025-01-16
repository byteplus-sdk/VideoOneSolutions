//
//  DramaSubtitleListView.h
//  MiniDrama
//
//  Created by ByteDance on 2024/12/6.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "DramaSubtitleManage.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DramaSubtitleListViewDelegate <NSObject>

- (void)onChangeSubtitle:(NSInteger)subtitleId;

@end

@interface DramaSubtitleListViewCell : UITableViewCell

@property (nonatomic, copy) NSString *language;

@end

@interface DramaSubtitleListView : UIView

@property (nonatomic, weak) id<DramaSubtitleListViewDelegate> delegate;

@property (nonatomic, copy) NSArray<DramaSubtitleModel *> *subtitleList;

@property (nonatomic, assign) NSInteger currentSubtitleId;

- (void)show;

@end

NS_ASSUME_NONNULL_END
