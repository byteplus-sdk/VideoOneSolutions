// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELPixelBufferManager.h"
#import "VELGLUtils.h"
FOUNDATION_EXTERN void vel_pixel_copy_plane(const uint8_t* src_y,
                                            int src_stride_y,
                                            uint8_t* dst_y,
                                            int dst_stride_y,
                                            int width,
                                            int height);
FOUNDATION_EXTERN void vel_pixel_set_plane(uint8_t* dst_y,
                                           int dst_stride_y,
                                           int width,
                                           int height,
                                           uint32_t value);
FOUNDATION_EXTERN void vel_pixel_swap_uv_plane_c(const uint8_t* src_uv,
                                                 int src_stride_uv,
                                                 uint8_t* dst_vu,
                                                 int dst_stride_vu,
                                                 int width,
                                                 int height);
FOUNDATION_EXTERN void vel_pixel_merge_uv_plane_c(const uint8_t* src_u,
                                                  int src_stride_u,
                                                  const uint8_t* src_v,
                                                  int src_stride_v,
                                                  uint8_t* dst_uv,
                                                  int dst_stride_uv,
                                                  int width,
                                                  int height);
@interface VELPixelBufferManager ()
@property (nonatomic, strong) NSRecursiveLock *lock;
@property(nonatomic, strong) NSMutableDictionary <NSString *,NSValue *> *pixelBufferPoolDict;
@end
@implementation VELPixelBufferManager
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VELPixelBufferManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (instancetype)init {
    if (self = [super init]) {
        self.pixelBufferPoolDict = [[NSMutableDictionary alloc] initWithCapacity:10];
        self.lock = [[NSRecursiveLock alloc] init];
    }
    return self;
}

+ (CVPixelBufferRef)fromImage:(UIImage *)image {
    return [[self sharedInstance] fromImage:image];
}

+ (CVPixelBufferRef)fromBGRAData:(NSData *)data width:(int)width height:(int)height {
    return [[self sharedInstance] fromBGRAData:data width:width height:height];
}

+ (CVPixelBufferRef)fromNV12Data:(NSData *)data width:(int)width height:(int)height {
    return [[self sharedInstance] fromNV12Data:data width:width height:height];
}

+ (CVPixelBufferRef)fromNV21Data:(NSData *)data width:(int)width height:(int)height {
    return [[self sharedInstance] fromNV21Data:data width:width height:height];
}

+ (CVPixelBufferRef)fromYUVData:(NSData *)data width:(int)width height:(int)height {
    return [[self sharedInstance] fromYUVData:data width:width height:height];
}

+ (CMSampleBufferRef)sampleBufferFromPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (!pixelBuffer) {
        return NULL;
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    CMSampleTimingInfo timing = {kCMTimeInvalid, kCMTimeInvalid, kCMTimeInvalid};
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    if (result != noErr) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return NULL;
    }
    
    CMSampleBufferRef sampleBuffer = NULL;
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    if (result != noErr || sampleBuffer == nil) {
        if(videoInfo) {
            CFRelease(videoInfo);
            videoInfo = nil;
        }
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        return nil;
    }
    if(videoInfo) {
        CFRelease(videoInfo);
        videoInfo = nil;
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    return sampleBuffer;
}

+ (void)releaseMemory {
    [[self sharedInstance] releaseMemory];
}

