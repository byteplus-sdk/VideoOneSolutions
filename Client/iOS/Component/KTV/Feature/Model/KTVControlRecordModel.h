//
//  KTVControlRecordModel.h
//  SceneRTCDemo
//
//  Created by on 2021/3/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KTVControlRecordModel : NSObject

@property (nonatomic, copy) NSString *room_id;

@property (nonatomic, copy) NSString *download_url;

@property (nonatomic, assign) NSInteger created_at;

@end

NS_ASSUME_NONNULL_END
