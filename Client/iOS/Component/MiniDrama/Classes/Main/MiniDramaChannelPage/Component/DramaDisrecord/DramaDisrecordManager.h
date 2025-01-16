//
//  DramaDisrecordManager.h
//  AFNetworking
//
//  Created by ByteDance on 2024/12/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DramaDisrecordManager : NSObject

+ (instancetype)sharedInstance;

+ (void)destroyUnit;

+ (BOOL)isOpenDisrecord;

- (void)showDisRecordView;

- (void)hideDisRecordView;


@end

NS_ASSUME_NONNULL_END