- (CVPixelBufferRef)fromImage:(UIImage *)image {
    CGImageRef imageRef = [self rotateImage:image];
    if (imageRef == NULL) {
        return NULL;
    }
    CGFloat imageHeight = CGImageGetHeight(imageRef);
    CGFloat imageWidth = CGImageGetWidth(imageRef);
    
    CVPixelBufferRef pixelBuffer = [self createPixelBuffer:kCVPixelFormatType_32BGRA heigth:imageHeight width:imageWidth];
    if (pixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *pxdata = CVPixelBufferGetBaseAddress(pixelBuffer);
        if (pxdata == NULL) {
            CVPixelBufferRelease(pixelBuffer);
            return NULL;
        }
        size_t dataSize = CVPixelBufferGetDataSize(pixelBuffer);
        memset(pxdata, 0, dataSize);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(imageRef);
        BOOL hasAlpha = !(alphaInfo == kCGImageAlphaNone ||
                          alphaInfo == kCGImageAlphaNoneSkipFirst ||
                          alphaInfo == kCGImageAlphaNoneSkipLast);
        uint32_t bitmapInfo = kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Host;
        if (!hasAlpha) {
            bitmapInfo = kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host;
        }
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer);
        CGContextRef context = CGBitmapContextCreate(pxdata, imageWidth, imageHeight, 8, bytesPerRow, colorSpace, bitmapInfo);
        NSParameterAssert(context);
        if (context == NULL) {
            CVPixelBufferRelease(pixelBuffer);
            return NULL;
        }
        CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), imageRef);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        
        CGColorSpaceRelease(colorSpace);
        CGImageRelease(imageRef);
        CGContextRelease(context);
    } else {
        CGImageRelease(imageRef);
    }
    
    return pixelBuffer;
}

- (CGFloat)getDegressForImageOrientation:(UIImageOrientation)orientation {
    switch (orientation) {
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:{
            return 0;
        }
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:{
            return 90.0;
        }
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:{
            return -90.0;
        }
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:{
            return 180.0;
        }
    }
    return 0;
}

- (BOOL)getMirroedForImageOrientation:(UIImageOrientation)orientation {
    switch (orientation) {
        case UIImageOrientationUp:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationDown: {
            return NO;
        }
        case UIImageOrientationUpMirrored:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        case UIImageOrientationDownMirrored:{
            return YES;
        }
    }
    return NO;
}

