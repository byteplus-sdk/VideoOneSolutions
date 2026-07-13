//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AirPlayViewController.h"
#import "AirPlayManager.h"
#import "VEBaseVideoDetailViewController+Private.h"
#import "VEEventMessageBus.h"
#import "VEInterfaceAirPlayConf.h"
#import <AVKit/AVKit.h>
#import <ToolKit/ToolKit.h>
#import <ToolKit/Localizator.h>

@interface AirPlayViewController () <AirPlayManagerDelegate>

@property (nonatomic, strong) AirPlayManager *airPlayManager;
@property (nonatomic, copy, nullable) NSString *resolvedPlayUrl;

@property (nonatomic, strong, nullable) UIView *airPlayOverlayView;
@property (nonatomic, strong, nullable) UILabel *airPlayDeviceLabel;

@property (nonatomic, assign) BOOL needsRestartFromBeginningOnStop;

@end

@implementation AirPlayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupAirPlayManager];
    [self checkInitialAirPlayStateOnEnter];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.isMovingFromParentViewController || self.isBeingDismissed) {
        if (self.airPlayManager.delegate == self) {
            self.airPlayManager.delegate = nil;
        }
    }
}

- (void)dealloc {
    if (self.airPlayManager.delegate == self) {
        self.airPlayManager.delegate = nil;
    }
}

#pragma mark - Setup

- (void)setupAirPlayManager {
    self.airPlayManager = [AirPlayManager sharedManager];
    self.airPlayManager.delegate = self;
}

- (NSString *)currentVideoIdentifier {
    if (self.videoModel.videoId.length > 0) {
        return self.videoModel.videoId;
    }
    return self.resolvedPlayUrl.length > 0 ? self.resolvedPlayUrl : self.videoModel.playUrl;
}

- (void)checkInitialAirPlayStateOnEnter {
    AirPlayManager *mgr = self.airPlayManager;
    if (!mgr.isAirPlaying) {
        self.needsRestartFromBeginningOnStop = NO;
        return;
    }

    NSString *playingId = mgr.currentVideoIdentifier;
    NSString *currentId = [self currentVideoIdentifier];
    BOOL sameVideo = playingId.length > 0
                  && currentId.length > 0
                  && [playingId isEqualToString:currentId];
    self.needsRestartFromBeginningOnStop = !sameVideo;

    [self.playerController pause];
    self.playerController.view.hidden = YES;
    [self showAirPlayOverlay];

    [self.playerControlView.eventMessageBus postEvent:VEUIEventAirPlayStateChanged
                                           withObject:@(YES)
                                             rightNow:YES];
    VOLogI(VOVideoPlayback, @"[AirPlay] enter page while airplaying, sameVideo=%d, playingId=%@, currentId=%@", sameVideo, playingId, currentId);
}

#pragma mark - Overlay

- (UIView *)ensureAirPlayOverlayView {
    if (_airPlayOverlayView) {
        return _airPlayOverlayView;
    }
    UIView *container = self.playContainerView.contentView;
    UIView *overlay = [[UIView alloc] initWithFrame:container.bounds];
    overlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlay.backgroundColor = [UIColor blackColor];

    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"airplayvideo"]];
    icon.tintColor = [UIColor whiteColor];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [overlay addSubview:icon];

    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = 0;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [overlay addSubview:label];

    AVRoutePickerView *picker = [[AVRoutePickerView alloc] init];
    picker.activeTintColor = [UIColor whiteColor];
    picker.tintColor = [UIColor whiteColor];
    picker.translatesAutoresizingMaskIntoConstraints = NO;
    [overlay addSubview:picker];

    UILabel *pickerHint = [[UILabel alloc] init];
    pickerHint.text = LocalizedStringFromBundle(@"switch_or_stop_airplay", @"VodPlayer");
    pickerHint.textColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    pickerHint.font = [UIFont systemFontOfSize:12];
    pickerHint.textAlignment = NSTextAlignmentCenter;
    pickerHint.translatesAutoresizingMaskIntoConstraints = NO;
    [overlay addSubview:pickerHint];

    [NSLayoutConstraint activateConstraints:@[
        [icon.centerXAnchor constraintEqualToAnchor:overlay.centerXAnchor],
        [icon.centerYAnchor constraintEqualToAnchor:overlay.centerYAnchor constant:-30],
        [icon.widthAnchor constraintEqualToConstant:64],
        [icon.heightAnchor constraintEqualToConstant:64],

        [label.topAnchor constraintEqualToAnchor:icon.bottomAnchor constant:12],
        [label.leadingAnchor constraintEqualToAnchor:overlay.leadingAnchor constant:24],
        [label.trailingAnchor constraintEqualToAnchor:overlay.trailingAnchor constant:-24],

        [picker.topAnchor constraintEqualToAnchor:label.bottomAnchor constant:16],
        [picker.centerXAnchor constraintEqualToAnchor:overlay.centerXAnchor],
        [picker.widthAnchor constraintEqualToConstant:44],
        [picker.heightAnchor constraintEqualToConstant:44],

        [pickerHint.topAnchor constraintEqualToAnchor:picker.bottomAnchor constant:4],
        [pickerHint.centerXAnchor constraintEqualToAnchor:overlay.centerXAnchor],
    ]];

    [container addSubview:overlay];
    _airPlayOverlayView = overlay;
    _airPlayDeviceLabel = label;
    return overlay;
}

