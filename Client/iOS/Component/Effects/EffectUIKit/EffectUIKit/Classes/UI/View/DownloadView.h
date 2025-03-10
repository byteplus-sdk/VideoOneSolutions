// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef DownloadView_h
#define DownloadView_h

#import <UIKit/UIkit.h>

typedef NS_ENUM(NSInteger, DownloadViewState) {
    DownloadViewStateInit,
    DownloadViewStateDownloading,
    DownloadViewStateDownloaded,
};

@interface DownloadView : UIView

@property (nonatomic, assign) DownloadViewState state;

@property (nonatomic, assign) CGFloat downloadProgress;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) CGFloat backgroundLineWidth;
@property (nonatomic, strong) UIColor *progressColor;
@property (nonatomic, assign) CGFloat progressLineWidth;
@property (nonatomic, strong) UIImage *downloadImage;

@end

#endif /* DownloadView_h */