- (CGImageRef)rotateImage:(UIImage *)image {
    CGImageRef imageRef = image.CGImage;
    if (imageRef == NULL) {
        return NULL;
    }
    UIImageOrientation orientation = image.imageOrientation;
    CGFloat degreesToRotate = [self getDegressForImageOrientation:orientation];
    BOOL mirrored = [self getMirroedForImageOrientation:orientation];
    BOOL swapWidthHeight = ((int)ceil(degreesToRotate) / 90) % 2 != 0;
    
    CGFloat originImageWidth = CGImageGetWidth(imageRef);
    CGFloat originImageHeight = CGImageGetHeight(imageRef);
    
    CGFloat imageWidth = originImageWidth;
    CGFloat imageHeight = originImageHeight;
    CGFloat radians = degreesToRotate * M_PI / 180.0;
    
    if (swapWidthHeight) {
        imageWidth = originImageHeight;
        imageHeight = originImageWidth;
    }
    
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    uint32_t bitmapInfo = CGImageGetBitmapInfo(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    
    CGContextRef context = CGBitmapContextCreate(nil, imageWidth, imageHeight, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    if (context == NULL) {
        return NULL;
    }
    CGContextTranslateCTM(context, imageWidth * 0.5, imageHeight * 0.5);
    if (mirrored) {
        CGContextScaleCTM(context, -1.0, -1.0);
    }
    CGContextRotateCTM(context, radians);
    
    if (swapWidthHeight) {
        CGContextTranslateCTM(context, -imageHeight * 0.5, -imageWidth * 0.5);
    } else {
        CGContextTranslateCTM(context, -imageWidth * 0.5, -imageHeight * 0.5);
    }
    CGContextDrawImage(context, CGRectMake(0, 0, originImageWidth, originImageHeight), imageRef);
    CGImageRef imgRef = CGBitmapContextCreateImage(context);
    CGContextRelease(context);
    return imgRef;
}


- (CVPixelBufferRef)fromBGRAData:(NSData *)data width:(int)width height:(int)height {
    CVPixelBufferRef pixelBuffer = [self createPixelBuffer:kCVPixelFormatType_32BGRA heigth:height width:width];
    if (pixelBuffer) {
        CVPixelBufferLockBaseAddress(pixelBuffer,0);
        uint8_t *yDestPlane = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
        size_t destHeight = CVPixelBufferGetHeight(pixelBuffer);
        size_t destStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
        vel_pixel_copy_plane(data.bytes, width * 4, yDestPlane, (int)destStride, width * 4, (int)MIN(destHeight, height));
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
    return pixelBuffer;
}

- (CVPixelBufferRef)fromNV12Data:(NSData *)data width:(int)width height:(int)height {
    return [self createYUVCVPixelWithBuffer:data.bytes
                                       type:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                                      width:width
                                     height:height];
}

- (CVPixelBufferRef)fromNV21Data:(NSData *)data width:(int)width height:(int)height {
    uint8_t *dstBuffer = (uint8_t *)malloc(data.length);
    memcpy(dstBuffer, data.bytes, data.length);
    uint8_t *srcBuffer = (uint8_t *)data.bytes;
    int yBufferLen = width * height;
    vel_pixel_swap_uv_plane_c(srcBuffer + yBufferLen, width,
                              dstBuffer + yBufferLen, width,
                              width, height * 0.5);
    CVPixelBufferRef pixelBuffer = [self createYUVCVPixelWithBuffer:dstBuffer
                                                               type:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                                                              width:width
                                                             height:height];
    free(dstBuffer);
    return pixelBuffer;
}

- (CVPixelBufferRef)fromYUVData:(NSData *)data width:(int)width height:(int)height {
    uint8_t *dstBuffer = (uint8_t *)malloc(data.length);
    memcpy(dstBuffer, data.bytes, data.length);
    uint8_t *srcBuffer = (uint8_t *)data.bytes;
    vel_pixel_copy_plane(srcBuffer, width,
                         dstBuffer, width,
                         width, height);
    int yBufferLen = width * height;
    int uBufferLen = (yBufferLen + 1) * 0.25;
    uint8_t *src_u = srcBuffer + yBufferLen;
    uint8_t *src_v = src_u + uBufferLen;
    int stride_u_v = (width + 1) * 0.5;
    vel_pixel_merge_uv_plane_c(src_u, stride_u_v,
                               src_v, stride_u_v,
                               dstBuffer + yBufferLen, width,
                               (width + 1) * 0.5, (height + 1) * 0.5);
    CVPixelBufferRef pixelBuffer = [self createYUVCVPixelWithBuffer:dstBuffer
                                                               type:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange
                                                              width:width
                                                             height:height];
    free(dstBuffer);
    return pixelBuffer;
}

- (void)releaseMemory {
    if ([self.lock tryLock]) {
        NSDictionary <NSString *, NSValue *>*bufferPool = self.pixelBufferPoolDict.copy;
        [self.pixelBufferPoolDict removeAllObjects];
        [bufferPool enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSValue * _Nonnull obj, BOOL * _Nonnull stop) {
            CVPixelBufferPoolRef pixelBufferPool = (CVPixelBufferPoolRef)[obj pointerValue];
            CVPixelBufferPoolRelease(pixelBufferPool);
        }];
        [self.lock unlock];
    }
}


- (CVPixelBufferRef)createYUVCVPixelWithBuffer:(const uint8_t *)buffer type:(OSType)type width:(int)width height:(int)height {
    CVPixelBufferRef pixelBuffer = [self createPixelBuffer:type
                                                    heigth:height
                                                     width:width];
    if (pixelBuffer == NULL) {
        return NULL;
    }
    
    CVPixelBufferLockBaseAddress(pixelBuffer,0);
    
    int yBufferLen = width * height;
    int yBufferStride = width;
    int uvBufferLen = (yBufferLen + 1) * 0.5;
    
    size_t planeCount = CVPixelBufferGetPlaneCount(pixelBuffer);
    if (planeCount <= 0 || planeCount > 3) {
        CVPixelBufferUnlockBaseAddress(pixelBuffer,0);
        CVPixelBufferRelease(pixelBuffer);
        return NULL;
    }
    uint8_t *yDestPlane = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
    size_t yHeight = CVPixelBufferGetHeight(pixelBuffer);
    size_t yDestStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 0);
    vel_pixel_set_plane(yDestPlane, (int)yDestStride, width, (int)yHeight, 0);
    vel_pixel_copy_plane(buffer, yBufferStride,
                         yDestPlane, (int)yDestStride,
                         yBufferStride, (int)MIN(yHeight, height));
    int uvBufferStride = width;
    if (planeCount == 2) {
        size_t uvHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
        size_t uvDestStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        uint8_t *uvDestPlane = (uint8_t *) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        vel_pixel_set_plane(uvDestPlane, (int)uvDestStride, uvBufferStride, (int)uvHeight, 0);
        const uint8_t *uvBuffer = buffer + width * height;
        vel_pixel_copy_plane(uvBuffer, uvBufferStride,
                             uvDestPlane, (int)uvDestStride,
                             uvBufferStride, (int)MIN(uvHeight, height));
    } else {
        int uBufferHeight = (height + 1) * 0.5;
        int uBufferLen = (uvBufferLen + 1) * 0.5;
        int uBufferStride = (width + 1) * 0.5;
        size_t uHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 1);
        size_t uStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 1);
        uint8_t *uDestPlane = (uint8_t *) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
        vel_pixel_set_plane(uDestPlane, (int)uStride, uBufferStride, (int)uHeight, 0);
        const uint8_t *uBuffer = buffer + width * height;
        vel_pixel_copy_plane(uBuffer, uBufferStride,
                             uDestPlane, (int)uStride,
                             uBufferStride, (int)MIN(uHeight, uBufferHeight));
        
        int vBufferHeight = uBufferHeight;
        int vBufferStride = uBufferStride;
        size_t vHeight = CVPixelBufferGetHeightOfPlane(pixelBuffer, 2);
        size_t vStride = CVPixelBufferGetBytesPerRowOfPlane(pixelBuffer, 2);
        uint8_t *vDestPlane = (uint8_t *) CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 2);
        vel_pixel_set_plane(vDestPlane, (int)vStride, vBufferStride, (int)vHeight, 0);
        const uint8_t *vBuffer = uBuffer + uBufferLen;
        vel_pixel_copy_plane(vBuffer, vBufferStride,
                             vDestPlane, (int)vStride,
                             vBufferStride, (int)MIN(vHeight, vBufferHeight));
    }
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    
    return pixelBuffer;
}

