//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "VEInterfaceCommentView.h"
#import "NetworkingManager+Vod.h"
#import "VECommentModel.h"
#import "VEEventConst.h"
#import "VEInterfaceCommentCell.h"
#import "VEInterfaceCommentViewDescription.h"
#import "VEVideoModel.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ReportComponent.h>
#import <ToolKit/TextInputView.h>
#import <ToolKit/ToolKit.h>

@interface VEInterfaceCommentView () <UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, copy, nullable) NSArray<VECommentModel *> *commentModels;

@property (nonatomic, strong) VEInterfaceCommentViewDescription *viewDesc;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TextInputView *textInputView;

@end

@implementation VEInterfaceCommentView

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame axis:UILayoutConstraintAxisHorizontal];
}

- (instancetype)initWithFrame:(CGRect)frame axis:(UILayoutConstraintAxis)axis {
    self = [super initWithFrame:frame];
    if (self) {
        self.viewDesc = [VEInterfaceCommentViewDescription descriptionWithAxis:axis];
        [self createChildView];
        [self layoutIfNeeded];
    }
    return self;
}

- (void)dealloc {
    [self removeNotification];
}

#pragma mark - Publish Method

- (void)showInView:(UIView *)superview {
    [superview addSubview:self];
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superview);
    }];
    [self registerNotification];
    [self reloadData];
    [UIView animateWithDuration:self.viewDesc.animationDuration animations:^{
        if (self.axis == UILayoutConstraintAxisVertical) {
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self);
            }];
        } else {
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self).offset(-MAX(8, [DeviceInforTool getSafeAreaInsets].right));
            }];
        }
        [self layoutIfNeeded];
    } completion:nil];
    [self loadDataIfNeed];
    [self changeScreenClearState:YES];
}

- (void)close {
    [self.textInputView dismiss:nil];
    [self changeScreenClearState:NO];
    [UIView animateWithDuration:self.viewDesc.animationDuration animations:^{
        if (self.axis == UILayoutConstraintAxisVertical) {
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self).offset(self.viewDesc.contentSize.height);
            }];
        } else {
            [self.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.trailing.equalTo(self).offset(self.viewDesc.contentSize.width);
            }];
        }
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self removeNotification];
    }];
}

- (void)reloadData {
    [self updateTitle];
    [self.tableView reloadData];
}

#pragma mark - Private Method

- (UILayoutConstraintAxis)axis {
    return self.viewDesc.axis;
}

- (void)showCommentTip {
    AlertActionModel *actionModel = [[AlertActionModel alloc] init];
    actionModel.title = LocalizedStringFromBundle(@"tip_close", @"VEVodApp");
    [[AlertActionManager shareAlertActionManager] showWithTitle:LocalizedStringFromBundle(@"tip_title", @"VEVodApp")
                                                        message:LocalizedStringFromBundle(@"tip_comment_content", @"VEVodApp")
                                                        actions:@[actionModel]
                                                      hideDelay:0];
}

#pragma mark - Data

- (void)loadDataIfNeed {
    if (!!self.commentModels.count || !self.videoModel.videoId) {
        return;
    }

    __weak __typeof(self) wself = self;
    [NetworkingManager getVideoCommentsForVid:self.videoModel.videoId
                                   completion:^(NSArray<VECommentModel *> *_Nonnull commentModels, NetworkingResponse *_Nonnull response) {
                                       if (commentModels.count) {
                                           wself.commentModels = commentModels;
                                           [wself reloadData];
                                       }
                                   }];
}

- (void)sendComment:(NSString *)text {
    BaseUserModel *userModel = [LocalUserComponent userModel];
    VECommentModel *comment = [VECommentModel new];
    comment.uid = userModel.uid;
    comment.name = userModel.name;
    comment.content = text;
    comment.createTime = [NSString timeStringSinceNow];
    NSMutableArray *commentModels = [[NSMutableArray alloc] initWithArray:self.commentModels];
    [commentModels insertObject:comment atIndex:0];
    self.commentModels = commentModels.copy;
    [self reloadData];
}

- (void)updateTitle {
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@", [NSString stringForCount:self.commentModels.count], LocalizedStringFromBundle(@"comments", @"VEVodApp")];
}

