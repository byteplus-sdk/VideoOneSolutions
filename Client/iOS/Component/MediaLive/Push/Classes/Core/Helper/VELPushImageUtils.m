// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPushImageUtils.h"
#import <Accelerate/Accelerate.h>
#import "VELPushGLTexture.h"
#import "VELPushGLRenderHelper.h"
#import <ToolKit/ToolKit.h>

static const int VEL_PUSH_TEXTURE_CACHE_NUM = 3;
static const int VEL_PUSH_MAX_MALLOC_CACHE = 3;

@implementation VELPushPixelBufferInfo
@end

@implementation VELPushImageBuffer
@end

@interface VELPushImageUtils () {
    int                             _textureIndex;
    NSMutableArray<id<VELPushGLTexture>> *_inputTextures;
    NSMutableArray<id<VELPushGLTexture>> *_outputTextures;
    BOOL                            _useCacheTexture;
    CVOpenGLESTextureCacheRef       _textureCache;
    
    NSMutableDictionary<NSNumber *, NSValue *> *_mallocDict;
    CVPixelBufferRef                _cachedPixelBuffer;
}

@property (nonatomic, readonly) CVOpenGLESTextureCacheRef textureCache;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSValue *> *pixelBufferPoolDict;
@property (nonatomic, strong) VELPushGLRenderHelper *renderHelper;
@property (nonatomic, strong) EAGLContext *oldGlContext;

@end

@implementation VELPushImageUtils

- (instancetype)init
{
    self = [super init];
    if (self) {
        _glContext = [[EAGLContext alloc] initWithAPI:(kEAGLRenderingAPIOpenGLES3)];
        _textureIndex = 0;
        _inputTextures = [NSMutableArray arrayWithCapacity:VEL_PUSH_TEXTURE_CACHE_NUM];
        _outputTextures = [NSMutableArray arrayWithCapacity:VEL_PUSH_TEXTURE_CACHE_NUM];
        _textureCache = nil;
        _useCacheTexture = YES;
        _mallocDict = [NSMutableDictionary dictionary];
    }
    return self;
}
- (void)beginCurrentContext {
    self.oldGlContext = [EAGLContext currentContext];
    if (self.oldGlContext != self.glContext) {
        [EAGLContext setCurrentContext:self.glContext];
    }
}

- (void)endCurrentContext {
    if (self.oldGlContext != nil && self.oldGlContext != self.glContext) {
        [EAGLContext setCurrentContext:self.oldGlContext];
    }
}

