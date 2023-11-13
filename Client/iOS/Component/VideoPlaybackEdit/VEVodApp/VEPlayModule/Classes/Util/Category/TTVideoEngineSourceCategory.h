// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
@import Foundation;
#import <TTSDK/TTVideoEngineVidSource.h>
#import <TTSDK/TTVideoEngineUrlSource.h>
#import <TTSDK/TTVideoEngineMultiEncodingUrlSource.h>


@interface TTVideoEngineMultiEncodingUrlSource (VECodecUrlSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;

@end

@interface TTVideoEngineVidSource (VEVidSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;

@end

@interface TTVideoEngineUrlSource (VEUrlSource)

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *cover;

@end

