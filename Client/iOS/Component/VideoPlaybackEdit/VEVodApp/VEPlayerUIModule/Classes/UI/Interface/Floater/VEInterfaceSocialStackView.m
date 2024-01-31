//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceSocialStackView.h"
#import "VEEventConst.h"
#import "VEInterface.h"
#import "VEInterfaceCommentView.h"
#import "VEInterfaceDiggButton.h"
#import "VEInterfaceSocialButton.h"
#import "VEVideoModel.h"
#import <ToolKit/DeviceInforTool.h>
#import <ToolKit/NSString+Valid.h>

typedef NS_ENUM(NSUInteger, VEShortFunctionType) {
    VEShortFunctionTypeLike,
    VEShortFunctionTypeComment,
};

@interface VEInterfaceSocialStackView ()

@end

@implementation VEInterfaceSocialStackView

- (void)setAxis:(UILayoutConstraintAxis)axis {
    [super setAxis:axis];
    if (axis == UILayoutConstraintAxisVertical) {
        self.spacing = 16.0;
    } else {
        self.spacing = 24.0;
    }
}

- (void)setVideoModel:(VEVideoModel *)videoModel {
    _videoModel = videoModel;
    [self clear];

    VEInterfaceDiggButton *likeButton = [[VEInterfaceDiggButton alloc] initWithFrame:CGRectZero axis:self.axis];
    [likeButton addTarget:self action:@selector(liveVideoAction) forControlEvents:UIControlEventTouchUpInside];
    [self addArrangedSubview:likeButton];

    VEInterfaceSocialButton *commentButton = [[VEInterfaceSocialButton alloc] initWithFrame:CGRectZero axis:self.axis];
    [commentButton addTarget:self action:@selector(showCommentAction) forControlEvents:UIControlEventTouchUpInside];
    [self addArrangedSubview:commentButton];

    [self reloadData];
}

- (void)setEventMessageBus:(VEEventMessageBus *)eventMessageBus {
    _eventMessageBus = eventMessageBus;
    [eventMessageBus registEvent:VEUIEventLikeVideo withAction:@selector(doubleLiveVideoAction:) ofTarget:self];
}

- (void)clear {
    NSArray<__kindof UIView *> *arrangedSubviews = self.arrangedSubviews;
    [arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self removeArrangedSubview:obj];
        [obj removeFromSuperview];
    }];
}

- (void)reloadData {
    if (!self.arrangedSubviews.count) {
        return;
    }
    VEInterfaceDiggButton *likeButton = self.arrangedSubviews[VEShortFunctionTypeLike];
    likeButton.liked = _videoModel.isSelfLiked;
    likeButton.title = [NSString stringForCount:_videoModel.likeCount];

    VEInterfaceSocialButton *commentButton = self.arrangedSubviews[VEShortFunctionTypeComment];
    commentButton.image = [UIImage imageNamed:(self.axis == UILayoutConstraintAxisVertical) ? @"vod_feed_comment" : @"vod_feed_comment_deformity"];
    commentButton.title = [NSString stringForCount:_videoModel.commentCount];
}

#pragma mark - Event
- (void)doubleLiveVideoAction:(NSDictionary *)obj {
    CGPoint point = [obj[VEUIEventLikeVideo][@"location"] CGPointValue];
    [VEInterfaceDiggButton playDiggAnimationInView:self.superview location:point];
    if (_videoModel.selfLiked) {
        return;
    }
    [self liveVideoAction];
}

- (void)liveVideoAction {
    VEInterfaceDiggButton *likeButton = self.arrangedSubviews[VEShortFunctionTypeLike];
    likeButton.liked = _videoModel.selfLiked;
    _videoModel.selfLiked = !_videoModel.isSelfLiked;
    if (_videoModel.selfLiked) {
        _videoModel.likeCount += 1;
    } else {
        _videoModel.likeCount -= 1;
    }
    [likeButton play];
    likeButton.title = [NSString stringForCount:_videoModel.likeCount];
    [self.eventMessageBus postEvent:VEUIEventResetAutoHideController withObject:nil rightNow:YES];
}

- (void)showCommentAction {
    VEInterfaceCommentView *commentView = [[VEInterfaceCommentView alloc] initWithFrame:[UIScreen mainScreen].bounds axis:self.axis];
    commentView.eventMessageBus = self.eventMessageBus;
    commentView.eventPoster = self.eventPoster;
    commentView.videoModel = self.videoModel;
    [commentView showInView:[DeviceInforTool topViewController].view];
}

#pragma mark - VEInterfaceCustomView
- (void)elementViewAction {
}

- (void)elementViewEventNotify:(id)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)obj;
        NSString *key = [[paramDic allKeys] firstObject];
        if (key && ([key isEqualToString:VEUIEventScreenClearStateChanged] || [key isEqualToString:VEUIEventScreenLockStateChanged] || [key isEqualToString:VEUIEventScreenOrientationChanged])) {
            if (normalScreenBehaivor()) {
                self.hidden = YES;
            } else {
                BOOL screenIsClear = [self.eventPoster screenIsClear];
                BOOL screenIsLocking = [self.eventPoster screenIsLocking];
                self.hidden = screenIsLocking ?: screenIsClear;
            }
        }
    }
}

- (BOOL)isEnableZone:(CGPoint)point {
    if (self.hidden) {
        return NO;
    }
    if (CGRectContainsPoint(self.frame, point)) {
        return YES;
    }
    return NO;
}

@end
