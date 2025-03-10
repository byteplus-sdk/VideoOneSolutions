// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MiniDramaSocialView.h"
#import "VEInterfaceDiggButton.h"
#import "VEInterfaceSocialButton.h"
#import <ToolKit/ToolKit.h>
#import <ToolKit/DeviceInforTool.h>
#import <ToolKit/UIImage+Bundle.h>
#import "VEInterfaceCommentView.h"
#import "MiniDramaCommentView.h"
#import "MDEventConst.h"
#import "MDInterface.h"

typedef NS_ENUM(NSUInteger, MDFunctionType) {
    MDFunctionTypeLike,
    MDFunctionTypeComment,
};

@interface MiniDramaSocialView ()

@end

@implementation MiniDramaSocialView


- (instancetype)init {
    self = [super init];
    if (self) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(socialViewTap:)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
        [self registerEvent];
    }
    return self;
}

- (void)setAxis:(UILayoutConstraintAxis)axis {
    [super setAxis:axis];
    if (axis == UILayoutConstraintAxisVertical) {
        self.spacing = 16.0;
    } else {
        self.spacing = 24.0;
    }
}


- (void)setVideoModel:(MiniDramaBaseVideoModel *)videoModel {
    _videoModel = videoModel;
    [self clear];

    VEInterfaceDiggButton *likeButton = [[VEInterfaceDiggButton alloc] initWithFrame:CGRectZero axis:self.axis];
    likeButton.tag = [self getTag:MDFunctionTypeLike];
    [self addArrangedSubview:likeButton];

    VEInterfaceSocialButton *commentButton = [[VEInterfaceSocialButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50) axis:self.axis];
    commentButton.tag = [self getTag:MDFunctionTypeComment];
    [self addArrangedSubview:commentButton];
    [self reloadData];
}

- (void)clear {
    NSArray<__kindof UIView *> *arrangedSubviews = self.arrangedSubviews;
    [arrangedSubviews enumerateObjectsUsingBlock:^(__kindof UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        [self removeArrangedSubview:obj];
        [obj removeFromSuperview];
    }];
}

- (void)registerEvent {
    
}

- (void)reloadData {
    if (!self.arrangedSubviews.count) {
        return;
    }
    VEInterfaceDiggButton *likeButton = self.arrangedSubviews[MDFunctionTypeLike];
    likeButton.liked = _videoModel.isSelfLiked;
    likeButton.title = [NSString stringForCount:self.videoModel.likeCount];

    VEInterfaceSocialButton *commentButton = self.arrangedSubviews[MDFunctionTypeComment];
    commentButton.image = [UIImage imageNamed:(self.axis == UILayoutConstraintAxisVertical) ? @"vod_feed_comment" : @"vod_feed_comment_deformity" bundleName:@"VodPlayer"];
    commentButton.title = [NSString stringForCount:self.videoModel.commentCount];
}

- (void)loveVideoAction {
    VEInterfaceDiggButton *likeButton = self.arrangedSubviews[MDFunctionTypeLike];
    likeButton.liked = _videoModel.selfLiked;
    _videoModel.selfLiked = !_videoModel.isSelfLiked;
    if (_videoModel.selfLiked) {
        _videoModel.likeCount += 1;
    } else {
        _videoModel.likeCount -= 1;
    }
    [likeButton play];
    likeButton.title = [NSString stringForCount:self.videoModel.likeCount];
}

- (void)handleDoubleClick:(CGPoint)location {
    [VEInterfaceDiggButton playDiggAnimationInView:self.superview location:location];
    if (_videoModel.selfLiked) {
        return;
    }
    [self loveVideoAction];
}

- (void)handleDoubleClick:(CGPoint)location inView:(nonnull __kindof UIView *)view {
    [VEInterfaceDiggButton playDiggAnimationInView:view location:location];
    if (_videoModel.selfLiked) {
        return;
    }
    [self loveVideoAction];
}

- (void)showCommentAction {
    MiniDramaCommentView *commentView = [[MiniDramaCommentView alloc] initWithFrame:[UIScreen mainScreen].bounds axis:self.axis];
    commentView.videoModel = self.videoModel;
    [commentView showInView:[DeviceInforTool topViewController].view];
}

- (NSInteger )getTag:(MDFunctionType)type {
    NSInteger value = -1;
    switch (type) {
        case MDFunctionTypeLike:
            value =  10001;
            break;
        case MDFunctionTypeComment:
            value =  10002;
            break;
        default:
            break;
    }
    return value;
}

- (void) socialViewTap:(UIGestureRecognizer*)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self];
    UIView *tappedView = [self hitTest:location withEvent:nil];
    if (tappedView.tag == [self getTag:MDFunctionTypeLike]) {
        [self loveVideoAction];
    } else if (tappedView.tag == [self getTag:MDFunctionTypeComment]) {
        [self showCommentAction];
    } else {
        return;
    }
}

#pragma mark - VEInterfaceCustomView

- (void)elementViewAction {
    
}

- (void)elementViewEventNotify:(id)obj {
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *paramDic = (NSDictionary *)obj;
        NSString *key = [[paramDic allKeys] firstObject];
        if (key && ([key isEqualToString:MDUIEventScreenClearStateChanged] || [key isEqualToString:MDUIEventScreenLockStateChanged] || [key isEqualToString:MDUIEventScreenOrientationChanged])) {
            if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
                self.hidden = YES;
            } else {
                BOOL screenIsClear = [[MDEventPoster currentPoster] screenIsClear];
                BOOL screenIsLocking = [[MDEventPoster currentPoster] screenIsLocking];
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
