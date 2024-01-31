// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "NoticeViewController.h"
#import <Masonry/Masonry.h>
#import <ToolKit/ToolKit.h>

@interface NoticeViewController ()

@property (nonatomic, strong) UITextView *textView;

@property (nonatomic, strong) BaseButton *leftButton;

@end

@implementation NoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.leftButton];
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.view);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(48);
    }];
    
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftButton.mas_bottom);
        make.left.right.bottom.equalTo(self.view);
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *filepath = [bundle pathForResource:@"notice" ofType:@"txt"];
    NSError *error;
    NSString *fileContents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:&error];
    
    if(fileContents) {
        self.textView.text = fileContents;
    } else {
        NSLog(@"Error reading file: %@", error);
    }
}

- (void)navBackAction {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Getter
- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.editable = NO;
        _textView.selectable = NO;
        _textView.textContainerInset = UIEdgeInsetsMake(0, 25, 0, 25);
    }
    return _textView;
}

- (BaseButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [[BaseButton alloc] init];
        [_leftButton setImage:[UIImage imageNamed:@"img_left_black" bundleName:@"App"] forState:UIControlStateNormal];
        _leftButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_leftButton addTarget:self action:@selector(navBackAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

@end
