// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#ifndef VELPushGLTexture_h
#define VELPushGLTexture_h

#import <OpenGLES/ES2/glext.h>
#import <CoreVideo/CoreVideo.h>

typedef NS_ENUM(NSInteger, VELPushGLTextureType) {
    VELImageFormatType_NORMAL_TEXTURE,
    VELImageFormatType_PIXEL_BUFFER_TEXTURE
};

@protocol VELPushGLTexture <NSObject>
@property (nonatomic) GLuint texture;
@property (nonatomic) VELPushGLTextureType type;
@property (nonatomic) BOOL available;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
- (instancetype)initWithWidth:(int)width height:(int)height;
- (void)updateWidth:(int)width height:(int)height;
- (void)destroy;

@end
@interface VELPushNormalGLTexture : NSObject <VELPushGLTexture>
- (instancetype)initWithTexture:(GLuint)texture width:(int)width height:(int)height;
/// @param buffer buffer
- (instancetype)initWithBuffer:(unsigned char *)buffer width:(int)width height:(int)height format:(GLenum)format;
/// @param buffer buffer
- (void)update:(unsigned char *)buffer width:(int)width height:(int)height format:(GLenum)format;
- (void)updateTexture:(GLuint)texture width:(int)width height:(int)height;


@end
@interface VELPushPixelBufferGLTexture : NSObject <VELPushGLTexture>
/// @param textureCache cache
- (instancetype)initWithTextureCache:(CVOpenGLESTextureCacheRef)textureCache;
/// @param textureCache cache
- (instancetype)initWithWidth:(int)width height:(int)height textureCache:(CVOpenGLESTextureCacheRef)textureCache;
/// @param pixelBuffer CVPixelBuffer
/// @param textureCache cache
- (instancetype)initWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer textureCache:(CVOpenGLESTextureCacheRef)textureCache;
/// @param pixelBuffer CVPixelBuffer
- (void)update:(CVPixelBufferRef)pixelBuffer;
- (CVPixelBufferRef)pixelBuffer;

@end

#endif /* VELPushGLTexture_h */