- (void)dealloc
{
    // release input/output texture
    if (_textureCache) {
        CVOpenGLESTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
    for (id<VELPushGLTexture> texture in _inputTextures) {
        [texture destroy];
    }
    [_inputTextures removeAllObjects];
    for (id<VELPushGLTexture> texture in _outputTextures) {
        [texture destroy];
    }
    [_outputTextures removeAllObjects];
    if (_textureCache) {
        CVOpenGLESTextureCacheFlush(_textureCache, 0);
        CFRelease(_textureCache);
        _textureCache = nil;
    }
    // release malloced memory
    for (NSValue *value in _mallocDict.allValues) {
        unsigned char *pointer = [value pointerValue];
        free(pointer);
        VOLogI(VOMediaLive,@"release malloced size");
    }
    [_mallocDict removeAllObjects];
    // release CVPixelBufferPool
    if (_cachedPixelBuffer != nil) {
        CVPixelBufferRelease(_cachedPixelBuffer);
    }
    for (NSValue *value in self.pixelBufferPoolDict.allValues) {
        CVPixelBufferPoolRef pool = [value pointerValue];
        CVPixelBufferPoolFlush(pool, kCVPixelBufferPoolFlushExcessBuffers);
        CVPixelBufferPoolRelease(pool);
    }
    [self.pixelBufferPoolDict removeAllObjects];
    self.pixelBufferPoolDict = nil;
}

- (VELPushPixelBufferGLTexture *)getOutputPixelBufferGLTextureWithWidth:(int)width height:(int)height format:(VELImageFormatType)format {
    if (format != VELImageFormatType_BGRA) {
        VOLogI(VOMediaLive,@"this method only supports VELImageFormatType_BRGA format, please use VELImageFormatType_BGRA");
        return nil;
    }
    
    while (_textureIndex >= _outputTextures.count) {
        [_outputTextures addObject:[[VELPushPixelBufferGLTexture alloc] initWithTextureCache:self.textureCache]];
    }
    
    id<VELPushGLTexture> _outputTexture = _outputTextures[_textureIndex];
    if (!_outputTexture || _outputTexture.type != VELImageFormatType_PIXEL_BUFFER_TEXTURE) {
        if (_outputTexture) {
            [_outputTexture destroy];
        }
        _outputTexture = [[VELPushPixelBufferGLTexture alloc] initWithWidth:width height:height textureCache:self.textureCache];
    }
    
    [_outputTexture updateWidth:width height:height];
    
    if (_useCacheTexture) {
        // If use pipeline, return last output texture if we can.
        // To resolve problems like size changed between two continuous frames
        int lastTextureIndex = (_textureIndex + VEL_PUSH_TEXTURE_CACHE_NUM - 1) % VEL_PUSH_TEXTURE_CACHE_NUM;
        if (_outputTextures.count > lastTextureIndex && _outputTextures[lastTextureIndex].available) {
            _outputTexture = _outputTextures[lastTextureIndex];
        }
    }
    return _outputTexture.available ? _outputTexture : nil;
}

- (void)setUseCachedTexture:(BOOL)useCache {
    _useCacheTexture = useCache;
    if (!useCache) {
        _textureIndex = 0;
    }
}

- (VELPushImageBuffer *)transforCVPixelBufferToBuffer:(CVPixelBufferRef)pixelBuffer outputFormat:(VELImageFormatType)outputFormat {
    VELPushImageBuffer *inputBuffer = [self live_getBufferFromCVPixelBuffer:pixelBuffer];
    return [self transforBufferToBuffer:inputBuffer outputFormat:outputFormat];
}

- (CVPixelBufferRef)transforCVPixelBufferToCVPixelBuffer:(CVPixelBufferRef)pixelBuffer outputFormat:(VELImageFormatType)outputFormat {
    if ([self getCVPixelBufferFormat:pixelBuffer] == outputFormat) {
        return pixelBuffer;
    }
    VELPushImageBuffer *inputBuffer = [self live_getBufferFromCVPixelBuffer:pixelBuffer];
    CVPixelBufferRef outputPixelBuffer = [self live_createCVPixelBufferWithWidth:inputBuffer.width height:inputBuffer.height format:outputFormat];
    if (!outputPixelBuffer) {
        return nil;
    }
    CVPixelBufferLockBaseAddress(outputPixelBuffer, 0);
    VELPushImageBuffer *outputBuffer = [self live_getBufferFromCVPixelBuffer:outputPixelBuffer];
    BOOL result = [self transforBufferToBuffer:inputBuffer outputBuffer:outputBuffer];
    CVPixelBufferUnlockBaseAddress(outputPixelBuffer, 0);
    if (result) {
        return outputPixelBuffer;
    }
    return nil;
}

- (CVPixelBufferRef)rotateCVPixelBuffer:(CVPixelBufferRef)pixelBuffer rotation:(int)rotation {
    if (rotation == 0) {
        return pixelBuffer;
    }
    
    VELPushPixelBufferInfo *info = [self getCVPixelBufferInfo:pixelBuffer];
    
    int outputWidth = info.width;
    int outputHeight = info.height;
    if (rotation % 180 == 90) {
        outputWidth = info.height;
        outputHeight = info.width;
    }
    CVPixelBufferRef outputPixelBuffer = [self live_createPixelBufferFromPool:[self getOsType:info.format] heigth:outputHeight width:outputWidth];
    
    VELPushImageBuffer *inputBuffer = [self live_getBufferFromCVPixelBuffer:pixelBuffer];
    VELPushImageBuffer *outputBuffer = [self live_getBufferFromCVPixelBuffer:outputPixelBuffer];
    
    BOOL ret = [self rotateBufferToBuffer:inputBuffer outputBuffer:outputBuffer rotation:rotation];
    if (!ret) {
        return nil;
    }
    return outputPixelBuffer;
}

- (CVPixelBufferRef)blendCVPixelBuffer:(CVPixelBufferRef)pixelBuffer blendColor:(UIColor *)color {
	if (color == nil) {
		return pixelBuffer;
	}
	
	VELPushPixelBufferInfo *info = [self getCVPixelBufferInfo:pixelBuffer];
	
	int outputWidth = info.width;
	int outputHeight = info.height;
	CVPixelBufferRef outputPixelBuffer = [self live_createPixelBufferFromPool:[self getOsType:info.format] heigth:outputHeight width:outputWidth];
	
	VELPushImageBuffer *inputBuffer = [self live_getBufferFromCVPixelBuffer:pixelBuffer];
	VELPushImageBuffer *outputBuffer = [self live_getBufferFromCVPixelBuffer:outputPixelBuffer];
	
	BOOL ret = [self blendBufferToBuffer:inputBuffer outputBuffer:outputBuffer blendColor:color];
	if (!ret) {
        CVPixelBufferRelease(outputPixelBuffer);
		return nil;
	}
	return outputPixelBuffer;
}

- (id<VELPushGLTexture>)transforCVPixelBufferToTexture:(CVPixelBufferRef)pixelBuffer {
    VELPushPixelBufferInfo *info = [self getCVPixelBufferInfo:pixelBuffer];
    if (info.format != VELImageFormatType_BGRA) {
        pixelBuffer = [self transforCVPixelBufferToCVPixelBuffer:pixelBuffer outputFormat:VELImageFormatType_BGRA];
        VOLogI(VOMediaLive,@"this method only supports BRGA format CVPixelBuffer, convert it to BGRA CVPixelBuffer internal");
    }
    
    if (_useCacheTexture) {
        _textureIndex = (_textureIndex + 1) % VEL_PUSH_TEXTURE_CACHE_NUM;
    } else {
        _textureIndex = 0;
    }
    
    while (_textureIndex >= _inputTextures.count) {
        [_inputTextures addObject:[[VELPushPixelBufferGLTexture alloc] initWithTextureCache:self.textureCache]];
    }
    
    id<VELPushGLTexture> texture = _inputTextures[_textureIndex];
    if (texture.type != VELImageFormatType_PIXEL_BUFFER_TEXTURE) {
        [texture destroy];
        texture = [[VELPushPixelBufferGLTexture alloc] initWithCVPixelBuffer:pixelBuffer textureCache:self.textureCache];
        _inputTextures[_textureIndex] = texture;
    } else {
        [(VELPushPixelBufferGLTexture *)texture update:pixelBuffer];
    }
    
    return texture;
}

- (CVPixelBufferRef)transforBufferToCVPixelBuffer:(VELPushImageBuffer *)buffer outputFormat:(VELImageFormatType)outputFormat {
    CVPixelBufferRef pixelBuffer = [self live_createCVPixelBufferWithWidth:buffer.width height:buffer.height format:outputFormat];
    if (pixelBuffer == nil) {
        return nil;
    }
    BOOL result = [self transforBufferToCVPixelBuffer:buffer pixelBuffer:pixelBuffer];
    if (result) {
        return pixelBuffer;
    }
    return nil;
}

- (BOOL)transforBufferToCVPixelBuffer:(VELPushImageBuffer *)buffer pixelBuffer:(CVPixelBufferRef)pixelBuffer {
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    VELPushImageBuffer *outputBuffer = [self live_getBufferFromCVPixelBuffer:pixelBuffer];
    BOOL result = [self transforBufferToBuffer:buffer outputBuffer:outputBuffer];
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return result;
}

- (VELPushImageBuffer *)transforBufferToBuffer:(VELPushImageBuffer *)inputBuffer outputFormat:(VELImageFormatType)outputFormat {
    if (inputBuffer.format == outputFormat) {
        return inputBuffer;
    }
    
    VELPushImageBuffer *buffer = nil;
    if ([self live_isRgba:outputFormat]) {
        if ([self live_isRgba:inputBuffer.format]) {
            buffer = [self allocBufferWithWidth:inputBuffer.width height:inputBuffer.height bytesPerRow:inputBuffer.bytesPerRow format:outputFormat];
        } else {
            buffer = [self allocBufferWithWidth:inputBuffer.width height:inputBuffer.height bytesPerRow:inputBuffer.width * 4 format:outputFormat];
        }
    } else if ([self live_isYuv420:outputFormat]) {
        if ([self live_isYuv420:inputBuffer.format]) {
            buffer = [self allocBufferWithWidth:inputBuffer.yWidth height:inputBuffer.yHeight bytesPerRow:inputBuffer.yBytesPerRow format:outputFormat];
        } else {
            buffer = [self allocBufferWithWidth:inputBuffer.width height:inputBuffer.height bytesPerRow:inputBuffer.bytesPerRow format:outputFormat];
        }
    }
    if (buffer == nil) {
        return nil;
    }
    BOOL result = [self transforBufferToBuffer:inputBuffer outputBuffer:buffer];
    if (result) {
        return buffer;
    }
    return nil;
}

- (BOOL)transforBufferToBuffer:(VELPushImageBuffer *)inputBuffer outputBuffer:(VELPushImageBuffer *)outputBuffer {
    if ([self live_isYuv420:outputBuffer.format]) {
        if ([self live_isRgba:inputBuffer.format]) {
            vImage_Buffer rgbaBuffer;
            rgbaBuffer.data = inputBuffer.buffer;
            rgbaBuffer.width = inputBuffer.width;
            rgbaBuffer.height = inputBuffer.height;
            rgbaBuffer.rowBytes = inputBuffer.bytesPerRow;
            vImage_Buffer yBuffer;
            yBuffer.data = outputBuffer.yBuffer;
            yBuffer.width = outputBuffer.yWidth;
            yBuffer.height = outputBuffer.yHeight;
            yBuffer.rowBytes = outputBuffer.yBytesPerRow;
            vImage_Buffer uvBuffer;
            uvBuffer.data = outputBuffer.uvBuffer;
            uvBuffer.width = outputBuffer.uvWidth;
            uvBuffer.height = outputBuffer.uvHeight;
            uvBuffer.rowBytes = outputBuffer.uvBytesPerRow;
            BOOL result = [self live_convertRgbaToYuv:&rgbaBuffer yBuffer:&yBuffer yuBuffer:&uvBuffer inputFormat:inputBuffer.format outputFormat:outputBuffer.format];
            return result;
        }
    } else if ([self live_isRgba:outputBuffer.format]) {
#define PROFILE_TEST false
#if PROFILE_TEST
        if (inputBuffer.format == outputBuffer.format) {
            unsigned char *from = inputBuffer.buffer, *to = outputBuffer.buffer;
            for (int i = 0; i < inputBuffer.height; i++) {
                memcpy(to, from, MIN(inputBuffer.bytesPerRow, outputBuffer.bytesPerRow));
                from += inputBuffer.bytesPerRow;
                to += outputBuffer.bytesPerRow;
            }
            return YES;
        }
#endif
        if ([self live_isRgba:inputBuffer.format]) {
            vImage_Buffer rgbaBuffer;
            rgbaBuffer.data = inputBuffer.buffer;
            rgbaBuffer.width = inputBuffer.width;
            rgbaBuffer.height = inputBuffer.height;
            rgbaBuffer.rowBytes = inputBuffer.bytesPerRow;
            vImage_Buffer bgraBuffer;
            bgraBuffer.data = outputBuffer.buffer;
            bgraBuffer.width = outputBuffer.width;
            bgraBuffer.height = outputBuffer.height;
            bgraBuffer.rowBytes = outputBuffer.bytesPerRow;
            BOOL result = [self live_convertRgbaToBgra:&rgbaBuffer outputBuffer:&bgraBuffer inputFormat:inputBuffer.format outputFormat:outputBuffer.format];
            return result;
        } else if ([self live_isYuv420:inputBuffer.format]) {
            vImage_Buffer yBuffer;
            yBuffer.data = inputBuffer.yBuffer;
            yBuffer.width = inputBuffer.yWidth;
            yBuffer.height = inputBuffer.yHeight;
            yBuffer.rowBytes = inputBuffer.yBytesPerRow;
            vImage_Buffer uvBuffer;
            uvBuffer.data = inputBuffer.uvBuffer;
            uvBuffer.width = inputBuffer.uvWidth;
            uvBuffer.height = inputBuffer.uvHeight;
            uvBuffer.rowBytes = inputBuffer.uvBytesPerRow;
            vImage_Buffer bgraBuffer;
            bgraBuffer.data = outputBuffer.buffer;
            bgraBuffer.width = outputBuffer.width;
            bgraBuffer.height = outputBuffer.height;
            bgraBuffer.rowBytes = outputBuffer.bytesPerRow;
            BOOL result = [self live_convertYuvToRgba:&yBuffer yvBuffer:&uvBuffer rgbaBuffer:&bgraBuffer inputFormat:inputBuffer.format outputFormat:outputBuffer.format];
            return result;
        }
    }
    return NO;
}

- (BOOL)rotateBufferToBuffer:(VELPushImageBuffer *)inputBuffer outputBuffer:(VELPushImageBuffer *)outputBuffer rotation:(int)rotation {
    if ([self live_isRgba:inputBuffer.format] && [self live_isRgba:outputBuffer.format]) {
        vImage_Buffer inputVBuffer;
        inputVBuffer.data = inputBuffer.buffer;
        inputVBuffer.width = inputBuffer.width;
        inputVBuffer.height = inputBuffer.height;
        inputVBuffer.rowBytes = inputBuffer.bytesPerRow;
        
        vImage_Buffer outputVBuffer;
        outputVBuffer.data = outputBuffer.buffer;
        outputVBuffer.width = outputBuffer.width;
        outputVBuffer.height = outputBuffer.height;
        outputVBuffer.rowBytes = outputBuffer.bytesPerRow;
        
        return [self live_rotateRgba:&inputVBuffer outputBuffer: &outputVBuffer rotation:rotation];
    }
    
    VOLogI(VOMediaLive,@"not support for format %ld to %ld", (long)inputBuffer.format, (long)outputBuffer.format);
    return NO;
}

- (BOOL)blendBufferToBuffer:(VELPushImageBuffer *)inputBuffer outputBuffer:(VELPushImageBuffer *)outputBuffer blendColor:(UIColor *)color {
	if ([self live_isRgba:inputBuffer.format] && [self live_isRgba:outputBuffer.format]) {
		vImage_Buffer inputVBuffer;
		inputVBuffer.data = inputBuffer.buffer;
		inputVBuffer.width = inputBuffer.width;
		inputVBuffer.height = inputBuffer.height;
		inputVBuffer.rowBytes = inputBuffer.bytesPerRow;
		
		vImage_Buffer outputVBuffer;
		outputVBuffer.data = outputBuffer.buffer;
		outputVBuffer.width = outputBuffer.width;
		outputVBuffer.height = outputBuffer.height;
		outputVBuffer.rowBytes = outputBuffer.bytesPerRow;
		
		return [self live_blendRgba:&inputVBuffer outputBuffer:&outputVBuffer blendColor:color];
	}
	
	VOLogI(VOMediaLive,@"not support for format %ld to %ld", (long)inputBuffer.format, (long)outputBuffer.format);
	return NO;
}
- (id<VELPushGLTexture>)transforBufferToTexture:(VELPushImageBuffer *)buffer {
    if (_useCacheTexture) {
        _textureIndex = (_textureIndex + 1) % VEL_PUSH_TEXTURE_CACHE_NUM;
    } else {
        _useCacheTexture = 0;
    }
    
    if (![self live_isRgba:buffer.format]) {
        buffer = [self transforBufferToBuffer:buffer outputFormat:VELImageFormatType_BGRA];
    }
    
    if (buffer == nil) {
        return nil;
    }
    
    while (_textureIndex >= _inputTextures.count) {
        [_inputTextures addObject:[[VELPushNormalGLTexture alloc] initWithBuffer:buffer.buffer width:buffer.width height:buffer.height format:[self getGlFormat:buffer.format]]];
    }
    id<VELPushGLTexture> texture = _inputTextures[_textureIndex];
    if (texture.type != VELImageFormatType_NORMAL_TEXTURE) {
        [texture destroy];
        texture = [[VELPushNormalGLTexture alloc] initWithBuffer:buffer.buffer width:buffer.width height:buffer.height format:[self getGlFormat:buffer.format]];
        _inputTextures[_textureIndex] = texture;
    } else {
        [(VELPushNormalGLTexture *)texture update:buffer.buffer width:buffer.width height:buffer.height format:[self getGlFormat:buffer.format]];
    }
    
    return texture;
}

- (UIImage *)transforBufferToUIImage:(VELPushImageBuffer *)buffer {
    if (![self live_isRgba:buffer.format]) {
        buffer = [self transforBufferToBuffer:buffer outputFormat:VELImageFormatType_BGRA];
    }
    
    if (buffer == nil) {
        return nil;
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithData(
                                                              NULL,
                                                              buffer.buffer,
                                                              buffer.height * buffer.bytesPerRow,
                                                              NULL);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo;
    if (buffer.format == VELImageFormatType_RGBA) {
        bitmapInfo = kCGBitmapByteOrderDefault|kCGImageAlphaLast;
    } else {
        bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaFirst;
    }
    CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
    
    CGImageRef imageRef = CGImageCreate(buffer.width,
                                        buffer.height,
                                        8,
                                        4 * 8,
                                        buffer.bytesPerRow,
                                        colorSpaceRef,
                                        bitmapInfo,
                                        provider,
                                        NULL,
                                        NO,
                                        renderingIntent);

    UIImage *uiImage = [UIImage imageWithCGImage:imageRef];
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpaceRef);
    CGImageRelease(imageRef);
    return uiImage;
}

- (VELImageFormatType)getCVPixelBufferFormat:(CVPixelBufferRef)pixelBuffer {
    OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
    return [self getFormatForOSType:type];
}

- (VELImageFormatType)getFormatForOSType:(OSType)type {
    switch (type) {
        case kCVPixelFormatType_32BGRA:
            return VELImageFormatType_BGRA;
        case kCVPixelFormatType_32RGBA:
            return VELImageFormatType_RGBA;
        case kCVPixelFormatType_420YpCbCr8BiPlanarFullRange:
            return VELImageFormatType_YUV420F;
        case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
            return VELImageFormatType_YUV420V;
        default:
            return VELImageFormatType_UNKNOW;
            break;
    }
}

- (OSType)getOsType:(VELImageFormatType)format {
    switch (format) {
        case VELImageFormatType_RGBA:
            return kCVPixelFormatType_32RGBA;
        case VELImageFormatType_BGRA:
            return kCVPixelFormatType_32BGRA;
        case VELImageFormatType_YUV420F:
            return kCVPixelFormatType_420YpCbCr8BiPlanarFullRange;
        case VELImageFormatType_YUV420V:
            return kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange;
        default:
            return kCVPixelFormatType_32BGRA;
            break;
    }
}

- (GLenum)getGlFormat:(VELImageFormatType)format {
    switch (format) {
        case VELImageFormatType_RGBA:
            return GL_RGBA;
        case VELImageFormatType_BGRA:
            return GL_BGRA;
        default:
            return GL_RGBA;
            break;
    }
}

- (VELPushPixelBufferInfo *)getCVPixelBufferInfo:(CVPixelBufferRef)pixelBuffer {
    int bytesPerRow = (int) CVPixelBufferGetBytesPerRow(pixelBuffer);
    int width = (int) CVPixelBufferGetWidth(pixelBuffer);
    int height = (int) CVPixelBufferGetHeight(pixelBuffer);
    size_t iTop, iBottom, iLeft, iRight;
    CVPixelBufferGetExtendedPixels(pixelBuffer, &iLeft, &iRight, &iTop, &iBottom);
    width = width + (int) iLeft + (int) iRight;
    height = height + (int) iTop + (int) iBottom;
    bytesPerRow = bytesPerRow + (int) iLeft + (int) iRight;
    
    VELPushPixelBufferInfo *info = [VELPushPixelBufferInfo new];
    info.format = [self getCVPixelBufferFormat:pixelBuffer];
    info.width = width;
    info.height = height;
    info.bytesPerRow = bytesPerRow;
    return info;
}

- (VELPushImageBuffer *)allocBufferWithWidth:(int)width height:(int)height bytesPerRow:(int)bytesPerRow format:(VELImageFormatType)format {
    VELPushImageBuffer *buffer = [[VELPushImageBuffer alloc] init];
    buffer.width = width;
    buffer.height = height;
    buffer.bytesPerRow = bytesPerRow;
    buffer.format = format;
    if ([self live_isRgba:format]) {
        buffer.buffer = [self live_mallocBufferWithSize:bytesPerRow * height * 4];
        return buffer;
    } else if ([self live_isYuv420:format]) {
        buffer.yBuffer = [self live_mallocBufferWithSize:bytesPerRow * height];
        buffer.yWidth = width;
        buffer.yHeight = height;
        buffer.yBytesPerRow = bytesPerRow;
        buffer.uvBuffer = [self live_mallocBufferWithSize:bytesPerRow * height / 2];
        buffer.uvWidth = width / 2;
        buffer.uvHeight = height / 2;
        buffer.uvBytesPerRow = bytesPerRow;
        return buffer;
    }
    return nil;
}

- (VELPushImageBuffer *)transforUIImageToBEBuffer:(UIImage *)image {
    int width = (int)CGImageGetWidth(image.CGImage);
    int height = (int)CGImageGetHeight(image.CGImage);
    int bytesPerRow = 4 * width;
    VELPushImageBuffer *buffer = [self allocBufferWithWidth:width height:height bytesPerRow:bytesPerRow format:VELImageFormatType_RGBA];

    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(buffer.buffer, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrderDefault);

    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image.CGImage);
    CGContextRelease(context);
    
    return buffer;
}

