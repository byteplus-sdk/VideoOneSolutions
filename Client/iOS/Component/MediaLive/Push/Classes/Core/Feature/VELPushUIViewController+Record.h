// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPushUIViewController_Record_h
#define VELPushUIViewController_Record_h
#import "VELPushUIViewController.h"
@interface VELPushUIViewController (Record)
@property (nonatomic, strong, nullable) NSTimer *recordTimer;
@property (nonatomic, assign) NSTimeInterval recordTime;
@end
#endif /* VELPushUIViewController_Record_h */