- (CVPixelBufferRef)createPixelBuffer:(OSType)type heigth:(int)height width:(int)width {
    CVPixelBufferRef buffer = [self createPixelBufferFromPool:type heigth:height width:width];
    if (buffer == NULL) {
        buffer = [self createPixelBufferNormalWithType:type heigth:height width:width];
    }
    return buffer;
}

- (CVPixelBufferRef)createPixelBufferFromPool:(OSType)type heigth:(int)height width:(int)width {
    
    NSString *poolKey = [NSString stringWithFormat:@"%u_%d_%d", (unsigned int)type, height, width];
    CVPixelBufferPoolRef pixelBufferPool = NULL;
    CVPixelBufferRef buffer = NULL;
    
    if ([self.lock tryLock]) {
        NSValue *bufferPoolAddress = [self.pixelBufferPoolDict objectForKey:poolKey];
        if (!bufferPoolAddress) {
            pixelBufferPool = [self createPixelBufferPool:type heigth:height width:width];
            if (pixelBufferPool != NULL) {
                bufferPoolAddress = [NSValue valueWithPointer:pixelBufferPool];
                [self.pixelBufferPoolDict setValue:bufferPoolAddress forKey:poolKey];
            }
        } else {
            pixelBufferPool = (CVPixelBufferPoolRef)[bufferPoolAddress pointerValue];
        }
        [self.lock unlock];        
    }
    
    if (pixelBufferPool != NULL) {
        CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pixelBufferPool, &buffer);
        [self cleanPixelBuffer:buffer];
    }
    return buffer;
}