- (VELPushImageBuffer *)transforTextureToBEBuffer:(GLuint)texture width:(int)widht height:(int)height outputFormat:(VELImageFormatType)outputFormat {
    if (![self live_isRgba:outputFormat]) {
        VOLogI(VOMediaLive,@"only rgba support");
        return nil;
    }
    
    VELPushImageBuffer *buffer = [self allocBufferWithWidth:widht height:height bytesPerRow:widht * 4 format:outputFormat];
    [self.renderHelper textureToImage:texture withBuffer:buffer.buffer Width:widht height:height format:[self getGlFormat:outputFormat]];
    return buffer;
}

#pragma mark - private

- (BOOL)live_convertRgbaToBgra:(vImage_Buffer *)inputBuffer outputBuffer:(vImage_Buffer *)outputBuffer inputFormat:(VELImageFormatType)inputFormat outputFormat:(VELImageFormatType)outputFormat {
    if (![self live_isRgba:inputFormat] || ![self live_isRgba:outputFormat]) {
        return NO;
    }
    uint8_t map[4] = {0, 1, 2, 3};
    [self live_permuteMap:map format:inputFormat];
    [self live_permuteMap:map format:outputFormat];
    vImage_Error error = vImagePermuteChannels_ARGB8888(inputBuffer, outputBuffer, map, kvImageNoFlags);
    if (error != kvImageNoError) {
        VOLogI(VOMediaLive,@"live_transforRgbaToRgba error: %ld", error);
    }
    return error == kvImageNoError;
}

