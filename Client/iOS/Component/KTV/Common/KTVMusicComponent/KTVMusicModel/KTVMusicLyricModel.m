//
//  KTVMusicLyricModel.m
//  AFNetworking
//
//  Created by bytedance on 2022/11/21.
//

#import "KTVMusicLyricModel.h"

@implementation KTVMusicLyricModel

@end

@implementation KTVMusicLyricLineModel

- (CGFloat)calculateContentHeight:(UIFont *)font
                          content:(NSString *)content
                         maxWidth:(CGFloat)maxWidth {
    CGSize maxSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    NSDictionary *attributes = @{NSFontAttributeName : font};
    CGRect rect = [self.content boundingRectWithSize:maxSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil];
    CGFloat height = CGRectGetHeight(rect);
    return ceilf(height);
}

- (CGFloat)calculateContentWidth:(UIFont *)font content:(NSString *)content {
    CGSize size = [content sizeWithAttributes:@{NSFontAttributeName : font}];
    return ceilf(size.width);
}

- (CGFloat)calculateCurrentLrcProgress:(NSInteger)currentTime {
    NSInteger offsetTime = currentTime - self.beginTime;

    KTVMusicLyricWordModel *lastWordModel;
    NSInteger allWordDuration = 0;
    if (self.words.count > 0) {
        lastWordModel = self.words[self.words.count - 1];
        allWordDuration = lastWordModel.offset + lastWordModel.duration;
    }

    CGFloat progressAll = 0.f;

    if (offsetTime < allWordDuration) {
        for (int i = 0; i < self.words.count; i++) {
            KTVMusicLyricWordModel *wordModel = self.words[i];
            if (offsetTime >= wordModel.offset && offsetTime <= wordModel.offset + wordModel.duration) {
                CGFloat progressBefore = i / (CGFloat)self.words.count;
                CGFloat percent = 1 / (CGFloat)self.words.count;
                CGFloat progressCurrentWord = (offsetTime - wordModel.offset) / (CGFloat)wordModel.duration;
                progressAll = progressBefore + progressCurrentWord * percent;
                break;
            } else if (i < self.words.count - 1) {
                KTVMusicLyricWordModel *nextModel = self.words[i + 1];
                if (offsetTime > wordModel.offset + wordModel.duration && offsetTime < nextModel.offset) {
                    progressAll = (i + 1) / (CGFloat)self.words.count;
                }
            }
        }
    } else {
        progressAll = 1.f;
    }
    return progressAll;
}

@end

@implementation KTVMusicLyricWordModel


@end