- (CVPixelBufferRef)createPixelBufferNormalWithType:(OSType)type heigth:(int)height width:(int)width {
    NSDictionary *attributes = [self getPixelBufferAttributes:type heigth:height width:width];
    CVPixelBufferRef pixelBuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, type, (__bridge CFDictionaryRef)attributes, &pixelBuffer);
    if (status != kCVReturnSuccess) {
        return NULL;
    }
    [self cleanPixelBuffer:pixelBuffer];
    return pixelBuffer;
}

- (void)cleanPixelBuffer:(CVPixelBufferRef)pixelBuffer {
    if (pixelBuffer != NULL) {
        CVPixelBufferLockBaseAddress(pixelBuffer, 0);
        void *pxdata = CVPixelBufferGetBaseAddress(pixelBuffer);
        size_t dataSize = CVPixelBufferGetDataSize(pixelBuffer);
        memset(pxdata, 0, dataSize);
        CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    }
}

- (CVPixelBufferPoolRef)createPixelBufferPool:(OSType)type heigth:(int)height width:(int)width {
    CVPixelBufferPoolRef pool = NULL;
    
    NSDictionary *attributes = [self getPixelBufferAttributes:type heigth:height width:width];
    
    CVReturn ret = CVPixelBufferPoolCreate(kCFAllocatorDefault, NULL, (__bridge CFDictionaryRef)attributes, &pool);
    
    if (ret != kCVReturnSuccess){
        return NULL;
    }
    
    CVPixelBufferRef buffer = NULL;
    ret = CVPixelBufferPoolCreatePixelBuffer(NULL, pool, &buffer);
    if (ret != kCVReturnSuccess){
        return NULL;
    }
    if (buffer != NULL) {
        CVPixelBufferRelease(buffer);
    }
    return pool;
}

