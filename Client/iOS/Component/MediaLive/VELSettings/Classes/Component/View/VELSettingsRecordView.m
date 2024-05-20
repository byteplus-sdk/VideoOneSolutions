// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsRecordView.h"
#import "VELSettingsSegmentViewModel.h"
#import "VELSettingsSwitchViewModel.h"
#import "VELSettingsPopChooseViewModel.h"
#import <ToolKit/Localizator.h>
@interface VELSettingsRecordView ()
@property (nonatomic, strong) NSDateFormatter *dateFormater;
@property (nonatomic, strong) VELSettingsSegmentViewModel *segmentUIModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *recordModel;
@property (nonatomic, strong) VELSettingsPopChooseViewModel *recordResolutionViewModel;
@property (nonatomic, strong) VELSettingsSwitchViewModel *snapshotModel;
@property (nonatomic) NSInteger recordSolution;//0-360P、1-480P、2-540P、3-720P、4-1080P
@end
@implementation VELSettingsRecordView

- (void)initSubviewsInContainer:(UIView *)container {
    UIView *segmentView = self.segmentUIModel.settingView;
    [container addSubview:segmentView];
    [segmentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container).mas_offset(self.model.insets);
    }];
}

- (void)layoutSubViewWithModel {
    [super layoutSubViewWithModel];
    
    if (self.model.showSanpShot) {
        self.segmentUIModel.segmentModels = @[self.recordModel, self.recordResolutionViewModel, self.snapshotModel];
    } else {
        self.segmentUIModel.segmentModels = @[self.recordModel];
    }
    [self.segmentUIModel updateUI];
}
- (void)updateSubViewStateWithModel {
    [super updateSubViewStateWithModel];
    if (self.model.time > 0) {
        self.recordModel.des = [self.dateFormater stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.model.time]];
    } else {
        self.recordModel.des = @"";
    }
    self.recordModel.on = self.model.state == VELSettingsRecordStateStart;
    [self.recordModel updateUI];
}

- (VELSettingsSegmentViewModel *)segmentUIModel {
    if (!_segmentUIModel) {
        _segmentUIModel = [[VELSettingsSegmentViewModel alloc] init];
        _segmentUIModel.cornerRadius = 0;
        _segmentUIModel.itemMargin = 3;
        _segmentUIModel.disableSelectd = YES;
        _segmentUIModel.margin = UIEdgeInsetsMake(10, 15, 10, 15);
        _segmentUIModel.scrollDirection = UICollectionViewScrollDirectionVertical;
        _segmentUIModel.backgroundColor = UIColor.clearColor;
        _segmentUIModel.containerBackgroundColor = UIColor.clearColor;
        _segmentUIModel.containerSelectBackgroundColor = UIColor.clearColor;
        _segmentUIModel.scrollDirection = UICollectionViewScrollDirectionVertical;
        _segmentUIModel.size = CGSizeMake(VELAutomaticDimension, 78);
    }
    return _segmentUIModel;
}

- (VELSettingsSwitchViewModel *)recordModel {
    if (!_recordModel) {
        _recordModel = [[VELSettingsSwitchViewModel alloc] init];
        _recordModel.title = LocalizedStringFromBundle(@"medialive_record_title", @"MediaLive");
        _recordModel.backgroundColor = UIColor.clearColor;
        _recordModel.containerBackgroundColor = UIColor.clearColor;
        _recordModel.containerSelectBackgroundColor = UIColor.clearColor;
        _recordModel.size = CGSizeMake(VELAutomaticDimension, 30);
        __weak __typeof__(self)weakSelf = self;
        [_recordModel setSwitchBlock:^(BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            self.model.state = isOn ? VELSettingsRecordStateStart : VELSettingsRecordStateStop;
            if (self.model.recordActionBlock) {
                int w = 360;
                int h = 640;
                switch (self.recordSolution) {
                    case 0:
                        w = 360;
                        h = 640;
                        break;
                    case 1:
                        w = 480;
                        h = 864;
                        break;
                    case 2:
                        w = 540;
                        h = 960;
                        break;
                    case 3:
                        w = 720;
                        h = 1280;
                        break;
                    case 4:
                        w = 1080;
                        h = 1920;
                        break;
                    default:
                        break;
                }
                
                self.model.recordActionBlock(self.model, self.model.state, w, h);
            }
        }];
    }
    return _recordModel;
}

- (VELSettingsPopChooseViewModel *)recordResolutionViewModel {
    if (!_recordResolutionViewModel) {
        __weak __typeof__(self)weakSelf = self;
        _recordResolutionViewModel = [VELSettingsPopChooseViewModel createCommonMenuModelWithTitle:LocalizedStringFromBundle(@"medialive_record_resolution", @"MediaLive") menuTitles:@[@"360P", @"480P", @"540P", @"720P", @"1080"] menuValues:@[@0, @1, @2, @3, @4] selectBlock:^BOOL(NSInteger index, NSNumber * _Nonnull value) {
            __strong __typeof__(weakSelf)self = weakSelf;
            self.recordSolution = [value integerValue];
            return YES;
        }];
        [_recordResolutionViewModel clearDefault];
        _recordResolutionViewModel.size = CGSizeMake(VELAutomaticDimension, 35);
        _recordResolutionViewModel.margin = UIEdgeInsetsMake(2, 0, 2, 0);
    }
    return _recordResolutionViewModel;
}

- (VELSettingsSwitchViewModel *)snapshotModel {
    if (!_snapshotModel) {
        _snapshotModel = [[VELSettingsSwitchViewModel alloc] init];
        _snapshotModel.title = LocalizedStringFromBundle(@"medialive_screen_snapshot", @"MediaLive");
        _snapshotModel.convertToBtn = YES;
        _snapshotModel.btnTitle =  LocalizedStringFromBundle(@"medialive_intercept", @"MediaLive");
        _snapshotModel.backgroundColor = UIColor.clearColor;
        _snapshotModel.containerBackgroundColor = UIColor.clearColor;
        _snapshotModel.containerSelectBackgroundColor = UIColor.clearColor;
        _snapshotModel.size = CGSizeMake(VELAutomaticDimension, 30);
        __weak __typeof__(self)weakSelf = self;
        [_snapshotModel setSwitchBlock:^(BOOL isOn) {
            __strong __typeof__(weakSelf)self = weakSelf;
            if (self.model.recordActionBlock) {
                self.model.recordActionBlock(self.model, VELSettingsRecordStateSnapshot, 0, 0);
            }
        }];
    }
    return _snapshotModel;
}

- (NSDateFormatter *)dateFormater {
    if (!_dateFormater) {
        _dateFormater = [[NSDateFormatter alloc] init];
        _dateFormater.dateFormat = @"mm:ss";
    }
    return _dateFormater;
}

@end
