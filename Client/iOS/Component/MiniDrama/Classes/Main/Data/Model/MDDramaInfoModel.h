//
//  MDDramaInfoModel.h
//  MDPlayModule
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * drama meta info for HomePage
 */
typedef NS_ENUM(NSInteger, MiniDramaVideoDisplayType) {
    MiniDramaVideoDisplayTypeVertical,
    MiniDramaVideoDisplayTypeHorizontal
};


@interface MDDramaInfoModel: NSObject<YYModel>

@property (nonatomic, copy) NSString *dramaId;
@property (nonatomic, copy) NSString *dramaTitle;
@property (nonatomic, assign) NSInteger dramaPlayTimes;
@property (nonatomic, copy) NSString *dramaCoverUrl;
@property (nonatomic, assign) NSInteger dramaLength;
@property (nonatomic, assign) BOOL newReleased;
@property (nonatomic, assign) MiniDramaVideoDisplayType dramaDisplayType;
@end

NS_ASSUME_NONNULL_END
