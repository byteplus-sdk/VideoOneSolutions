//
//  DramaDisrecordManager.m
//  AFNetworking
//
//  Created by ByteDance on 2024/12/18.
//

#import "DramaDisrecordManager.h"
#import "DeviceInforTool.h"
#import <Masonry/Masonry.h>
#import <ToolKit/Localizator.h>
#import <ToolKit/UIImage+Bundle.h>
#import "UIColor+RGB.h"

static BOOL OpenDisrecord = NO;

@interface DramaDisrecordManager ()

@property (nonatomic, strong) UIView *disRecordScreenView;

@end

@implementation DramaDisrecordManager

static id sharedInstance = nil;
+ (instancetype)sharedInstance {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

+ (void)destroyUnit {
    @autoreleasepool {
        [sharedInstance hideDisRecordView];
        sharedInstance = nil;
    }
}

- (void)setupDisRecordView {
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.cornerRadius = 16;
    containerView.layer.masksToBounds = YES;
    
    [self.disRecordScreenView addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.disRecordScreenView);
        make.size.mas_equalTo(CGSizeMake(280, 200));
    }];
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dis_record_screen" bundleName:@"MiniDrama"]];
    
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textColor = [UIColor colorWithRGB:0x161823 alpha:1];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.text = LocalizedStringFromBundle(@"mini_drama_disrecord_title", @"MiniDrama");
    
    UILabel *subTitleLabel = [[UILabel alloc] init];
    subTitleLabel.numberOfLines = 2;
    subTitleLabel.textAlignment = NSTextAlignmentCenter;
    subTitleLabel.textColor = [UIColor colorWithRGB:0x161823 alpha:.75];
    subTitleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.lineSpacing = 3;
    NSDictionary *contentAttr = @{ NSFontAttributeName            : [UIFont systemFontOfSize:14],
                                   NSForegroundColorAttributeName : [UIColor colorWithRGB:0x161823 alpha:.75],
                                   NSParagraphStyleAttributeName  : style};
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:LocalizedStringFromBundle(@"mini_drama_disrecord_des", @"MiniDrama") attributes:contentAttr];
    subTitleLabel.attributedText = attString;
    
    [containerView addSubview:iconImageView];
    [containerView addSubview:titleLabel];
    [containerView addSubview:subTitleLabel];
    
    [iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containerView);
        make.top.equalTo(containerView).with.offset(25);
    }];
    

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containerView);
        make.top.equalTo(iconImageView.mas_bottom).with.offset(30);
    }];

    [subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(containerView);
        make.top.equalTo(titleLabel.mas_bottom).with.offset(10);
        make.left.equalTo(containerView).with.offset(20);
        make.right.equalTo(containerView).with.offset(-20);
    }];
}

- (void)showDisRecordView {
    if (![DramaDisrecordManager isOpenDisrecord]) {
        return;
    }
    if (!self.disRecordScreenView) {
        self.disRecordScreenView = [[UIView alloc] init];
        self.disRecordScreenView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.2f];
        [self setupDisRecordView];
        
        UIView *parentView = [DeviceInforTool topViewController].view;
        [parentView addSubview:self.disRecordScreenView];
        [self.disRecordScreenView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(parentView);
        }];
    }
}

- (void)hideDisRecordView {
    if (self.disRecordScreenView) {
        [self.disRecordScreenView removeFromSuperview];
        self.disRecordScreenView = nil;
    }
}

+ (BOOL)isOpenDisrecord {
    return OpenDisrecord;
}

@end
