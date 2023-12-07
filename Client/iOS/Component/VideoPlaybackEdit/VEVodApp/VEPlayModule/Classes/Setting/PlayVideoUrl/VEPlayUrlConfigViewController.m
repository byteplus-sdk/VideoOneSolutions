//
//  VEPlayUrlConfigViewController.m
//  VideoPlaybackEdit
//
//  Created by bytedance on 2023/11/1.
//

#import "VEPlayUrlConfigViewController.h"
#import <Masonry/Masonry.h>
#import "VEVideoUrlParser.h"
#import "VEShortVideoDemoViewController.h"
#import "VEFeedVideoDemoViewController.h"
#import "ToastComponent.h"

@interface VEPlayUrlConfigViewController ()

@property (nonatomic, strong) UITextView *inputView;
@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation VEPlayUrlConfigViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *closeButton = [UIButton new];
    [closeButton setImage:[UIImage imageNamed:@"black_back"] forState:UIControlStateNormal];
    [self.view addSubview:closeButton];
    [closeButton addTarget:self action:@selector(onClose) forControlEvents:UIControlEventTouchUpInside];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.top.equalTo(self.view).offset(40);
        make.size.equalTo(@(CGSizeMake(40, 40)));
    }];
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    [self.view addSubview:lineView];
    [lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(closeButton.mas_bottom).offset(4);
        make.height.equalTo(@(0.5));
    }];
    
    self.inputView = [UITextView new];
    self.inputView.textColor = [UIColor blackColor];
    [self.view addSubview:self.inputView];
    self.inputView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    self.inputView.layer.cornerRadius = 5;
    
    [self.inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(10);
        make.right.equalTo(self.view).offset(-10);
        make.top.equalTo(lineView.mas_bottom).offset(10);
        make.height.equalTo(@(300));
    }];
    
    NSArray *titles = @[@"ENTER SHORT VIDEO", @"ENTER FEED VIDEO", @"CLEAN CACHE"];
    
    CGFloat buttonHeight = 44;
    CGRect rect = CGRectMake(10, self.view.frame.size.height - buttonHeight*3 - 20 - 40, self.view.frame.size.width-20, buttonHeight);
    for (NSUInteger i = 0; i <= titles.count - 1; i++) {
        NSString *title = titles[i];
        UIButton *btn = [UIButton new];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor colorWithWhite:0.8 alpha:1.0]];
        btn.layer.cornerRadius = 4;
        btn.tag = i;
        [btn addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        btn.frame = rect;
        rect.origin.y += buttonHeight + 10;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
    
}

- (void)keyboardWillShow:(NSNotification *)noti {
    NSValue *value = [noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect rect = value.CGRectValue;
    self.keyboardHeight = rect.size.height;
}

- (void)onTap:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.view];
    if (self.keyboardHeight > 0 && point.y < self.view.frame.size.height - self.keyboardHeight) {
        [self.inputView resignFirstResponder];
    }
}

- (void)onButtonClick:(UIButton *)sender {
    if (sender.tag == 2) {
        self.inputView.text = nil;
        return;
    }
    NSString *url = [self.inputView text];
    if (!url.length) {
        return;
    }
    NSArray *videoModels = [VEVideoUrlParser parseUrl:url];
    if (!videoModels.count) {
        [[ToastComponent shareToastComponent] showWithMessage:@"Input url error, please check it."];
        return;
    }
    
    if (sender.tag == 0) {
        //short video
        VEShortVideoDemoViewController *vc = [[VEShortVideoDemoViewController alloc] init];
        vc.videoModels = videoModels.copy;
        [self.navigationController pushViewController:vc animated:YES];
    } else if (sender.tag == 1) {
        //feed video
        VEFeedVideoDemoViewController *vc = [[VEFeedVideoDemoViewController alloc] init];
        vc.videoModels = videoModels.copy;
        [self.navigationController pushViewController:vc animated:YES];
        
    }
}

- (void)onClose {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