- (NSDictionary *)getPixelBufferAttributes:(OSType)type heigth:(int)height width:(int)width {
    NSMutableDictionary* attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[NSNumber numberWithBool:YES] forKey:(__bridge NSString *)kCVPixelBufferOpenGLCompatibilityKey];
    [attributes setObject:[NSNumber numberWithBool:YES] forKey:(__bridge NSString *)kCVPixelBufferCGImageCompatibilityKey];
    [attributes setObject:[NSNumber numberWithBool:YES] forKey:(__bridge NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey];
    [attributes setObject:[NSNumber numberWithInt:64] forKey:(__bridge NSString *)kCVPixelBufferBytesPerRowAlignmentKey];
    [attributes setObject:[NSNumber numberWithInt:type] forKey:(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey];
    [attributes setObject:[NSNumber numberWithInt:width] forKey:(__bridge NSString *)kCVPixelBufferWidthKey];
    [attributes setObject:[NSNumber numberWithInt:height] forKey:(__bridge NSString *)kCVPixelBufferHeightKey];
    [attributes setObject:[NSDictionary dictionary] forKey:(__bridge NSString *)kCVPixelBufferIOSurfacePropertiesKey];
    return attributes;
}

@end
/// from yuv
void vel_pixel_copy_plane(const uint8_t* src_y,
                          int src_stride_y,
                          uint8_t* dst_y,
                          int dst_stride_y,
                          int width,
                          int height) {
    
    if (width <= 0 || height == 0) {
        return;
    }
    // Negative height means invert the image.
    if (height < 0) {
        height = -height;
        dst_y = dst_y + (height - 1) * dst_stride_y;
        dst_stride_y = -dst_stride_y;
    }
    // Coalesce rows.
    if (src_stride_y == width && dst_stride_y == width) {
        width *= height;
        height = 1;
        src_stride_y = dst_stride_y = 0;
    }
    // Nothing to do.
    if (src_y == dst_y && src_stride_y == dst_stride_y) {
        return;
    }
    for (int y = 0; y < height; ++y) {
        memcpy((void *)dst_y, (void *)src_y, width);
        src_y += src_stride_y;
        dst_y += dst_stride_y;
    }
};
void vel_pixel_set_plane(uint8_t* dst_y,
                         int dst_stride_y,
                         int width,
                         int height,
                         uint32_t value) {
    if (width <= 0 || height == 0) {
        return;
    }
    if (height < 0) {
        height = -height;
        dst_y = dst_y + (height - 1) * dst_stride_y;
        dst_stride_y = -dst_stride_y;
    }
    // Coalesce rows.
    if (dst_stride_y == width) {
        width *= height;
        height = 1;
        dst_stride_y = 0;
    }
    
    for (int y = 0; y < height; ++y) {
        memset(dst_y, value, width);
        dst_y += dst_stride_y;
    }
};
void vel_pixel_merge_uv_row_c(const uint8_t* src_u,
                              const uint8_t* src_v,
                              uint8_t* dst_uv,
                              int width) {
    for (int x = 0; x < width - 1; x += 2) {
        dst_uv[0] = src_u[x];
        dst_uv[1] = src_v[x];
        dst_uv[2] = src_u[x + 1];
        dst_uv[3] = src_v[x + 1];
        dst_uv += 4;
    }
    if (width & 1) {
        dst_uv[0] = src_u[width - 1];
        dst_uv[1] = src_v[width - 1];
    }
};
void vel_pixel_merge_uv_plane_c(const uint8_t* src_u,
                                int src_stride_u,
                                const uint8_t* src_v,
                                int src_stride_v,
                                uint8_t* dst_uv,
                                int dst_stride_uv,
                                int width,
                                int height) {
    if (width <= 0 || height == 0) {
        return;
    }
    if (height < 0) {
        height = -height;
        dst_uv = dst_uv + (height - 1) * dst_stride_uv;
        dst_stride_uv = -dst_stride_uv;
    }
    if (src_stride_u == width && src_stride_v == width &&
        dst_stride_uv == width * 2) {
        width *= height;
        height = 1;
        src_stride_u = src_stride_v = dst_stride_uv = 0;
    }
    for (int y = 0; y < height; ++y) {
        vel_pixel_merge_uv_row_c(src_u, src_v, dst_uv, width);
        src_u += src_stride_u;
        src_v += src_stride_v;
        dst_uv += dst_stride_uv;
    }
};
void vel_pixel_swap_row_c(const uint8_t* src_uv, uint8_t* dst_vu, int width) {
    for (int x = 0; x < width; ++x) {
        uint8_t u = src_uv[0];
        uint8_t v = src_uv[1];
        dst_vu[0] = v;
        dst_vu[1] = u;
        src_uv += 2;
        dst_vu += 2;
    }
};
void vel_pixel_swap_uv_plane_c(const uint8_t* src_uv,
                               int src_stride_uv,
                               uint8_t* dst_vu,
                               int dst_stride_vu,
                               int width,
                               int height) {
    if (width <= 0 || height == 0) {
        return;
    }
    // Negative height means invert the image.
    if (height < 0) {
        height = -height;
        src_uv = src_uv + (height - 1) * src_stride_uv;
        src_stride_uv = -src_stride_uv;
    }
    // Coalesce rows.
    if (src_stride_uv == width * 2 && dst_stride_vu == width * 2) {
        width *= height;
        height = 1;
        src_stride_uv = dst_stride_vu = 0;
    }
    for (int y = 0; y < height; ++y) {
        vel_pixel_swap_row_c(src_uv, dst_vu, width);
        src_uv += src_stride_uv;
        dst_vu += dst_stride_vu;
    }
};
