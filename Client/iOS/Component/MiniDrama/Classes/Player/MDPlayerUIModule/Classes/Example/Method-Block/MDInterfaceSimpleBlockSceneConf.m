////
////  MDInterfaceLongVideoScene.m
////  MDPlayerUIModule
////
////  Created by real on 2021/9/24.
////
//
//#import "MDInterfaceSimpleBlockSceneConf.h"
//#import "MDPlayerUIModule.h"
//#import <Masonry/Masonry.h>
//#import "MDActionButton.h"
//#import "MDProgressView.h"
//#import "MDDisplayLabel.h"
//#import "MDInterfaceSlideMenuCell.h"
//#import "MDInterfaceElementDescriptionImp.h"
//#import <ToolKit/ToolKit.h>
//
//static NSString *playButtonIdentifier = @"playButtonIdentifier";
//
//static NSString *progressViewIdentifier = @"progressViewIdentifier";
//
//static NSString *fullScreenButtonIdentifier = @"fullScreenButtonIdentifier";
//
//static NSString *backButtonIdentifier = @"backButtonIdentifier";
//
//static NSString *resolutionButtonIdentifier = @"resolutionButtonIdentifier";
//
//static NSString *playSpeedButtonIdentifier = @"playSpeedButtonIdentifier";
//
//static NSString *moreButtonIdentifier = @"moreButtonIdentifier";
//
//static NSString *lockButtonIdentifier = @"lockButtonIdentifier";
//
//static NSString *pipButtonIdentifier = @"pipButtonIdentifier";
//
//static NSString *titleLabelIdentifier = @"titleLabelIdentifier";
//
//static NSString *loopPlayButtonIdentifier = @"loopPlayButtonIdentifier";
//
//static NSString *srButtonIdentifier = @"srButtonIdentifier";
//
//static NSString *volumeGestureIdentifier = @"volumeGestureIdentifier";
//
//static NSString *brightnessGestureIdentifier = @"brightnessGestureIdentifier";
//
//static NSString *progressGestureIdentifier = @"progressGestureIdentifier";
//
//static NSString *clearScreenGestureIdentifier = @"clearScreenGestureIdentifier";
//
//static NSString *playGestureIdentifier = @"playGestureIdentifier";
//
//@implementation MDInterfaceSimpleBlockSceneConf
//
//#pragma mark ----- Tool
//
//static inline BOOL normalScreenBehaivor () {
//    return ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait);
//}
//
//static inline CGSize squareSize () {
//    if (normalScreenBehaivor()) {
//        return CGSizeMake(24.0, 24.0);
//    } else {
//        return CGSizeMake(36.0, 36.0);
//    }
//}
//
//- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup {
//    for (UIView *aView in viewGroup) {
//        if ([aView.elementID isEqualToString:identifier]) {
//            return aView;
//        }
//    }
//    return nil;
//}
//
//
//#pragma mark ----- Element Statement
//
//- (MDInterfaceElementDescriptionImp *)playButton {
//    return ({
//        MDInterfaceElementDescriptionImp *playBtnDes = [MDInterfaceElementDescriptionImp new];
//        playBtnDes.elementID = playButtonIdentifier;
//        playBtnDes.type = MDInterfaceElementTypeButton;
//        playBtnDes.elementDisplay = ^(MDActionButton *button) {
//            [button setImage:[UIImage imageNamed:@"video_pause" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
//            [button setImage:[UIImage imageNamed:@"video_play" bundleName:@"VodPlayer"] forState:UIControlStateSelected];
//        };
//        playBtnDes.elementAction = ^NSString *(MDActionButton *button) {
//            MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
//            if (playbackState == MDPlaybackStatePlaying) {
//                return MDPlayEventPause;
//            } else {
//                return MDPlayEventPlay;
//            }
//        };
//        playBtnDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDPlayEventStateChanged]) {
//                MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
//                button.selected = playbackState != MDPlaybackStatePlaying;
//            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                button.hidden = screenIsLocking ?: screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                button.hidden = screenIsLocking;
//            }
//            return @[MDPlayEventStateChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
//        };
//        playBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.center.equalTo(groupContainer);
//                make.size.equalTo(@(CGSizeMake(50.0, 50.0)));
//            }];
//        };
//        playBtnDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)progressView {
//    return ({
//        MDInterfaceElementDescriptionImp *progressViewDes = [MDInterfaceElementDescriptionImp new];
//        progressViewDes.elementID = progressViewIdentifier;
//        progressViewDes.type = MDInterfaceElementTypeProgressView;
//        progressViewDes.elementAction = ^NSDictionary* (MDProgressView *progressView) {
//            return @{MDPlayEventSeek : @(progressView.currentValue)};
//        };
//        progressViewDes.elementNotify = ^id (MDProgressView *progressView, NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDPlayEventTimeIntervalChanged]) {
//                if ([obj isKindOfClass:[NSNumber class]]) {
//                    NSTimeInterval interval = [((NSNumber *)obj) doubleValue];
//                    progressView.totalValue = [[MDEventPoster currentPoster] duration];
//                    progressView.currentValue = interval;
//                    progressView.bufferValue = [[MDEventPoster currentPoster] playableDuration];
//                };
//            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                progressView.hidden = screenIsLocking ?: screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                progressView.hidden = screenIsLocking;
//            }
//            return @[MDPlayEventTimeIntervalChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
//        };
//        progressViewDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            MDProgressView *progressView = (MDProgressView *)elementView;
//            if (normalScreenBehaivor()) {
//                UIView *fullscreenBtn = [self viewOfElementIdentifier:fullScreenButtonIdentifier inGroup:elementGroup];
//                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.leading.equalTo(groupContainer).offset(12.0);
//                    make.centerY.equalTo(fullscreenBtn);
//                    make.trailing.equalTo(fullscreenBtn.mas_leading).offset(-5.0);
//                    make.height.equalTo(@50.0);
//                }];
//                progressView.currentOrientation = UIInterfaceOrientationPortrait;
//            } else {
//                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.leading.equalTo(groupContainer).offset(45.0);
//                    make.trailing.equalTo(groupContainer).offset(-45.0);
//                    make.bottom.equalTo(groupContainer).offset(-50.0);
//                    make.height.equalTo(@40.0);
//                }];
//                progressView.currentOrientation = UIInterfaceOrientationLandscapeRight;
//            }
//        };
//        progressViewDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)fullScreenButton {
//    return ({
//        MDInterfaceElementDescriptionImp *fullScreenBtnDes = [MDInterfaceElementDescriptionImp new];
//        fullScreenBtnDes.elementID = fullScreenButtonIdentifier;
//        fullScreenBtnDes.type = MDInterfaceElementTypeButton;
//        fullScreenBtnDes.elementDisplay = ^(MDActionButton *button) {
//            [button setImage:[UIImage imageNamed:@"long_video_portrait" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
//        };
//        fullScreenBtnDes.elementAction = ^NSString *(MDActionButton *button) {
//            return MDUIEventScreenRotation;
//        };
//        fullScreenBtnDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                button.hidden = screenIsLocking ?: screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                button.hidden = screenIsLocking;
//            }
//            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
//        };
//        fullScreenBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            if (normalScreenBehaivor()) {
//                elementView.hidden = NO;
//                elementView.alpha = 1.0;
//                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.bottom.equalTo(groupContainer).offset(-10.0);
//                    make.trailing.equalTo(groupContainer).offset(-3.0);
//                    make.size.equalTo(@(CGSizeMake(44.0, 44.0)));
//                }];
//            } else {
//                elementView.hidden = YES;
//                elementView.alpha = 0.0;
//            }
//        };
//        fullScreenBtnDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)backButton {
//    return ({
//        MDInterfaceElementDescriptionImp *backBtnDes = [MDInterfaceElementDescriptionImp new];
//        backBtnDes.elementID = backButtonIdentifier;
//        backBtnDes.type = MDInterfaceElementTypeButton;
//        backBtnDes.elementDisplay = ^(MDActionButton *button) {
//            [button setImage:[UIImage imageNamed:@"video_page_back" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
//        };
//        backBtnDes.elementAction = ^NSString *(MDActionButton *button) {
//            if (normalScreenBehaivor()) {
//                return MDUIEventPageBack;
//            } else {
//                return MDUIEventScreenRotation;
//            }
//        };
//        backBtnDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                button.hidden = screenIsLocking ?: screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                button.hidden = screenIsLocking;
//            }
//            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
//        };
//        backBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            CGFloat leading = normalScreenBehaivor() ? 12.0 : 48.0;
//            CGFloat top = normalScreenBehaivor() ? 10.0 : 16.0;
//            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(groupContainer).offset(top);
//                make.leading.equalTo(groupContainer).offset(leading);
//                make.size.equalTo(@(squareSize()));
//            }];
//        };
//        backBtnDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)resolutionButton {
//    return ({
//        MDInterfaceElementDescriptionImp *resolutionBtnDes = [MDInterfaceElementDescriptionImp new];
//        resolutionBtnDes.elementID = resolutionButtonIdentifier;
//        resolutionBtnDes.type = MDInterfaceElementTypeButton;
//        resolutionBtnDes.elementDisplay = ^(MDActionButton *button) {
//            [button setImage:[UIImage imageNamed:@"long_video_resolution" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
//            [button setTitle:@"默认" forState:UIControlStateNormal];
//        };
//        resolutionBtnDes.elementAction = ^NSString* (MDActionButton *button) {
//            return MDUIEventShowResolutionMenu;
//        };
//        resolutionBtnDes.elementNotify = ^id (MDActionButton *button,  NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDPlayEventResolutionChanged]) {
//                NSString *currentResolutionTitle = [[MDEventPoster currentPoster] currentResolutionForDisplay];
//                [button setTitle:currentResolutionTitle forState:UIControlStateNormal];
//            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                button.hidden = screenIsLocking ?: screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                button.hidden = screenIsLocking;
//            }
//            return @[MDPlayEventResolutionChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];
//        };
//        resolutionBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            if (normalScreenBehaivor()) {
//                elementView.hidden = YES;
//                elementView.alpha = 0.0;
//            } else {
//                elementView.hidden = NO;
//                elementView.alpha = 1.0;
//                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.bottom.equalTo(groupContainer).offset(-9.0);
//                    make.trailing.equalTo(groupContainer.mas_trailing).offset(-50.0);
//                    make.size.equalTo(@(CGSizeMake(80.0, 50.0)));
//                }];
//            }
//        };
//        resolutionBtnDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)playSpeedButton {
//    return ({
//        MDInterfaceElementDescriptionImp *playSpeedBtnDes = [MDInterfaceElementDescriptionImp new];
//        playSpeedBtnDes.elementID = playSpeedButtonIdentifier;
//        playSpeedBtnDes.type = MDInterfaceElementTypeButton;
//        playSpeedBtnDes.elementDisplay = ^(MDActionButton *button) {
//            [button setImage:[UIImage imageNamed:@"long_video_speed" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
//            [button setTitle:@"1.0x" forState:UIControlStateNormal];
//        };
//        playSpeedBtnDes.elementAction = ^NSString* (MDActionButton *button) {
//            return MDUIEventShowPlaySpeedMenu;
//        };
//        playSpeedBtnDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDPlayEventPlaySpeedChanged]) {
//                NSString *currentSpeedTitle = [[MDEventPoster currentPoster] currentPlaySpeedForDisplay];
//                [button setTitle:currentSpeedTitle forState:UIControlStateNormal];
//            } else if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                button.hidden = screenIsLocking ?: screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                button.hidden = screenIsLocking;
//            }
//            return @[MDPlayEventPlaySpeedChanged, MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
//        };
//        playSpeedBtnDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            if (normalScreenBehaivor()) {
//                elementView.hidden = YES;
//                elementView.alpha = 0.0;
//            } else {
//                elementView.hidden = NO;
//                elementView.alpha = 1.0;
//                UIView *resolutionBtn = [self viewOfElementIdentifier:resolutionButtonIdentifier inGroup:elementGroup];
//                [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                    make.centerY.equalTo(resolutionBtn);
//                    make.trailing.equalTo(resolutionBtn.mas_leading).offset(-10.0);
//                    make.size.equalTo(@(CGSizeMake(80.0, 50.0)));
//                }];
//            }
//        };
//        playSpeedBtnDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)moreButton {
//    return ({
//        MDInterfaceElementDescriptionImp *moreButtonDes = [MDInterfaceElementDescriptionImp new];
//        moreButtonDes.elementID = moreButtonIdentifier;
//        moreButtonDes.type = MDInterfaceElementTypeButton;
//        moreButtonDes.elementDisplay = ^(MDActionButton *button) {
//            [button setImage:[UIImage imageNamed:@"long_video_more" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
//        };
//        moreButtonDes.elementAction = ^NSString* (MDActionButton *button) {
//            return MDUIEventShowMoreMenu;
//        };
//        moreButtonDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                button.hidden = screenIsLocking ?: screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                button.hidden = screenIsLocking;
//            }
//            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
//        };
//        moreButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            CGFloat trailing = normalScreenBehaivor() ? 14.0 : 54.0;
//            CGFloat top = normalScreenBehaivor() ? 10.0 : 16.0;
//            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.equalTo(groupContainer).offset(top);
//                make.trailing.equalTo(groupContainer).offset(-trailing);
//                make.size.equalTo(@(squareSize()));
//            }];
//        };
//        moreButtonDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)lockButton {
//    return ({
//        MDInterfaceElementDescriptionImp *lockButtonDes = [MDInterfaceElementDescriptionImp new];
//        lockButtonDes.elementID = lockButtonIdentifier;
//        lockButtonDes.type = MDInterfaceElementTypeButton;
//        lockButtonDes.elementDisplay = ^(MDActionButton *button) {
//            [button setImage:[UIImage imageNamed:@"long_video_unlock" bundleName:@"VodPlayer"] forState:UIControlStateNormal];
//            [button setImage:[UIImage imageNamed:@"long_video_lock" bundleName:@"VodPlayer"] forState:UIControlStateSelected];
//        };
//        lockButtonDes.elementAction = ^NSString* (MDActionButton *button) {
//            return MDUIEventLockScreen;
//        };
//        lockButtonDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                button.hidden = screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                button.selected = screenIsLocking;
//            }
//            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
//        };
//        lockButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            UIView *backBtn = [self viewOfElementIdentifier:backButtonIdentifier inGroup:elementGroup];
//            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.leading.equalTo(backBtn);
//                make.centerY.equalTo(groupContainer);
//                make.size.equalTo(@(squareSize()));
//            }];
//        };
//        lockButtonDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)pipButton {
//	return ({
//		MDInterfaceElementDescriptionImp *pipButtonDes = [MDInterfaceElementDescriptionImp new];
//		pipButtonDes.elementID = pipButtonIdentifier;
//		pipButtonDes.type = MDInterfaceElementTypeButton;
//		pipButtonDes.elementDisplay = ^(MDActionButton *button) {
//			if (@available(iOS 13.0, *)) {
//				[button setImage:[UIImage systemImageNamed:@"pip.enter"] forState:UIControlStateNormal];
//				[button setTintColor:UIColor.whiteColor];
//			} else {
//				// Fallback on earlier versions
//			}
//		};
//		pipButtonDes.elementAction = ^NSString* (MDActionButton *button) {
//			return MDUIEventStartPip;
//		};
//		pipButtonDes.elementNotify = ^id (MDActionButton *button, NSString *key, id obj) {
//			BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//			BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//			if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//				button.hidden = screenIsLocking ?: screenIsClear;
//			} else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//				button.hidden = screenIsLocking;
//			}
//			return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
//		};
//		pipButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//			UIView *backBtn = [self viewOfElementIdentifier:backButtonIdentifier inGroup:elementGroup];
//			[elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//				make.leading.equalTo(backBtn);
//				make.top.equalTo(groupContainer.mas_centerY).offset(20);
//				make.size.equalTo(@(squareSize()));
//			}];
//		};
//		pipButtonDes;
//	});
//}
//
//- (MDInterfaceElementDescriptionImp *)titleLabel {
//    return ({
//        MDInterfaceElementDescriptionImp *titleLabelDes = [MDInterfaceElementDescriptionImp new];
//        titleLabelDes.elementID = titleLabelIdentifier;
//        titleLabelDes.type = MDInterfaceElementTypeLabel;
//        titleLabelDes.elementDisplay = ^(MDDisplayLabel *label) {
//            label.text = [[MDEventPoster currentPoster] title];
//        };
//        titleLabelDes.elementNotify = ^id (MDDisplayLabel *label, NSString *key, id obj) {
//            BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
//            BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
//            if ([key isEqualToString:MDUIEventScreenClearStateChanged]) {
//                label.hidden = screenIsLocking ?: screenIsClear;
//            } else if ([key isEqualToString:MDUIEventScreenLockStateChanged]) {
//                label.hidden = screenIsLocking;
//            }
//            return @[MDUIEventScreenClearStateChanged, MDUIEventScreenLockStateChanged];;
//        };
//        titleLabelDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            UIView *backBtn = [self viewOfElementIdentifier:backButtonIdentifier inGroup:elementGroup];
//            UIView *moreBtn = [self viewOfElementIdentifier:moreButtonIdentifier inGroup:elementGroup];
//            [elementView mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.leading.equalTo(backBtn.mas_trailing).offset(8.0);
//                make.centerY.equalTo(backBtn);
//                make.trailing.equalTo(moreBtn.mas_leading).offset(8.0);
//                make.height.equalTo(@50.0);
//            }];
//        };
//        titleLabelDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)loopPlayButton {
//    return ({
//        MDInterfaceElementDescriptionImp *loopPlayButtonDes = [MDInterfaceElementDescriptionImp new];
//        loopPlayButtonDes.elementID = loopPlayButtonIdentifier;
//        loopPlayButtonDes.type = MDInterfaceElementTypeMenuNormalCell;
//        loopPlayButtonDes.elementDisplay = ^(MDInterfaceSlideMenuCell *cell) {
//            cell.titleLabel.text = NSLocalizedStringFromTable(@"title_play_panel_looper", @"VodLocalizable", nil);
//            cell.iconImgView.image = [[MDEventPoster currentPoster] loopPlayOpen] ? [UIImage imageNamed:@"long_video_loopplay_sel" bundleName:@"VodPlayer"] : [UIImage imageNamed:@"long_video_loopplay"];
//        };
//        loopPlayButtonDes.elementAction = ^NSString* (MDInterfaceSlideMenuCell *cell) {
//            return MDPlayEventChangeLoopPlayMode;
//        };
//        loopPlayButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            
//        };
//        loopPlayButtonDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)srButton {
//    return ({
//        MDInterfaceElementDescriptionImp *srButtonDes = [MDInterfaceElementDescriptionImp new];
//        srButtonDes.elementID = srButtonIdentifier;
//        srButtonDes.type = MDInterfaceElementTypeMenuNormalCell;
//        srButtonDes.elementDisplay = ^(MDInterfaceSlideMenuCell *cell) {
//            cell.titleLabel.text = NSLocalizedStringFromTable(@"title_play_panel_sr", @"VodLocalizable", nil);
//            cell.iconImgView.image = [[MDEventPoster currentPoster] srOpen] ? [UIImage imageNamed:@"long_video_sr_sel" bundleName:@"VodPlayer"] : [UIImage imageNamed:@"long_video_sr"];
//        };
//        srButtonDes.elementAction = ^NSString* (MDInterfaceSlideMenuCell *cell) {
//            return MDPlayEventChangeSREnable;
//        };
//        srButtonDes.elementWillLayout = ^(UIView *elementView, NSSet<UIView *> *elementGroup, UIView *groupContainer) {
//            
//        };
//        srButtonDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)volumeGesture {
//    return ({
//        MDInterfaceElementDescriptionImp *volumeGestureDes = [MDInterfaceElementDescriptionImp new];
//        volumeGestureDes.elementID = volumeGestureIdentifier;
//        volumeGestureDes.type = MDInterfaceElementTypeGestureRightVerticalPan;
//        volumeGestureDes.elementAction = ^NSString* (id sender) {
//            return MDUIEventVolumeIncrease;
//        };
//        volumeGestureDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)brightnessGesture {
//    return ({
//        MDInterfaceElementDescriptionImp *brightnessGestureDes = [MDInterfaceElementDescriptionImp new];
//        brightnessGestureDes.elementID = brightnessGestureIdentifier;
//        brightnessGestureDes.type = MDInterfaceElementTypeGestureLeftVerticalPan;
//        brightnessGestureDes.elementAction = ^NSString* (id sender) {
//            return MDUIEventBrightnessIncrease;
//        };
//        brightnessGestureDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)progressGesture {
//    return ({
//        MDInterfaceElementDescriptionImp *progressGestureDes = [MDInterfaceElementDescriptionImp new];
//        progressGestureDes.elementID = progressGestureIdentifier;
//        progressGestureDes.type = MDInterfaceElementTypeGestureHorizontalPan;
//        progressGestureDes.elementAction = ^NSString* (id sender) {
//            return MDPlayEventProgressValueIncrease;
//        };
//        progressGestureDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)playGesture {
//    return ({
//        MDInterfaceElementDescriptionImp *playGestureDes = [MDInterfaceElementDescriptionImp new];
//        playGestureDes.elementID = playGestureIdentifier;
//        playGestureDes.type = MDInterfaceElementTypeGestureDoubleTap;
//        playGestureDes.elementAction = ^NSString* (id sender) {
//            if ([[MDEventPoster currentPoster] screenIsLocking] || [[MDEventPoster currentPoster] screenIsClear]) {
//                return nil;
//            }
//            MDPlaybackState playbackState = [[MDEventPoster currentPoster] currentPlaybackState];
//            if (playbackState == MDPlaybackStatePlaying) {
//                return MDPlayEventPause;
//            } else {
//                return MDPlayEventPlay;
//            }
//        };
//        playGestureDes;
//    });
//}
//
//- (MDInterfaceElementDescriptionImp *)clearScreenGesture {
//    return ({
//        MDInterfaceElementDescriptionImp *clearScreenGestureDes = [MDInterfaceElementDescriptionImp new];
//        clearScreenGestureDes.elementID = clearScreenGestureIdentifier;
//        clearScreenGestureDes.type = MDInterfaceElementTypeGestureSingleTap;
//        clearScreenGestureDes.elementAction = ^NSString* (id sender) {
//            return MDUIEventClearScreen;
//        };
//        clearScreenGestureDes;
//    });
//}
//
//
//#pragma mark ----- MDInterfaceElementProtocol
//
//- (NSArray<id<MDInterfaceElementDescription>> *)customizedElements {
//    NSMutableArray *elements = [NSMutableArray array];
//    [elements addObject:[self playButton]];
//    [elements addObject:[self progressView]];
//    [elements addObject:[self fullScreenButton]];
//    [elements addObject:[self backButton]];
//    [elements addObject:[self resolutionButton]];
//    [elements addObject:[self playSpeedButton]];
//    [elements addObject:[self moreButton]];
//    [elements addObject:[self lockButton]];
//	[elements addObject:[self pipButton]];
//    [elements addObject:[self titleLabel]];
//    [elements addObject:[self loopPlayButton]];
//    [elements addObject:[self volumeGesture]];
//    [elements addObject:[self brightnessGesture]];
//    [elements addObject:[self progressGesture]];
//    [elements addObject:[self playGesture]];
//    [elements addObject:[self clearScreenGesture]];
//    [elements addObject:[self progressView]];
//    if ([[MDEventPoster currentPoster] srOpen]) {
//        [elements addObject:[self srButton]];
//    }
//    return [elements copy];
//}
//
//@end
