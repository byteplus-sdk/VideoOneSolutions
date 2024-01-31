// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "ToastView.h"
#import "Masonry.h"
#import "UIImage+Bundle.h"

@interface ToastView ()

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *loadingMessage;
@property (nonatomic, copy) NSString *describe;
@property (nonatomic, assign) ToastViewStatus status;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

@end

@implementation ToastView

- (instancetype)initWithMessage:(NSString *)message {
    self = [super init];
    if (self) {
        self.loadingMessage = message;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.bgView = [[UIView alloc] init];
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.8;
        self.bgView.layer.cornerRadius = 4;
        self.bgView.layer.masksToBounds = YES;
        [self addSubview:self.bgView];

        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)setContentType:(ToastViewContentType)contentType {
    if (_contentType == contentType) {
        return;
    }
    _contentType = contentType;
    while (self.bgView.subviews.count) {
        [self.bgView.subviews.lastObject removeFromSuperview];
    }
    switch (contentType) {
        case ToastViewContentTypeMeesage:
            [self configMeesageContent];
            break;
        case ToastViewContentTypeActivityIndicator:
            [self configActivityIndicatorContent];
            break;
        default:
            break;
    }
}

- (void)updateMessage:(NSString *)message
             describe:(NSString *)describe
               stauts:(ToastViewStatus)status {
    self.message = message;
    self.describe = describe;
    self.status = status;
    if (self.contentType != ToastViewContentTypeMeesage) {
        self.contentType = ToastViewContentTypeMeesage;
    }
}

- (void)startLoading {
    if (self.contentType != ToastViewContentTypeActivityIndicator) {
        self.contentType = ToastViewContentTypeActivityIndicator;
    }
    [self.activityIndicatorView startAnimating];
}

- (void)stopLoaidng {
    [self.activityIndicatorView stopAnimating];
}

- (void)configMeesageContent {
    CGFloat minScreen = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat scale = (minScreen / 375);

    UIImageView *statusImageView = [[UIImageView alloc] init];
    statusImageView.backgroundColor = [UIColor clearColor];
    UIImage *image = nil;
    switch (self.status) {
        case ToastViewStatusSucceed:
            image = [UIImage imageNamed:@"toast_succeed"
                             bundleName:ToolKitBundleName];
            break;
        case ToastViewStatusWarning:
            image = [UIImage imageNamed:@"toast_warning"
                             bundleName:ToolKitBundleName];
            break;
        case ToastViewStatusFailed:
            image = [UIImage imageNamed:@"toast_failed" bundleName:ToolKitBundleName];
            break;
        default:
            image = nil;
            break;
    }
    statusImageView.image = image;
    [self.bgView addSubview:statusImageView];
    [statusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (statusImageView.image) {
            make.size.mas_equalTo(CGSizeMake(28, 28));
        } else {
            make.size.mas_equalTo(CGSizeMake(0, 0));
        }
        make.top.equalTo(self.bgView).offset(14);
        make.centerX.equalTo(self.bgView);
    }];

    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.message;
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:14 * scale weight:UIFontWeightRegular];
    [self.bgView addSubview:titleLabel];
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(statusImageView.mas_bottom).offset(statusImageView.image ? 12 : 0);
        make.centerX.equalTo(self.bgView);
        make.width.mas_lessThanOrEqualTo(minScreen - 36 * 2);
    }];

    UILabel *describeLabel = [[UILabel alloc] init];
    describeLabel.text = self.describe;
    describeLabel.numberOfLines = 0;
    describeLabel.textColor = [UIColor colorWithRed:0.8 green:0.81 blue:0.82 alpha:1];
    describeLabel.textAlignment = NSTextAlignmentCenter;
    describeLabel.font = [UIFont systemFontOfSize:14 * scale weight:UIFontWeightRegular];
    [self.bgView addSubview:describeLabel];
    [describeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if (describeLabel.text.length > 0) {
            make.top.equalTo(titleLabel.mas_bottom).offset(12);
        } else {
            make.top.equalTo(titleLabel.mas_bottom).offset(0);
        }
        make.centerX.equalTo(self.bgView);
        make.width.mas_lessThanOrEqualTo(minScreen - 24 * 2);
        make.bottom.equalTo(self.bgView).offset(-14);
    }];

    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.lessThanOrEqualTo(titleLabel).offset(-16);
        make.left.lessThanOrEqualTo(describeLabel).offset(-16);
        make.right.greaterThanOrEqualTo(titleLabel).offset(16);
        make.right.greaterThanOrEqualTo(describeLabel).offset(16);
    }];
}

- (void)configActivityIndicatorContent {
    CGFloat minScreen = MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    CGFloat scale = (minScreen / 375);
    
    // Loaing
    UIActivityIndicatorView *activityIndicatorView = nil;
    if (@available(iOS 13.0, *)) {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
        activityIndicatorView.color = [UIColor whiteColor];
    } else {
        activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
    [self.bgView addSubview:activityIndicatorView];
    self.activityIndicatorView = activityIndicatorView;
    [activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.bgView).offset(20);
        make.centerX.equalTo(self.bgView);
    }];
    
    // Message
    UILabel *titleLabel = nil;
    if (self.loadingMessage.length > 0) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.text = self.loadingMessage;
        titleLabel.numberOfLines = 0;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont systemFontOfSize:14 * scale weight:UIFontWeightRegular];
        [self.bgView addSubview:titleLabel];
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(activityIndicatorView.mas_bottom).offset(4);
            make.centerX.equalTo(activityIndicatorView);
            make.width.mas_lessThanOrEqualTo(minScreen - 32 * 4);
            make.bottom.equalTo(self.bgView).offset(-20);
        }];
    } else {
        [activityIndicatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.bgView).offset(-20);
        }];
    }

    [self.bgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.lessThanOrEqualTo(activityIndicatorView).offset(-32);
        make.right.greaterThanOrEqualTo(activityIndicatorView).offset(32);
        if (titleLabel) {
            make.left.lessThanOrEqualTo(titleLabel).offset(-32);
            make.right.greaterThanOrEqualTo(titleLabel).offset(32);
        }
    }];
}

@end
