//
//  MiniDramaPayViewController.h
//  Pods
//
//  Created by zyw on 2024/7/23.
//

#import <UIKit/UIKit.h>
#import "MDDramaEpisodeInfoModel.h"
#import "MDDramaInfoModel.h"

NS_ASSUME_NONNULL_BEGIN
@class MiniDramaPayViewController;
@protocol MiniDramaPayViewControllerDelegate <NSObject>

- (void)onUnlockEpisode:(MiniDramaPayViewController*)vc count:(NSInteger)count;

- (void)onUnlockAllEpisodes:(MiniDramaPayViewController*)vc;

@end

@interface MiniDramaPayViewController : UIViewController

- (instancetype)initWithlandscape:(BOOL)landscape;

@property (nonatomic, weak) id<MiniDramaPayViewControllerDelegate> delegate;

@property (nonatomic, strong) MDDramaInfoModel *dramaInfo;

@property (nonatomic, assign) NSInteger count;

@property (nonatomic, assign) NSInteger vipCount;

- (void)showPopup;

- (void)showPayview;

@end

NS_ASSUME_NONNULL_END