- (BOOL)live_rotateRgba:(vImage_Buffer *)inputBuffer outputBuffer:(vImage_Buffer *)outputBuffer rotation:(int)rotation {
    uint8_t map[4] = {255, 255, 255, 1};
    
    rotation = 360 - rotation;
    vImage_Error error = vImageRotate90_ARGB8888(inputBuffer, outputBuffer, (rotation / 90), map, kvImageNoFlags);
    if (error != kvImageNoError) {
        VOLogI(VOMediaLive,@"vImageRotate90_ARGB8888 error: %ld", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)live_blendRgba:(vImage_Buffer *)inputBuffer outputBuffer:(vImage_Buffer *)outputBuffer blendColor:(UIColor *)blendColor {
	CGColorRef color = blendColor.CGColor;
	__block vImage_Buffer b_buffer = {};
	
	b_buffer.height = inputBuffer->height;
	b_buffer.width = inputBuffer->width;
	b_buffer.rowBytes = inputBuffer->rowBytes;
	b_buffer.data = malloc(b_buffer.rowBytes * b_buffer.height);
	
	Pixel_8888 pixel_color = {0};
	const double *components = CGColorGetComponents(color);
	const size_t components_size = CGColorGetNumberOfComponents(color);
	if (components_size == 2) {
		pixel_color[0] = components[1] * 255;
	} else {
		pixel_color[0] = components_size == 3 ? 255 : components[3] * 255;
		pixel_color[1] = components[0] * 255;
		pixel_color[2] = components[1] * 255;
		pixel_color[3] = components[2] * 255;
	}
	vImage_Error b_ret = vImageBufferFill_ARGB8888(&b_buffer, pixel_color , kvImageNoFlags);
	if (b_ret != kvImageNoError) {
		free(b_buffer.data);
		VOLogI(VOMediaLive,@"vImageBufferFill_ARGB8888 error: %ld", b_ret);
		return NO;
	}
	b_ret = vImageAlphaBlend_ARGB8888(&b_buffer, inputBuffer, outputBuffer, kvImageNoFlags);
	if (b_ret != kvImageNoError) {
		free(b_buffer.data);
		VOLogI(VOMediaLive,@"vImageAlphaBlend_ARGB8888 error: %ld", b_ret);
		return NO;
	}
	free(b_buffer.data);
	return YES;
}
- (BOOL)live_convertRgbaToYuv:(vImage_Buffer *)inputBuffer yBuffer:(vImage_Buffer *)yBuffer yuBuffer:(vImage_Buffer *)uvBuffer inputFormat:(VELImageFormatType)inputFormat outputFormat:(VELImageFormatType)outputFormat {
    if (![self live_isRgba:inputFormat] || ![self live_isYuv420:outputFormat]) {
        return NO;
    }
    uint8_t map[4] = {1, 2, 3, 0};
    [self live_permuteMap:map format:inputFormat];
    vImage_YpCbCrPixelRange pixelRange;
    [self live_yuvPixelRange:&pixelRange format:outputFormat];
    
    vImageARGBType argbType = kvImageARGB8888;
    vImageYpCbCrType yuvType = kvImage420Yp8_CbCr8;
    vImage_ARGBToYpCbCr conversionInfo;
    vImage_Flags flags = kvImageNoFlags;
    
    vImage_Error error = vImageConvert_ARGBToYpCbCr_GenerateConversion(kvImage_ARGBToYpCbCrMatrix_ITU_R_601_4, &pixelRange, &conversionInfo, argbType, yuvType, flags);
    if (error != kvImageNoError) {
        VOLogI(VOMediaLive,@"vImageConvert_ARGBToYpCbCr_GenerateConversion error: %ld", error);
        return NO;
    }
    
    error = vImageConvert_ARGB8888To420Yp8_CbCr8(inputBuffer, yBuffer, uvBuffer, &conversionInfo, map, flags);
    if (error != kvImageNoError) {
        VOLogI(VOMediaLive,@"vImageConvert_ARGB8888To420Yp8_CbCr8 error: %ld", error);
        return NO;
    }
    
    return YES;
}

- (BOOL)live_convertYuvToRgba:(vImage_Buffer *)yBuffer yvBuffer:(vImage_Buffer *)uvBuffer rgbaBuffer:(vImage_Buffer *)rgbaBuffer inputFormat:(VELImageFormatType)inputFormat outputFormat:(VELImageFormatType)outputFormat {
    if (![self live_isYuv420:inputFormat] || ![self live_isRgba:outputFormat]) {
        return NO;
    }
    
    uint8_t map[4] = {1, 2, 3, 0};
    [self live_permuteMap:map format:outputFormat];
    vImage_YpCbCrPixelRange pixelRange;
    [self live_yuvPixelRange:&pixelRange format:inputFormat];
    
    vImageARGBType argbType = kvImageARGB8888;
    vImageYpCbCrType yuvType = kvImage420Yp8_CbCr8;
    vImage_YpCbCrToARGB conversionInfo;
    vImage_Flags flags = kvImageNoFlags;
    
    vImage_Error error = vImageConvert_YpCbCrToARGB_GenerateConversion(kvImage_YpCbCrToARGBMatrix_ITU_R_601_4, &pixelRange, &conversionInfo, yuvType, argbType, flags);
    if (error != kvImageNoError) {
        VOLogI(VOMediaLive,@"vImageConvert_YpCbCrToARGB_GenerateConversion error: %ld", error);
        return NO;
    }
    
    error = vImageConvert_420Yp8_CbCr8ToARGB8888(yBuffer, uvBuffer, rgbaBuffer, &conversionInfo, map, 255, flags);
    if (error != kvImageNoError) {
        VOLogI(VOMediaLive,@"vImageConvert_420Yp8_CbCr8ToARGB8888 error: %ld", error);
        return NO;
    }
    
    return YES;
}

- (VELPushImageBuffer *)live_getBufferFromCVPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    VELPushImageBuffer *buffer = [[VELPushImageBuffer alloc] init];
    VELPushPixelBufferInfo *info = [self getCVPixelBufferInfo:pixelBuffer];
    buffer.width = info.width;
    buffer.height = info.height;
    buffer.format = info.format;
    
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    if ([self live_isRgba:info.format]) {
        buffer.buffer = (unsigned char *)CVPixelBufferGetBaseAddress(pixelBuffer);
        buffer.bytesPerRow = (int)CVPixelBufferGetBytesPerRow(pixelBuffer);
    } else if ([self live_isYuv420:info.format]) {
        buffer.yBuffer = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        buffer.yBytesPerRow = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        buffer.uvBuffer = (unsigned char *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        buffer.uvBytesPerRow = (int)CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        
        buffer.yWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer, 0);
        buffer.yHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer, 0);
        buffer.uvWidth = (int)CVPixelBufferGetWidthOfPlane(pixelBuffer, 1);
        buffer.uvHeight = (int)CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return buffer;
}

- (BOOL)live_isRgba:(VELImageFormatType)format {
    return format == VELImageFormatType_RGBA || format == VELImageFormatType_BGRA;
}

- (BOOL)live_isYuv420:(VELImageFormatType)format {
    return format == VELImageFormatType_YUV420F || format == VELImageFormatType_YUV420V;
}

- (void)live_permuteMap:(uint8_t *)map format:(VELImageFormatType)format {
    int r = map[0], g = map[1], b = map[2], a = map[3];
    switch (format) {
        case VELImageFormatType_RGBA:
            map[0] = r;
            map[1] = g;
            map[2] = b;
            map[3] = a;
            break;
        case VELImageFormatType_BGRA:
            map[0] = b;
            map[1] = g;
            map[2] = r;
            map[3] = a;
        default:
            break;
    }
}

- (void)live_yuvPixelRange:(vImage_YpCbCrPixelRange *)pixelRange format:(VELImageFormatType)format {
    switch (format) {
        case VELImageFormatType_YUV420F:
            pixelRange->Yp_bias = 0;
            pixelRange->CbCr_bias = 128;
            pixelRange->YpRangeMax = 255;
            pixelRange->CbCrRangeMax = 255;
            pixelRange->YpMax = 255;
            pixelRange->YpMin = 0;
            pixelRange->CbCrMax = 255;
            pixelRange->CbCrMin = 0;
            break;
        case VELImageFormatType_YUV420V:
            pixelRange->Yp_bias = 16;
            pixelRange->CbCr_bias = 128;
            pixelRange->YpRangeMax = 235;
            pixelRange->CbCrRangeMax = 240;
            pixelRange->YpMax = 235;
            pixelRange->YpMin = 16;
            pixelRange->CbCrMax = 240;
            pixelRange->CbCrMin = 16;
            break;
        default:
            break;
    }
}

- (unsigned char *)live_mallocBufferWithSize:(int)size {
    NSNumber *key = [NSNumber numberWithInt:size];
    if ([[_mallocDict allKeys] containsObject:key]) {
        unsigned char *buffer = [_mallocDict[key] pointerValue];
        memset(buffer, 0, size);
        return buffer;
    }
    while (_mallocDict.count >= VEL_PUSH_MAX_MALLOC_CACHE) {
        [_mallocDict removeObjectForKey:[_mallocDict.allKeys firstObject]];
    }
    VOLogI(VOMediaLive,@"malloc size: %d", size);
    unsigned char *buffer = malloc(size * sizeof(unsigned char));
    memset(buffer, 0, size);
    _mallocDict[key] = [NSValue valueWithPointer:buffer];
    return buffer;
}

- (CVPixelBufferRef)live_createCVPixelBufferWithWidth:(int)width height:(int)height format:(VELImageFormatType)format {
    if (_cachedPixelBuffer != nil) {
		CVPixelBufferRelease(_cachedPixelBuffer);
		_cachedPixelBuffer = NULL;
//        VELPushPixelBufferInfo *info = [self getCVPixelBufferInfo:_cachedPixelBuffer];
//        if (info.format == format && info.width == width && info.height == height) {
//            return _cachedPixelBuffer;
//        } else {
//            CVBufferRelease(_cachedPixelBuffer);
//        }
    }
//    VOLogI(VOMediaLive,@"create CVPixelBuffer");
    CVPixelBufferRef pixelBuffer = [self live_createPixelBufferFromPool:[self getOsType:format] heigth:height width:width];
    _cachedPixelBuffer = pixelBuffer;
    return pixelBuffer;
}

- (CVPixelBufferRef)live_createPixelBufferFromPool:(OSType)type heigth:(int)height width:(int)width {
    NSString* key = [NSString stringWithFormat:@"%u_%d_%d", (unsigned int)type, height, width];
    CVPixelBufferPoolRef pixelBufferPool = NULL;
    NSValue *bufferPoolAddress = [self.pixelBufferPoolDict objectForKey:key];
    
    /// Means we have not allocate such a pool
    if (!bufferPoolAddress) {
        pixelBufferPool = [self live_createPixelBufferPool:type heigth:height width:width];
        bufferPoolAddress = [NSValue valueWithPointer:pixelBufferPool];
        [self.pixelBufferPoolDict setValue:bufferPoolAddress forKey:key];
    }else {
        pixelBufferPool = [bufferPoolAddress pointerValue];
    }
    
    CVPixelBufferRef buffer = NULL;
    CVReturn ret = CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &buffer);
    if (ret != kCVReturnSuccess) {
        VOLogI(VOMediaLive,@"CVPixelBufferCreate error: %d", ret);
        if (ret == kCVReturnInvalidPixelFormat) {
            VOLogI(VOMediaLive,@"only format BGRA and YUV420 can be used");
        }
    }
    return buffer;
}

