//
// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LiveInfomationModel : NSObject

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *value;

@property (nonatomic, assign) BOOL isSegmentation;

@end

@interface LiveInformationStreamModel : NSObject

@property (nonatomic, assign) NSInteger defaultBitrate;

@property (nonatomic, assign) NSInteger minBitrate;

@property (nonatomic, assign) NSInteger maxBitrate;

@property (nonatomic, copy) NSString *captureResolution;

@property (nonatomic, copy) NSString *pushResolution;

@property (nonatomic, assign) NSInteger defaultFps;

@property (nonatomic, copy) NSString *encodeFormat;

@property (nonatomic, copy) NSString *adaptiveBitrateMode;

// real time.
@property (nonatomic, assign) NSInteger captureFps;

@property (nonatomic, assign) NSInteger transFps;

@property (nonatomic, assign) NSInteger realTimeEncodeBitrate;

@property (nonatomic, assign) NSInteger realTimeTransBitrate;

- (void)parseStreamLog:(NSDictionary *)log extra:(NSDictionary *)extra;

- (NSString *)integerToString:(NSInteger)value;

@end

NS_ASSUME_NONNULL_END
