// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "ChorusMusicLyricCell.h"
#import "ChorusMusicLyricPosModel.h"
#import "ChorusMusicLyricView.h"
#import "ChorusMusicLyricsAnalyzer.h"

@interface ChorusMusicLyricView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) ChorusMusicLyricModel *model;
@property (nonatomic, strong) ChorusMusicLyricConfig *config;
@property (nonatomic, assign) NSInteger currentRow;
@property (nonatomic, assign) NSInteger pos;
@property (nonatomic, strong) NSMutableArray *posList;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation ChorusMusicLyricView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        self.currentRow = 0;
        self.pos = -1;

        [self addSubview:self.tableView];
        self.layer.mask = self.gradientLayer;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.tableView.frame = self.bounds;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.tableView.frame.size.height - self.tableView.rowHeight, 0);
    self.gradientLayer.frame = self.bounds;
}

#pragma mark - Publish Action

- (void)loadLrcByPath:(NSString *)path
               config:(ChorusMusicLyricConfig *)config
                error:(NSError * _Nullable *)error {
    self.config = config;
    
    self.model = [ChorusMusicLyricsAnalyzer analyzeLrcByPath:path
                                                lrcFormat:config.lrcFormat];
    
    [self.tableView reloadData];
}

- (void)playAtTime:(NSTimeInterval)time {
    if (time < 0) {
        return;
    }

    [self updateLyric:time];
    [self linefeed:time];
}

- (void)reset {
    self.model = nil;
    [self.tableView reloadData];
}

#pragma mark - Private Action

- (void)setCurrentRow:(NSInteger)currentRow currentTime:(NSInteger)currentTime {
    if (_currentRow != currentRow) {
        _currentRow = currentRow;
        [self.tableView reloadData];
        [self.tableView layoutIfNeeded];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentRow inSection:0]
                              atScrollPosition:UITableViewScrollPositionTop
                                      animated:YES];
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:currentRow inSection:0];
        ChorusMusicLyricCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell playProgress:currentTime];
    }
}

- (void)updateLyric:(NSInteger)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        CGFloat secTime = progress;
        ChorusMusicLyricLineModel *lastLineModel = self.model.lines.lastObject;
        if (lastLineModel && secTime > lastLineModel.beginTime) {
            // Last line of lyrics
            NSInteger currentRow = self.model.lines.count - 1;
            [self setCurrentRow:currentRow currentTime:progress];
            return;
        }
        for (int i = 0; i < self.model.lines.count; i++) {
            ChorusMusicLyricLineModel *lineModel = self.model.lines[i];
            if (lineModel.beginTime > secTime) {
                NSInteger currentRow = 0;
                if (i > 0) {
                    currentRow = i - 1;
                }
                [self setCurrentRow:currentRow currentTime:progress];
                break;
            }
        }
    });
}

- (void)linefeed:(NSInteger)progress {
    NSInteger pos = [self getCurPos:progress];
    if (self.pos + 1 != pos) {
        self.pos = pos;
        return;
    }
    if ([self isLineFeedAtPos:pos]) {
        self.pos = pos;
        [self addPos:pos];
    }
    ChorusMusicLyricLineModel *lineModel = self.model.lines[pos];
    if (self.finishLineBlock) {
        self.finishLineBlock(lineModel);
    }
}

- (NSInteger)getCurPos:(NSInteger)progress {
    NSInteger pos = -1;
    for (int i = 0; i < self.model.lines.count; i++) {
        ChorusMusicLyricLineModel *lineModel = self.model.lines[i];
        ChorusMusicLyricWordModel *lastWordModel = lineModel.words.lastObject;
        if (lastWordModel) {
            NSInteger endTime = lineModel.beginTime + lastWordModel.offset + lastWordModel.duration;
            if (progress >= endTime) {
                pos = i;
            } else {
                break;
            }
        }
    }
    return pos;
}

- (BOOL)isLineFeedAtPos:(NSInteger)pos {
    NSMutableIndexSet *removeIndices = [NSMutableIndexSet indexSet];
    for (int i = 0; i < self.posList.count; i++) {
        ChorusMusicLyricPosModel *posModel = self.posList[i];
        if (posModel.pos == pos) {
            return NO;
        }
        [removeIndices addIndex:i];
    }
    [self.posList removeObjectsAtIndexes:removeIndices];

    return YES;
}

- (void)addPos:(NSInteger)pos {
    ChorusMusicLyricPosModel *posModel = [[ChorusMusicLyricPosModel alloc] init];
    posModel.pos = pos;
    posModel.time = [[NSDate date] timeIntervalSince1970];
    [self.posList addObject:posModel];
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [[CAGradientLayer alloc] init];
        _gradientLayer.colors = @[
            (__bridge id)[UIColor colorWithWhite:0 alpha:1.0f].CGColor,
            (__bridge id)[UIColor colorWithWhite:0 alpha:1.0f].CGColor,
            (__bridge id)[UIColor colorWithWhite:0 alpha:1.0f].CGColor,
            (__bridge id)[UIColor colorWithWhite:0 alpha:0.1f].CGColor
        ];
        _gradientLayer.locations = @[@0, @0.2, @.7, @1];
        _gradientLayer.startPoint = CGPointMake(0.5, 0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1);
    }
    return _gradientLayer;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.lines.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChorusMusicLyricCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(ChorusMusicLyricCell.class)];
    ChorusMusicLyricLineModel *lineModel = self.model.lines[indexPath.row];
    cell.lineModel = lineModel;
    cell.config = self.config;
    [cell setCurrentRow:indexPath.row playingRow:_currentRow];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [ChorusMusicLyricCell getCellHeight:self.model.lines[indexPath.row]
                                     config:self.config
                                   maxWidth:self.width];
}

#pragma mark - Getter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.userInteractionEnabled = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[ChorusMusicLyricCell class] forCellReuseIdentifier:NSStringFromClass(ChorusMusicLyricCell.class)];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}

- (NSMutableArray *)posList {
    if (!_posList) {
        _posList = [[NSMutableArray alloc] init];
    }
    return _posList;
}

@end