- (CVPixelBufferPoolRef)live_createPixelBufferPool:(OSType)type heigth:(int)height width:(int)width {
    CVPixelBufferPoolRef pool = NULL;
    
    NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
    
    [attributes setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCVPixelBufferOpenGLCompatibilityKey];
    [attributes setObject:[NSNumber numberWithInt:type] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithInt:width] forKey: (NSString*)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithInt:height] forKey: (NSString*)kCVPixelBufferHeightKey];
    [attributes setObject:@(16) forKey:(NSString*)kCVPixelBufferBytesPerRowAlignmentKey];
    [attributes setObject:[NSDictionary dictionary] forKey:(NSString*)kCVPixelBufferIOSurfacePropertiesKey];
        
    CVReturn ret = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef)attributes, &pool);
    
    if (ret != kCVReturnSuccess){
        VOLogI(VOMediaLive,@"Create pixbuffer pool failed %d", ret);
        return NULL;
    }
    
    CVPixelBufferRef buffer;
    ret = CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &buffer);
    if (ret != kCVReturnSuccess){
        VOLogI(VOMediaLive,@"Create pixbuffer from pixelbuffer pool failed %d", ret);
        return NULL;
    }
	if (buffer != NULL) {
		CVPixelBufferRelease(buffer);
	}
    return pool;
}

