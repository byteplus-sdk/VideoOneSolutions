// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushGLTexture.h"
#import <OpenGLES/EAGL.h>
#import <ToolKit/ToolKit.h>

@implementation VELPushNormalGLTexture {
    
}

@synthesize texture = _texture;
@synthesize type = _type;
@synthesize available = _available;
@synthesize width = _width;
@synthesize height = _height;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = VELImageFormatType_NORMAL_TEXTURE;
    }
    return self;
}

- (instancetype)initWithWidth:(int)width height:(int)height {
    if (self = [super init]) {
        _type = VELImageFormatType_NORMAL_TEXTURE;
        glGenTextures(1, &_texture);
        [self update:nil width:width height:height format:GL_RGBA];
    }
    return self;
}

- (instancetype)initWithBuffer:(unsigned char *)buffer width:(int)width height:(int)height format:(GLenum)format {
    if (self = [super init]) {
        _type = VELImageFormatType_NORMAL_TEXTURE;
        glGenTextures(1, &_texture);
        [self update:buffer width:width height:height format:format];
    }
    return self;
}

- (instancetype)initWithTexture:(GLuint)texture width:(int)width height:(int)height {
    if (self = [super init]) {
        [self updateTexture:texture width:width height:height];
    }
    return self;
}

- (void)updateWidth:(int)width height:(int)height {
    [self update:nil width:width height:height format:GL_RGBA];
}

- (void)update:(unsigned char *)buffer width:(int)width height:(int)height format:(GLenum)format {
    if (!glIsTexture(_texture)) {
        VOLogE(VOMediaLive,@"error: not a valid texture %d", _texture);
        _available = NO;
        return;
    }
    glBindTexture(GL_TEXTURE_2D, _texture);
    if (_width == width && _height == height) {
        glTexSubImage2D(GL_TEXTURE_2D, 0, 0, 0, width, height, format, GL_UNSIGNED_BYTE, buffer);
    } else {
        _width = width;
        _height = height;
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, format, GL_UNSIGNED_BYTE, buffer);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
    glBindTexture(GL_TEXTURE_2D, 0);
    _available = YES;
}

- (void)updateTexture:(GLuint)texture width:(int)width height:(int)height {
    if (glIsTexture(_texture)) {
        glDeleteTextures(1, &_texture);
    }
    
    _texture = texture;
    _width = width;
    _height = height;
    _available = YES;
}

- (void)destroy {
    if (glIsTexture(_texture)) {
        glDeleteTextures(1, &_texture);
    }
    _available = NO;
}

@end

@implementation VELPushPixelBufferGLTexture {
    CVOpenGLESTextureRef        _cvTexture;
    CVPixelBufferRef            _pixelBuffer;
    BOOL                        _needReleasePixelBuffer;
    CVOpenGLESTextureCacheRef   _textureCache;
    BOOL                        _needReleaseTextureCache;
}

@synthesize texture = _texture;
@synthesize type = _type;
@synthesize available = _available;
@synthesize width = _width;
@synthesize height = _height;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _type = VELImageFormatType_PIXEL_BUFFER_TEXTURE;
    }
    return self;
}

- (instancetype)initWithTextureCache:(CVOpenGLESTextureCacheRef)textureCache {
    self = [super init];
    if (self) {
        _type = VELImageFormatType_PIXEL_BUFFER_TEXTURE;
        _textureCache = textureCache;
        _needReleaseTextureCache = NO;
    }
    return self;
}

- (instancetype)initWithWidth:(int)width height:(int)height {
    if (self = [super init]) {
        _type = VELImageFormatType_PIXEL_BUFFER_TEXTURE;
        [self update:[self createPxielBuffer:width height:height]];
    }
    return self;
}

- (instancetype)initWithWidth:(int)width height:(int)height textureCache:(CVOpenGLESTextureCacheRef)textureCache {
    if (self = [super init]) {
        _textureCache = textureCache;
        _needReleaseTextureCache = NO;
        _type = VELImageFormatType_PIXEL_BUFFER_TEXTURE;
        [self update:[self createPxielBuffer:width height:height]];
    }
    return self;
}

