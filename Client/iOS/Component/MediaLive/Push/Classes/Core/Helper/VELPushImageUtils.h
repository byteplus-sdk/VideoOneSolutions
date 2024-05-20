// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPushImageUtils_h
#define VELPushImageUtils_h

#import <OpenGLES/ES2/glext.h>
#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import "VELPushGLTexture.h"
typedef NS_ENUM(NSInteger, VELImageFormatType) {
    VELImageFormatType_UNKNOW,
    // 8bit R G B A
    VELImageFormatType_RGBA,
    // 8bit B G R A
    VELImageFormatType_BGRA,
    // video range, 8bit Y1 Y2 Y3 Y4... U1 V1...
    VELImageFormatType_YUV420V,
    // full range, 8bit Y1 Y2 Y3 Y4... U1 V1...
    VELImageFormatType_YUV420F
};

@interface VELPushPixelBufferInfo : NSObject

@property (nonatomic, assign) VELImageFormatType format;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int bytesPerRow;

@end

@interface VELPushImageBuffer : NSObject
@property (nonatomic, assign) unsigned char *buffer;
@property (nonatomic, assign) unsigned char *yBuffer;
@property (nonatomic, assign) unsigned char *uvBuffer;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int yWidth;
@property (nonatomic, assign) int yHeight;
@property (nonatomic, assign) int uvWidth;
@property (nonatomic, assign) int uvHeight;
@property (nonatomic, assign) int bytesPerRow;
@property (nonatomic, assign) int yBytesPerRow;
@property (nonatomic, assign) int uvBytesPerRow;
@property (nonatomic, assign) VELImageFormatType format;

@end

@interface VELPushImageUtils : NSObject
@property (nonatomic, strong) EAGLContext *glContext;
#pragma mark - Init output texture and get
- (VELPushPixelBufferGLTexture *)getOutputPixelBufferGLTextureWithWidth:(int)width height:(int)height format:(VELImageFormatType)format;
- (void)setUseCachedTexture:(BOOL)useCache;

#pragma mark - CVPixelBuffer to others
/// @param pixelBuffer CVPixelBuffer
- (VELPushImageBuffer *)transforCVPixelBufferToBuffer:(CVPixelBufferRef)pixelBuffer outputFormat:(VELImageFormatType)outputFormat;
/// @param pixelBuffer CVPixelBuffer
- (VELPushPixelBufferGLTexture *)transforCVPixelBufferToTexture:(CVPixelBufferRef)pixelBuffer;
- (CVPixelBufferRef)transforCVPixelBufferToCVPixelBuffer:(CVPixelBufferRef)pixelBuffer outputFormat:(VELImageFormatType)outputFormat;
/// @param pixelBuffer CVPixelBuffer
- (CVPixelBufferRef)rotateCVPixelBuffer:(CVPixelBufferRef)pixelBuffer rotation:(int)rotation;
- (CVPixelBufferRef)blendCVPixelBuffer:(CVPixelBufferRef)pixelBuffer blendColor:(UIColor *)color;
- (VELPushImageBuffer *)live_getBufferFromCVPixelBuffer:(CVPixelBufferRef)pixelBuffer;

#pragma mark - VELPushImageBuffer to others
/// @param buffer VELPushImageBuffer
- (CVPixelBufferRef)transforBufferToCVPixelBuffer:(VELPushImageBuffer *)buffer outputFormat:(VELImageFormatType)outputFormat;
/// @param buffer VELPushImageBuffer
- (BOOL)transforBufferToCVPixelBuffer:(VELPushImageBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer;
- (VELPushImageBuffer *)transforBufferToBuffer:(VELPushImageBuffer *)inputBuffer outputFormat:(VELImageFormatType)outputFormat;
- (BOOL)transforBufferToBuffer:(VELPushImageBuffer *)inputBuffer outputBuffer:(VELPushImageBuffer *)outputBuffer;
- (BOOL)rotateBufferToBuffer:(VELPushImageBuffer *)inputBuffer outputBuffer:(VELPushImageBuffer *)outputBuffer rotation:(int)rotation;
/// @param buffer VELPushImageBuffer
- (id<VELPushGLTexture>)transforBufferToTexture:(VELPushImageBuffer *)buffer;
/// @param buffer VELPushImageBuffer
- (UIImage *)transforBufferToUIImage:(VELPushImageBuffer *)buffer;

#pragma mark - Texture to others
- (VELPushImageBuffer *)transforTextureToBEBuffer:(GLuint)texture width:(int)widht height:(int)height outputFormat:(VELImageFormatType)outputFormat;

#pragma mark - UIImage to others
/// @param image UIImage
- (VELPushImageBuffer *)transforUIImageToBEBuffer:(UIImage *)image;

#pragma mark - Utils
/// @param pixelBuffer CVPixelBuffer
- (VELImageFormatType)getCVPixelBufferFormat:(CVPixelBufferRef)pixelBuffer;
/// @param type OSType
- (VELImageFormatType)getFormatForOSType:(OSType)type;
/// @param format VELImageFormatType
- (OSType)getOsType:(VELImageFormatType)format;
/// @param format VELImageFormatType
- (GLenum)getGlFormat:(VELImageFormatType)format;
/// @param pixelBuffer CVPixelBuffer
- (VELPushPixelBufferInfo *)getCVPixelBufferInfo:(CVPixelBufferRef)pixelBuffer;
/// @param bytesPerRow bytesPerRow
/// @param format VELImageFormatType
- (VELPushImageBuffer *)allocBufferWithWidth:(int)width height:(int)height bytesPerRow:(int)bytesPerRow format:(VELImageFormatType)format;


- (NSData *)dataOfPixelBuffer:(CVPixelBufferRef)pixelBuffer;

- (void)beginCurrentContext;

- (void)endCurrentContext;
@end

#endif /* VELPushImageUtils_h */