#pragma mark - getter
- (CVOpenGLESTextureCacheRef)textureCache {
    if (!_textureCache) {
        EAGLContext *context = [EAGLContext currentContext];
        CVReturn ret = CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, context, NULL, &_textureCache);
        if (ret != kCVReturnSuccess) {
            VOLogI(VOMediaLive,@"create CVOpenGLESTextureCacheRef fail: %d", ret);
        }
    }
    return _textureCache;
}

- (NSMutableDictionary<NSString *,NSValue *> *)pixelBufferPoolDict {
    if (_pixelBufferPoolDict == nil) {
        _pixelBufferPoolDict = [NSMutableDictionary dictionary];
    }
    return _pixelBufferPoolDict;
}

- (VELPushGLRenderHelper *)renderHelper {
    if (_renderHelper) {
        return _renderHelper;
    }
    
    _renderHelper = [[VELPushGLRenderHelper alloc] init];
    return _renderHelper;
}


- (NSData *)dataOfYUV420Buffer:(CVPixelBufferRef)pixelBuffer
{
	OSStatus status = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
	if (kCVReturnSuccess != status){
		return nil;
	}
	uint8_t *pY = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
	uint8_t *pUV = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
	
	size_t width = CVPixelBufferGetWidth(pixelBuffer);
	size_t height = CVPixelBufferGetHeight(pixelBuffer);
	
	size_t strideY = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
	size_t strideUV  = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
	
	size_t len = width * height;
	uint8_t *pDestYUV420 = (uint8_t *)malloc(len * 3/2);
	
	uint8_t *pDestY = pDestYUV420;
	uint8_t *pDestU = pDestYUV420 + len;
	uint8_t *pDestV = pDestU + len / 4;
	if (width == strideY) {
		memcpy(pDestY, pY, len);
	} else {
		size_t offset = 0;
		size_t offsetSrc = 0;
		for (int i = 0; i < height; i++)
			{
			memcpy(pDestY + offset, pY + offsetSrc, width);
			offset += width;
			offsetSrc += strideY;
			}
	}
	for (int j = 0;j < height/2; j++)
		{
		for (int i = 0; i < width/2; i++)
			{
			*(pDestU++) = pUV[i * 2];
			*(pDestV++) = pUV[i * 2 + 1];
			}
		pUV += strideUV;
		}
	NSData *pixelData = [NSData dataWithBytesNoCopy:pDestYUV420 length:len * 3/2];
	
	CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
	return pixelData;
}

- (NSData *)dataOfRGBBuffer:(CVPixelBufferRef) pixelBuffer
{
	OSStatus status = CVPixelBufferLockBaseAddress(pixelBuffer, 0);
	if (kCVReturnSuccess != status){
		return nil;
	}
	//bgra
	//ffplay -pixel_format bgra -video_size 720x1280 origined.bgra
	const uint8_t* baseAddr = (uint8_t *)(CVPixelBufferGetBaseAddress(pixelBuffer));
	size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
	size_t height = CVPixelBufferGetHeight(pixelBuffer);
	size_t length = bytesPerRow * height;
	NSData *pixelData = [NSData dataWithBytes:baseAddr length:length];
	
	CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
	return pixelData;
}

//ffplay -f rawvideo -video_size 720x1280 1.bgra
- (NSData *)dataOfPixelBuffer:(CVPixelBufferRef)pixelBuffer {
	OSType fmt = CVPixelBufferGetPixelFormatType(pixelBuffer);
	if (fmt == kCVPixelFormatType_420YpCbCr8BiPlanarFullRange ||
		fmt == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
		return [self dataOfYUV420Buffer:pixelBuffer];
	} else {
		return [self dataOfRGBBuffer:pixelBuffer];
	}
}


@end