- (instancetype)initWithCVPixelBuffer:(CVPixelBufferRef)pixelBuffer textureCache:(CVOpenGLESTextureCacheRef)textureCache {
    if (self = [super init]) {
        _textureCache = textureCache;
        _needReleaseTextureCache = NO;
        _type = VELImageFormatType_PIXEL_BUFFER_TEXTURE;
        [self update:pixelBuffer];
    }
    return self;
}

- (CVPixelBufferRef)createPxielBuffer:(int)width height:(int)height {
    CVPixelBufferRef pixelBuffer;
    const void *keys[] = {
        kCVPixelBufferOpenGLCompatibilityKey,
        kCVPixelBufferIOSurfacePropertiesKey
    };
    const void *values[] = {
        (__bridge const void *)([NSNumber numberWithBool:YES]),
        (__bridge const void *)([NSDictionary dictionary])
    };
    
    CFDictionaryRef optionsDicitionary = CFDictionaryCreate(kCFAllocatorDefault, keys, values, 2, NULL, NULL);
    
    CVReturn res = CVPixelBufferCreate(kCFAllocatorDefault, width, height, kCVPixelFormatType_32BGRA, optionsDicitionary, &pixelBuffer);
    CFRelease(optionsDicitionary);
    if (res != kCVReturnSuccess) {
        VOLogE(VOMediaLive,@"CVPixelBufferCreate error: %d", res);
        if (res == kCVReturnInvalidPixelFormat) {
            VOLogE(VOMediaLive,@"only format BGRA and YUV420 can be used");
        }
        _available = NO;
    }
    _available = YES;
    _needReleasePixelBuffer = YES;
    return pixelBuffer;
}

- (void)updateWidth:(int)width height:(int)height {
    if (_width != width || _height != height) {
        [self destroy];
        
        [self update:[self createPxielBuffer:width height:height]];
    }
}

- (void)update:(CVPixelBufferRef)pixelBuffer {
    if (_pixelBuffer && _needReleasePixelBuffer) {
        _needReleasePixelBuffer = NO;
        CVPixelBufferRelease(_pixelBuffer);
    }
    if (pixelBuffer == nil) {
        _available = NO;
        return;
    }
    if (!_textureCache) {
        _needReleaseTextureCache = YES;
        EAGLContext *context = [EAGLContext currentContext];
        CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, context, NULL, &_textureCache);
        if (ret != kCVReturnSuccess) {
            VOLogE(VOMediaLive,@"create CVOpenGLESTextureCacheRef fail: %d", ret);
            _available = NO;
            return;
        }
    }
    
    if (_cvTexture) {
        CFRelease(_cvTexture);
        _cvTexture = nil;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    int bytesPerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    int width = (int) CVPixelBufferGetWidth(pixelBuffer);
    int height = (int) CVPixelBufferGetHeight(pixelBuffer);
    size_t iTop, iBottom, iLeft, iRight;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    width = width + (int) iLeft + (int) iRight;
    height = height + (int) iTop + (int) iBottom;
    bytesPerRow = bytesPerRow + (int) iLeft + (int) iRight;
    CVReturn ret = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, width, height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &_cvTexture);
    if (ret != kCVReturnSuccess || !_cvTexture) {
        VOLogE(VOMediaLive,@"create CVOpenGLESTextureRef fail: %d", ret);
        _available = NO;
        return;
    }
    
    _width = width;
    _height = height;
    _pixelBuffer = pixelBuffer;
    _texture = CVOpenGLESTextureGetName(_cvTexture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glBindTexture(GL_TEXTURE_2D, 0);
    _available = YES;
}

- (CVPixelBufferRef)pixelBuffer {
    return _pixelBuffer;
}

- (void)destroy {
    if (_cvTexture) {
        CFRelease(_cvTexture);
        _cvTexture = nil;
    }
    if (_pixelBuffer && _needReleasePixelBuffer) {
        VOLogI(VOMediaLive,@"release pixelBuffer %@", _pixelBuffer);
        _needReleasePixelBuffer = NO;
        CVPixelBufferRelease(_pixelBuffer);
        _pixelBuffer = nil;
    }
    if (_textureCache && _needReleaseTextureCache) {
        VOLogI(VOMediaLive,@"release CVTextureCache %@", _textureCache);
        CVOpenGLESTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
    _available = NO;
}

@end
