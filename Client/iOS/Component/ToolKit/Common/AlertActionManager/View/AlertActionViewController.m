// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "AlertActionViewController.h"
#import "Masonry.h"

@interface AlertActionViewController ()

@property (nonatomic, weak) AlertActionView *actionView;
@property (nonatomic, strong) NSMutableArray<AlertActionModel *> *actionList;

@property (nonatomic, strong) AlertUserModel *alertUserModel;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *describe;
@end

@implementation AlertActionViewController

- (instancetype)initWithTitle:(NSString *)title
                     describe:(NSString *)describe {
    if (self = [super init]) {
        _message = title;
        _describe = describe;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    AlertActionView *actionView = [[AlertActionView alloc] initWithTitle:self.message describe:self.describe alertActionList:[self.actionList copy] alertUserModel:self.alertUserModel];
    [self.view addSubview:actionView];
    [actionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(310);
        make.center.equalTo(self.view);
    }];
    __weak __typeof(self) wself = self;
    actionView.clickButtonBlock = ^{
        if (wself.clickButtonBlock) {
            wself.clickButtonBlock();
        }
    };
    self.actionView = actionView;
}

#pragma mark - Publish Action

- (void)addAlertUser:(AlertUserModel *)alertUserModel {
    self.alertUserModel = alertUserModel;
}

- (void)addAction:(AlertActionModel *)alertAction {
    [self.actionList addObject:alertAction];
}

#pragma mark - Getter

- (NSMutableArray *)actionList {
    if (!_actionList) {
        _actionList = [[NSMutableArray alloc] init];
    }
    return _actionList;
}

@end
