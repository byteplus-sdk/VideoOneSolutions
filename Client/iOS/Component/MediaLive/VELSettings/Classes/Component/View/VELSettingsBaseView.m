// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseView.h"
#import <ToolKit/ToolKit.h>
@interface VELSettingContainerView : UIView
@end
@implementation VELSettingContainerView
@end
@interface VELSettingsBaseView ()
@property (nonatomic, strong) UIView *disableView;
@property (nonatomic, strong) UIVisualEffectView *visualEffectView;
@property (nonatomic, strong) CALayer *shadowLayer;
@property (nonatomic, strong, readwrite) VELSettingContainerView *container;
@property (nonatomic, assign) BOOL allowedAddSubView;
@end
@implementation VELSettingsBaseView
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _enable = YES;
        self.allowedAddSubView = YES;
        [self addSubview:self.container];
        [self initSubviewsInContainer:self.container];
        [self addSubview:self.disableView];
        [self.disableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.container);
        }];
        self.allowedAddSubView = NO;
    }
    return self;
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    if ([self.model isKindOfClass:VELSettingsBaseViewModel.class]) {
        VELSettingsBaseViewModel *model = self.model;
        if (model.showDisableMask) {
            self.disableView.hidden = enable;
        } else {
            self.disableView.hidden = YES;
        }
    }
    
}

- (void)setModel:(__kindof VELSettingsBaseViewModel *)model {
    if (_model == nil && model == nil) {
        return;
    }
    _model = model;
    [self layoutSubViewWithModel];
    [self updateSubViewStateWithModel];
}

- (void)layoutSubViewWithModel {
    if ([self.model isKindOfClass:VELSettingsBaseViewModel.class]) {
        VELSettingsBaseViewModel *model = self.model;
        [self.container mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).mas_offset(model.margin);
            if (model.containerSize.height > 0) {
                make.height.mas_equalTo(model.containerSize.height).priorityMedium();
            }
        }];
    }
}

- (void)updateSubViewStateWithModel {
    if ([self.model isKindOfClass:VELSettingsBaseViewModel.class]) {
        VELSettingsBaseViewModel *model = self.model;
        self.shadowLayer.hidden = !model.hasShadow;
        self.container.layer.cornerRadius = model.cornerRadius;
        if (model.hasBorder) {
            self.container.layer.borderColor = model.isSelected ? model.selectedBorderColor.CGColor : model.borderColor.CGColor;
            self.container.layer.borderWidth = model.borderWidth;
        }
        if (model.hasShadow) {
            self.shadowLayer.cornerRadius = model.cornerRadius;
            self.shadowLayer.backgroundColor = [model.shadowColor colorWithAlphaComponent:model.shadowOpacity].CGColor;
            self.shadowLayer.shadowColor = model.shadowColor.CGColor;
            self.shadowLayer.shadowRadius = model.shadowRadius;
            self.shadowLayer.shadowOpacity = model.shadowOpacity;
            self.shadowLayer.shadowOffset = model.shadowOffset;
            [self.layer insertSublayer:self.shadowLayer below:self.container.layer];
        }
        UIColor *containerColor = model.isSelected ? model.containerSelectBackgroundColor : model.containerBackgroundColor;
        self.backgroundColor = model.showVisualEffect ? UIColor.clearColor : model.backgroundColor;
        self.container.backgroundColor = model.showVisualEffect ? UIColor.clearColor : containerColor;
        self.visualEffectView.hidden = !model.showVisualEffect;
        self.disableView.layer.cornerRadius = model.cornerRadius;
        self.disableView.clipsToBounds = YES;
        if (model.showDisableMask) {
            self.disableView.hidden = model.enable;
        } else {
            self.disableView.hidden = YES;
        }
    }
}

- (void)addSubview:(UIView *)view {
    [super addSubview:view];
}

- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    [super insertSubview:view atIndex:index];
}

- (void)insertSubview:(UIView *)view aboveSubview:(UIView *)siblingSubview {
    [super insertSubview:view aboveSubview:siblingSubview];
}