- (void)deleteComment:(VECommentModel *)comment {
    AlertActionModel *alertCancelModel = [[AlertActionModel alloc] init];
    alertCancelModel.title = LocalizedStringFromBundle(@"cancel", ToolKitBundleName);
    AlertActionModel *alertModel = [[AlertActionModel alloc] init];
    alertModel.title = LocalizedStringFromBundle(@"confirm", ToolKitBundleName);
    __weak typeof(self) weakSelf = self;
    alertModel.alertModelClickBlock = ^(UIAlertAction *_Nonnull action) {
        if (![weakSelf.commentModels containsObject:comment]) {
            return;
        }
        NSMutableArray *commentModels = [[NSMutableArray alloc] initWithArray:weakSelf.commentModels];
        [commentModels removeObject:comment];
        weakSelf.commentModels = commentModels.copy;
        [weakSelf reloadData];
    };
    [[AlertActionManager shareAlertActionManager] showWithTitle:LocalizedStringFromBundle(@"delete_comment_title", @"VEVodApp")
                                                        message:LocalizedStringFromBundle(@"delete_comment_content", @"VEVodApp")
                                                        actions:@[alertCancelModel, alertModel]
                                                      hideDelay:0];
}

- (void)longPressComment:(VECommentModel *)comment {
    if ([comment.uid isEqualToString:[LocalUserComponent userModel].uid]) {
        return;
    }
    [ReportComponent report:comment.uid cancelHandler:nil completion:nil];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.commentModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VEInterfaceCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:self.viewDesc.cellReuseIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.commentModels.count) {
        cell.comment = self.commentModels[indexPath.row];
    }
    __weak __typeof(self) wself = self;
    cell.deleteComment = ^(VECommentModel *_Nonnull comment) {
        [wself deleteComment:comment];
    };
    cell.longPressComment = ^(VECommentModel *_Nonnull comment) {
        [wself longPressComment:comment];
    };
    return cell;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    return !CGRectContainsPoint(self.contentView.frame, point);
}

#pragma mark - Layout

- (void)changeScreenClearState:(BOOL)isClear {
    if (self.eventPoster) {
        [self.eventPoster setScreenIsClear:isClear];
    }
}

- (void)registerNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    if (!_textInputView) {
        return;
    }
    CGRect keyboardRect = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets safeAreaInsets = [DeviceInforTool getSafeAreaInsets];
    self.textInputView.contentInsets = UIEdgeInsetsMake(8, 12 + safeAreaInsets.left, 8, 12 + safeAreaInsets.right);
    self.textInputView.backgroundColor = self.viewDesc.inputActiveBgColor;
    [self.textInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.bottom.equalTo(self).offset(-keyboardRect.size.height);
        make.height.mas_equalTo(self.viewDesc.inputHeight);
    }];
    [self.textInputView.superview layoutIfNeeded];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    if (!_textInputView) {
        return;
    }
    self.textInputView.contentInsets = UIEdgeInsetsMake(8, 12, 8, 12);
    self.textInputView.backgroundColor = self.viewDesc.inputBgColor;
    [self.textInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.tableView).offset(self.viewDesc.inputHeight);
        make.height.mas_equalTo(self.viewDesc.inputHeight);
    }];
    [self.textInputView.superview layoutIfNeeded];
}

- (void)resignFirstResponderAction:(UITapGestureRecognizer *)tap {
    [self.textInputView dismiss:nil];
}

- (void)createChildView {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)];
    tap.delegate = self;
    [self addGestureRecognizer:tap];
    [self createContentVeiw];
    [self createHeaderView];
    [self createTableView];
    [self createTextInputView];
}

- (void)createContentVeiw {
    UIView *contentView = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, self.viewDesc.contentSize}];
    contentView.backgroundColor = self.viewDesc.bgColor;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:contentView.bounds
                                                   byRoundingCorners:self.viewDesc.bgRoundingCorners
                                                         cornerRadii:self.viewDesc.bgCornerRadii];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = contentView.bounds;
    maskLayer.path = maskPath.CGPath;
    contentView.layer.mask = maskLayer;
    [self addSubview:contentView];
    if (self.axis == UILayoutConstraintAxisVertical) {
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(self);
            make.bottom.equalTo(self).offset(self.viewDesc.contentSize.height);
            make.height.mas_equalTo(self.viewDesc.contentSize);
        }];
    } else {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
        [contentView addSubview:blurView];
        [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(contentView);
        }];
        [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(8);
            make.bottom.equalTo(self).offset(-8);
            make.width.mas_equalTo(self.viewDesc.contentSize);
            make.trailing.equalTo(self).offset(self.viewDesc.contentSize.width);
        }];
    }
    self.contentView = contentView;
}