- (void)showAirPlayOverlay {
    UIView *overlay = [self ensureAirPlayOverlayView];
    NSString *device = [self.airPlayManager currentAirPlayDeviceName];
    self.airPlayDeviceLabel.text = [NSString stringWithFormat:@"%@%@ %@", LocalizedStringFromBundle(@"is_airplaying", @"VodPlayer"), LocalizedStringFromBundle(@"to", @"VodPlayer"), device];
    overlay.hidden = NO;
    [overlay.superview bringSubviewToFront:overlay];
}

- (void)hideAirPlayOverlay {
    _airPlayOverlayView.hidden = YES;
}

#pragma mark - Event

- (void)handleAirPlayStateChanged:(BOOL)isAirPlaying {
    VOLogI(VOVideoPlayback, @"[AirPlay] state changed, isAirPlaying=%d", isAirPlaying);
    if (isAirPlaying) {
        NSTimeInterval t = [self.playerController currentPlaybackTime];
        [self.playerController pause];
        self.playerController.view.hidden = YES;
        NSString *urlStr = self.resolvedPlayUrl.length > 0 ? self.resolvedPlayUrl : self.videoModel.playUrl;
        NSURL *url = urlStr.length > 0 ? [NSURL URLWithString:urlStr] : nil;
        [self.airPlayManager startWithURL:url
                               identifier:[self currentVideoIdentifier]
                                 fromTime:t];
        self.needsRestartFromBeginningOnStop = NO;
        [self showAirPlayOverlay];
    } else {
        NSTimeInterval t = self.needsRestartFromBeginningOnStop ? 0 : [self.airPlayManager currentTime];
        [self.airPlayManager stop];
        [self hideAirPlayOverlay];
        self.playerController.view.hidden = NO;
        if (self.needsRestartFromBeginningOnStop) {
            [self.playerController seekToTime:0 complete:nil renderComplete:nil];
            self.needsRestartFromBeginningOnStop = NO;
        } else if (t > 0) {
            [self.playerController seekToTime:t complete:nil renderComplete:nil];
        }
        [self.playerController play];
    }
    [self.playerControlView.eventMessageBus postEvent:VEUIEventAirPlayStateChanged
                                           withObject:@(isAirPlaying)
                                             rightNow:YES];
}

#pragma mark - AirPlayManagerDelegate

- (void)airPlayManager:(AirPlayManager *)manager didChangeAirPlayingState:(BOOL)isAirPlaying {
    [self handleAirPlayStateChanged:isAirPlaying];
}

- (void)airPlayManager:(AirPlayManager *)manager didFailWithError:(NSError *)error {
    [[ToastComponent shareToastComponent] showWithMessage:LocalizedStringFromBundle(@"airplay_fail", @"VodPlayer")];
    [manager stop];
}

- (void)airPlayManagerDidFinishPlayback:(AirPlayManager *)manager {
    [manager stop];
    [self hideAirPlayOverlay];
    self.playerController.view.hidden = NO;
    self.needsRestartFromBeginningOnStop = NO;
    [self.playerController seekToTime:0 complete:nil renderComplete:nil];
    [self.playerController play];
    [self.playerControlView.eventMessageBus postEvent:VEUIEventAirPlayStateChanged
                                           withObject:@(NO)
                                             rightNow:YES];
}

#pragma mark - VEVideoPlaybackDelegate

- (void)videoPlayer:(id<VEVideoPlayback>)player resolvedPlayUrl:(NSString *)url {
    VOLogI(VOVideoPlayback, @"[AirPlay] resolvedPlayUrl=%@", url);
    self.resolvedPlayUrl = url;
}

#pragma mark - Override

- (VEInterfaceBaseVideoDetailSceneConf *)interfaceScene {
    return [VEInterfaceAirPlayConf new];
}

@end
