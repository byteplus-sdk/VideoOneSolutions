//
//  MiniDramaEpisodeSelectionDelegate.h
//  MiniDrama
//
//  Created by ByteDance on 2024/12/2.
//

#import <Foundation/Foundation.h>
#import "MDDramaEpisodeInfoModel.h"


@protocol MiniDramaSelectionViewDelegate <NSObject>

- (void)onDramaSelectionCallback:(MDDramaEpisodeInfoModel *)dramaVideoInfo;

@optional
- (void)onCloseHandleCallback;

- (void)onClickUnlockAllEpisode;

@end