- (void)insertSubview:(UIView *)view belowSubview:(UIView *)siblingSubview {
    [super insertSubview:view belowSubview:siblingSubview];
}

- (void)initSubviewsInContainer:(UIView *)container {
    VOLogI(VOMediaLive,@"VELSettingsBaseView -- implemented by subclass");
}

- (VELSettingContainerView *)container {
    if (!_container) {
        _container = [[VELSettingContainerView alloc] init];
        _container.clipsToBounds = YES;
        [_container addSubview:self.visualEffectView];
        [self.visualEffectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_container);
        }];
    }
    return _container;
}

- (CALayer *)shadowLayer {
    if (!_shadowLayer) {
        _shadowLayer = [[CALayer alloc] init];
        _shadowLayer.shadowColor = [UIColor blackColor].CGColor;
        _shadowLayer.shadowRadius = 3;
        _shadowLayer.shadowOpacity = 0.02;
        _shadowLayer.shadowOffset = CGSizeZero;
        _shadowLayer.masksToBounds = NO;
    }
    return _shadowLayer;
}

- (UIVisualEffectView *)visualEffectView {
    if (!_visualEffectView) {
        _visualEffectView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:(UIBlurEffectStyleDark)]];
        _visualEffectView.hidden = YES;
    }
    return _visualEffectView;
}

- (UIView *)disableView {
    if (!_disableView) {
        _disableView = [[UIView alloc] init];
        _disableView.backgroundColor = VELViewBackgroundColor;
        _disableView.alpha = 0.6;
        _disableView.hidden = YES;
    }
    return _disableView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.shadowLayer.frame = self.container.frame;
}

- (void)dealloc {
    VELLogDebug(@"Memory", @"%@ - dealloc", NSStringFromClass(self.class));
}
@end


@interface VELSettingsBaseCollectionCell ()
@property (nonatomic, strong) VELSettingsBaseView *settingView;
@end

@implementation VELSettingsBaseCollectionCell
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setModel:(__kindof VELSettingsBaseViewModel *)model {
    _model = model;
    if (!self.settingView) {
        [self setupUI];
    }
    if (model.useCellSelect) {
        model.isSelected = self.isSelected;
    }
    self.settingView.model = model;
}
- (void)setEnable:(BOOL)enable {
    _enable = enable;
    self.settingView.enable = enable;
}

- (void)setupUI {
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    self.selectedBackgroundView = nil;
    self.settingView = (VELSettingsBaseView *)[self.model createSettingsViewFor:[NSString stringWithFormat:@"%@", self]];
    [self.contentView addSubview:self.settingView];
    [self.settingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if ([self.model isKindOfClass:VELSettingsBaseViewModel.class]) {
        VELSettingsBaseViewModel *model = self.model;
        if (model.useCellSelect) {
            model.isSelected = selected;
            [self.settingView updateSubViewStateWithModel];
        }
    }
}
@end


@interface VELSettingsBaseTableCell ()
@property (nonatomic, strong) VELSettingsBaseView *settingView;
@end

@implementation VELSettingsBaseTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setModel:(__kindof VELSettingsBaseViewModel *)model {
    _model = model;
    if (!self.settingView) {
        [self setupUI];
    }
    self.settingView.model = model;
}

- (void)setEnable:(BOOL)enable {
    _enable = enable;
    self.settingView.enable = enable;
}

- (void)setupUI {
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    self.selectedBackgroundView = nil;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.settingView = (VELSettingsBaseView *)[self.model createSettingsViewFor:[NSString stringWithFormat:@"%@", self]];
    [self.contentView addSubview:self.settingView];
    [self.settingView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if ([self.model isKindOfClass:VELSettingsBaseViewModel.class]) {
        VELSettingsBaseViewModel *model = self.model;
        if (model.useCellSelect) {
            model.isSelected = selected;
            [self.settingView updateSubViewStateWithModel];
        }
    }
}

@end
