// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveInfomationModel.h"

@implementation LiveInfomationModel


@end



@implementation LiveInformationStreamModel


- (void)parseStreamLog:(NSDictionary *)log extra:(NSDictionary *)extra {
    self.defaultBitrate = MAX(0, [extra[@"defaultBitrate"] integerValue]);
    self.minBitrate = MAX(0, [extra[@"minBitrate"] integerValue]);
    self.maxBitrate = MAX(0, [extra[@"maxBitrate"] integerValue]);
    self.pushResolution = [NSString stringWithFormat:@"%@*%@", log[@"width"] ?:@"0", log[@"height"] ?:@"0"];
    self.captureResolution = self.pushResolution.copy;
    self.defaultFps = [extra[@"fps"] integerValue];
    self.encodeFormat = [NSString stringWithFormat:@"%@/hardware = %ld",log[@"video_codec"] ?: @"unknown", [log[@"hardware"] integerValue]];
    
    
    self.captureFps = [log[@"preview_fps"] integerValue];
    self.transFps = [log[@"encode_fps"] integerValue];
    self.realTimeEncodeBitrate = MAX(0, [log[@"video_enc_bitrate"] integerValue]);
    self.realTimeTransBitrate = MAX(0, [log[@"real_bitrate"] integerValue]);
    self.adaptiveBitrateMode = extra[@"strategy"] ?: @"";
    
}

- (NSString *)integerToString:(NSInteger)value {
    return [NSString stringWithFormat:@"%ld", value];
}

@end
