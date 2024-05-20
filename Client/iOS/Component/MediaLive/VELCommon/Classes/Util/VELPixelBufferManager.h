// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <CoreFoundation/CoreFoundation.h>
#import <CoreMedia/CoreMedia.h>
NS_ASSUME_NONNULL_BEGIN
@interface VELPixelBufferManager : NSObject
+ (CVPixelBufferRef)fromImage:(UIImage *)image;
+ (CVPixelBufferRef)fromBGRAData:(NSData *)data width:(int)width height:(int)height;
+ (CVPixelBufferRef)fromNV12Data:(NSData *)data width:(int)width height:(int)height;
+ (CVPixelBufferRef)fromNV21Data:(NSData *)data width:(int)width height:(int)height;
+ (CVPixelBufferRef)fromYUVData:(NSData *)data width:(int)width height:(int)height;

+ (CMSampleBufferRef)sampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;

+ (void)releaseMemory;
@end

NS_ASSUME_NONNULL_END
