// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "UIView+VELDraggable.h"
#import "VELWeakContainer.h"
#import <objc/runtime.h>

static const NSInteger kVELDraggableAdsorbingTag = 10000;
static const CGFloat kVELDraggableAdsorbScope    = 2.f;
static const CGFloat kVELDraggableAdsorbDuration = 0.5f;

@implementation UIView (VELDraggable)

#pragma mark - synthesize

- (UIPanGestureRecognizer *)vel_panGesture {
    return objc_getAssociatedObject(self, @selector(vel_panGesture));
}

- (void)setVel_panGesture:(UIPanGestureRecognizer *)panGesture {
    objc_setAssociatedObject(self, @selector(vel_panGesture), panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<VELDraggingDelegate>)vel_delegate {
    return ((VELWeakContainer *)objc_getAssociatedObject(self, @selector(vel_delegate))).object;
}

- (void)setVel_delegate:(id<VELDraggingDelegate>)delegate {
    objc_setAssociatedObject(self, @selector(vel_delegate), [VELWeakContainer containerWithObject:delegate], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (VELDraggingMode)vel_draggingMode {
    return [objc_getAssociatedObject(self, @selector(vel_draggingMode)) integerValue];
}

- (void)setVel_draggingMode:(VELDraggingMode)draggingMode {
    if ([self vel_draggingMode] == VELDraggingModeAdsorb) {
        [self vel_bringViewBack];
    }
    objc_setAssociatedObject(self, @selector(vel_draggingMode), [NSNumber numberWithInteger:draggingMode], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self vel_makeDraggable:!(draggingMode == VELDraggingModeDisabled)];
}

- (BOOL)vel_draggingInBounds {
    NSNumber *draggingInBounds = objc_getAssociatedObject(self, @selector(vel_draggingInBounds));
    if (!draggingInBounds) {
        self.vel_draggingInBounds = YES;
    }
    return [draggingInBounds boolValue];
}

- (void)setVel_draggingInBounds:(BOOL)draggingInBounds {
    objc_setAssociatedObject(self, @selector(vel_draggingInBounds), [NSNumber numberWithBool:draggingInBounds], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGPoint)vel_revertPoint {
    NSString* pointString = objc_getAssociatedObject(self, @selector(vel_revertPoint));
    CGPoint point = CGPointFromString(pointString);
    return point;
}

- (void)setVel_revertPoint:(CGPoint)revertPoint {
    NSString* point = NSStringFromCGPoint(revertPoint);
    objc_setAssociatedObject(self, @selector(vel_revertPoint), point, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIEdgeInsets)vel_edgeInsets {
    NSValue *edgeInsets = objc_getAssociatedObject(self, @selector(vel_edgeInsets));
    if (!edgeInsets) {
        self.vel_edgeInsets = UIEdgeInsetsZero;
    }
    return edgeInsets.UIEdgeInsetsValue;
}

- (void)setVel_edgeInsets:(UIEdgeInsets)vel_edgeInsets {
    objc_setAssociatedObject(self, @selector(vel_edgeInsets), @(vel_edgeInsets), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Draggable

- (void)vel_makeDraggable:(BOOL)draggable {
    self.userInteractionEnabled = YES;
    for (NSLayoutConstraint* constraint in self.superview.constraints) {
        if ([constraint.firstItem isEqual:self] || [constraint.secondItem isEqual:self]) {
            [self.superview removeConstraint:constraint];
        }
    }
    self.translatesAutoresizingMaskIntoConstraints = YES;
    UIPanGestureRecognizer* panGesture = [self vel_panGesture];
    if (draggable) {
        if (nil == panGesture) {
            panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(vel_onPanGestureRecognizer:)];
            panGesture.delegate = self;
            [self addGestureRecognizer:panGesture];
            [self setVel_panGesture:panGesture];
        }
    } else {
        if (panGesture != nil) {
            [self removeGestureRecognizer:panGesture];
            [self setVel_panGesture:nil];
        }
    }
}

- (void)vel_onPanGestureRecognizer:(UIPanGestureRecognizer *)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan :
            {
                [self vel_bringViewBack];
                [self setVel_revertPoint:self.center];
                [self vel_dragging:sender];
                if ([self.vel_delegate respondsToSelector:@selector(draggingDidBegan:)]) {
                    [self.vel_delegate draggingDidBegan:self];
                }
            }
            break;
        case UIGestureRecognizerStateChanged :
            {
                [self vel_dragging:sender];
                if ([self.vel_delegate respondsToSelector:@selector(draggingDidChanged:)]) {
                    [self.vel_delegate draggingDidChanged:self];
                }
            }
            break;
        case UIGestureRecognizerStateEnded :
            {
                switch ([self vel_draggingMode]) {
                    case VELDraggingModeRevert :
                        [self vel_revertAnimated:YES];
                        break;
                    case VELDraggingModePullOver :
                        [self vel_pullOverAnimated:YES];
                        break;
                    case VELDraggingModeAdsorb :
                        [self vel_adsorb];
                        break;
                    default:
                        break;
                }
                if ([self.vel_delegate respondsToSelector:@selector(draggingDidEnded:)]) {
                    [self.vel_delegate draggingDidEnded:self];
                }
            }
            break;
        default:
            break;
    }
}

- (void)vel_dragging:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView* view = panGestureRecognizer.view;
    CGPoint translation = [panGestureRecognizer translationInView:view.superview];
    CGPoint center = CGPointMake(view.center.x + translation.x, view.center.y + translation.y);
    if ([self vel_draggingInBounds]) {
        CGSize size = view.frame.size;
        CGSize superSize = view.superview.frame.size;
        CGFloat width = size.width;
        CGFloat height = size.height;
        CGFloat superWidth = superSize.width;
        CGFloat superHeight = superSize.height;
        UIEdgeInsets insets = self.vel_edgeInsets;
        center.x = (center.x < width/2 + insets.left) ? width/2 + insets.left : center.x;
        center.x = (center.x > superWidth - width/2 - insets.right) ? superWidth - width/2 - insets.right : center.x;
        center.y = (center.y < height/2 + insets.top) ? height/2 + insets.top : center.y;
        center.y = (center.y > superHeight - height/2 - insets.bottom) ? superHeight - height/2 - insets.bottom : center.y;
    }
    [view setCenter:center];
    [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
}

#pragma mark - pull over

- (CGPoint)vel_centerByPullOver {
    CGPoint center = [self center];
    CGSize size = self.frame.size;
    CGSize superSize = [self superview].frame.size;
    UIEdgeInsets insets = self.vel_edgeInsets;
    if (center.x < superSize.width / 2) {
        center.x = size.width / 2 + insets.left;
    } else {
        center.x = superSize.width - size.width / 2 - insets.right;
    }
    if (center.y < size.height / 2 + insets.top) {
        center.y = size.height / 2 + insets.top;
    } else if (center.y > superSize.height - size.height / 2 - insets.bottom) {
        center.y = superSize.height - size.height / 2 - insets.bottom;
    }
    return center;
}

- (void)vel_pullOverAnimated:(BOOL)animated {
    [self vel_bringViewBack];
    CGPoint center = [self vel_centerByPullOver];
    [UIView animateWithDuration:animated ? kVELDraggableAdsorbDuration : 0 animations: ^{
        [self setCenter:center];
    } completion:nil];
}

#pragma mark - revert

- (void)vel_revertAnimated:(BOOL)animated {
    [self vel_bringViewBack];
    CGPoint center = [self vel_revertPoint];
    [UIView animateWithDuration:animated ? kVELDraggableAdsorbDuration : 0 animations: ^{
        [self setCenter:center];
    } completion:nil];
}

#pragma mark - adsorb

- (void)vel_adsorbingAnimated:(BOOL)animated {
    if (self.superview.tag == kVELDraggableAdsorbingTag) {
        return;
    }
    CGPoint center = [self vel_centerByPullOver];
    [UIView animateWithDuration:animated ? kVELDraggableAdsorbDuration : 0 animations: ^{
        [self setCenter:center];
    } completion: ^(BOOL finish){
        [self vel_adsorbAnimated:animated];
    }];
}

- (void)vel_adsorb {
    if (self.superview.tag == kVELDraggableAdsorbingTag) {
        return;
    }
    CGPoint origin = self.frame.origin;
    CGSize size = self.frame.size;
    CGSize superSize = self.superview.frame.size;
    BOOL adsorbing = NO;
    if (origin.x < kVELDraggableAdsorbScope) {
        origin.x = 0;
        adsorbing = YES;
    } else if (origin.x > superSize.width - size.width - kVELDraggableAdsorbScope) {
        origin.x = superSize.width - size.width;
        adsorbing = YES;
    }
    if (origin.y < kVELDraggableAdsorbScope) {
        origin.y = 0;
        adsorbing = YES;
    } else if (origin.y > superSize.height - size.height - kVELDraggableAdsorbScope) {
        origin.y = superSize.height - size.height;
        adsorbing = YES;
    }
    if (adsorbing) {
        [self setFrame:CGRectMake(origin.x, origin.y, size.width, size.height)];
        [self vel_adsorbAnimated:YES];
    }
}

- (void)vel_adsorbAnimated:(BOOL)animated {
    CGRect frame = self.frame;
    UIView* adsorbingView = [[UIView alloc] initWithFrame:frame];
    adsorbingView.tag = kVELDraggableAdsorbingTag;
    [adsorbingView setBackgroundColor:[UIColor clearColor]];
    adsorbingView.clipsToBounds = YES;
    [self.superview addSubview:adsorbingView];
    
    CGSize superSize = adsorbingView.superview.frame.size;
    CGPoint center = CGPointZero;
    CGRect newFrame = frame;
    if (frame.origin.x==0) {
        center.x = 0;
        newFrame.size.width = frame.size.width/2;
    } else if (frame.origin.x == superSize.width - frame.size.width) {
        newFrame.size.width = frame.size.width/2;
        newFrame.origin.x = frame.origin.x + frame.size.width / 2;
        center.x = newFrame.size.width;
    } else {
        center.x = frame.size.width / 2;
    }
    if (frame.origin.y == 0) {
        center.y = 0;
        newFrame.size.height = frame.size.height / 2;
    } else if (frame.origin.y == superSize.height - frame.size.height) {
        newFrame.size.height = frame.size.height / 2;
        newFrame.origin.y = frame.origin.y + frame.size.height / 2;
        center.y = newFrame.size.height;
    } else {
        center.y = frame.size.height / 2;
    }
    [self vel_sendToView:adsorbingView];
    [UIView animateWithDuration:animated ? kVELDraggableAdsorbDuration : 0 animations: ^{
        [adsorbingView setFrame:newFrame];
        [self setCenter:center];
    } completion:nil];
}

- (void)vel_sendToView:(UIView *)view {
    CGRect convertRect = [self.superview convertRect:self.frame toView:view];
    [view addSubview:self];
    [self setFrame:convertRect];
}

- (void)vel_bringViewBack {
    UIView* adsorbingView = self.superview;
    if (adsorbingView.tag == kVELDraggableAdsorbingTag) {
        [self vel_sendToView:adsorbingView.superview];
        [adsorbingView removeFromSuperview];
    }
}

@end