- (void)createHeaderView {
    UIButton *tipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [tipButton setImage:[UIImage imageNamed:@"vod_tip_question_mark"] forState:UIControlStateNormal];
    [tipButton addTarget:self action:@selector(showCommentTip) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:tipButton];

    if (self.axis == UILayoutConstraintAxisVertical) {
        [tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(48);
            make.height.mas_equalTo(self.viewDesc.headerHeight);
            make.leading.top.equalTo(self.contentView);
        }];

        UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeButton setImage:[UIImage imageNamed:@"vod_bar_close"] forState:UIControlStateNormal];
        [closeButton addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:closeButton];
        [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(48);
            make.height.mas_equalTo(self.viewDesc.headerHeight);
            make.trailing.top.equalTo(self.contentView);
        }];
    } else {
        [tipButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(48);
            make.height.mas_equalTo(self.viewDesc.headerHeight);
            make.trailing.top.equalTo(self.contentView);
        }];
    }

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = self.viewDesc.titleColor;
    titleLabel.textAlignment = self.viewDesc.titleTextAlignment;
    titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    [self.contentView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.viewDesc.headerHeight);
        make.top.centerX.equalTo(self.contentView);
        make.leading.equalTo(self.contentView).offset(16);
    }];
    self.titleLabel = titleLabel;

    UIView *line = [[UIView alloc] init];
    line.backgroundColor = self.viewDesc.topSeparatorColor;
    [self.contentView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
        make.bottom.equalTo(titleLabel.mas_bottom);
        make.leading.trailing.equalTo(self.contentView);
    }];
}

- (void)createTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectZero
                                                          style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.rowHeight = UITableViewAutomaticDimension;
    tableView.estimatedRowHeight = 75;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsHorizontalScrollIndicator = NO;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [tableView registerClass:VEInterfaceCommentCell.class forCellReuseIdentifier:self.viewDesc.cellReuseIdentifier];
    [self.contentView insertSubview:tableView belowSubview:self.titleLabel];
    [tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.leading.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView.mas_safeAreaLayoutGuideBottom).offset(-self.viewDesc.inputHeight);
    }];
    self.tableView = tableView;
}

- (void)createTextInputView {
    UIView *maskView = [[UIView alloc] initWithFrame:self.bounds];
    maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    maskView.hidden = YES;
    maskView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignFirstResponderAction:)];
    [maskView addGestureRecognizer:tap];
    [self addSubview:maskView];
    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];

    TextInputView *textInputView = [[TextInputView alloc] initWithFrame:CGRectMake(0, 0, self.viewDesc.contentSize.width, self.viewDesc.inputHeight)];
    textInputView.backgroundColor = self.viewDesc.inputBgColor;
    textInputView.borderColor = self.viewDesc.inputBorderColor;
    textInputView.textField.tintColor = self.viewDesc.inputTextColor;
    textInputView.textField.textColor = self.viewDesc.inputTextColor;
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:LocalizedStringFromBundle(@"placeholder_message", ToolKitBundleName)
                                                                     attributes:@{NSForegroundColorAttributeName: self.viewDesc.inputPlaceholderColorColor}];
    textInputView.textField.attributedPlaceholder = attrString;
    __weak __typeof(self) wself = self;
    textInputView.didBeginEditing = ^{
        maskView.hidden = NO;
    };
    textInputView.didEndEditing = ^{
        maskView.hidden = YES;
    };
    textInputView.clickSenderBlock = ^(NSString *_Nonnull text) {
        wself.textInputView.textField.text = @"";
        [wself.textInputView dismiss:nil];
        [wself sendComment:text];
    };
    [self addSubview:textInputView];
    [textInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.contentView);
        make.bottom.equalTo(self.tableView).offset(self.viewDesc.inputHeight);
        make.height.mas_equalTo(self.viewDesc.inputHeight);
    }];
    _textInputView = textInputView;

    UIView *line = [[UIView alloc] initWithFrame:CGRectZero];
    line.backgroundColor = self.viewDesc.inputSeparatorColor;
    [textInputView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(1 / [UIScreen mainScreen].scale);
        make.leading.trailing.top.equalTo(textInputView);
    }];
}

@end
