//
//  TTLiveModel.h
//  TTProtoTypeRoom
//
//  Created by ByteDance on 2024/9/5.
//

#import <Foundation/Foundation.h>
#import <YYModel/YYModel.h>


NS_ASSUME_NONNULL_BEGIN

@interface TTLiveModel : NSObject <YYModel>

@property (nonatomic, copy) NSString *appId;

@property (nonatomic, copy) NSString *roomId;

@property (nonatomic, copy) NSString *roomName;

@property (nonatomic, copy) NSString *hostName;

@property (nonatomic, copy) NSString  *roomDescription;

@property (nonatomic, copy) NSString *coverUrl;

@property (nonatomic, copy) NSString *hostUserId;

@property (nonatomic, copy) NSString *rtsToken;

@property (nonatomic, copy) NSDictionary *streamDic;

@end

NS_ASSUME_NONNULL_END