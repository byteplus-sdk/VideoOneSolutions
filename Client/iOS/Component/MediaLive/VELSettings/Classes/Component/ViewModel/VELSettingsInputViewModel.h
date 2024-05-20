// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELSettingsBaseViewModel.h"

NS_ASSUME_NONNULL_BEGIN
@interface VELSettingsInputViewModel : VELSettingsBaseViewModel
@property (nonatomic, copy, nullable) NSString *title;
@property (nonatomic, assign) UIEdgeInsets textInset;
/// NSFontAttributeName : [UIFont systemFontOfSize:20],
/// NSForegroundColorAttributeName : VELColorWithHex(0x1D2129)
/// }
@property (nonatomic, strong) NSMutableDictionary *titleAttribute;
@property (nonatomic, copy, nullable) NSString *placeHolder;
@property (nonatomic, strong) NSMutableDictionary *placeHolderAttribute;
@property (nonatomic, copy, nullable) NSString *text;
@property (nonatomic, assign) BOOL disableTextCheck;
@property (nonatomic, strong) NSMutableDictionary *textAttribute;
@property (nonatomic, assign) BOOL showQRScan;
@property (nonatomic, assign) BOOL qRScanInContainer;
@property (nonatomic, copy) NSString *qrScanTip;
@property (nonatomic, strong) NSMutableDictionary *qrScanTipAttribute;
@property (nonatomic, strong) UIImage *qrScanIcon;
@property (nonatomic, assign) CGSize qrScanSize;
@property (nonatomic, assign) CGFloat spacingBetweenQRAndInput;
@property (nonatomic, assign) CGFloat spacingBetweenTitleAndInput;
@property(nonatomic, copy) void (^qrScanActionBlock)(VELSettingsInputViewModel *model);
@property(nonatomic, copy) void (^textDidChangedBlock)(VELSettingsInputViewModel *model, NSString *text);

+ (instancetype)modeWithTitle:(nullable NSString *)title placeHolder:(nullable NSString *)placeHolder;
@end

NS_ASSUME_NONNULL_END
