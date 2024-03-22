//
//  KTVSeatModel.h
//  veRTC_Demo
//
//  Created by on 2021/11/23.
//  
//

#import <Foundation/Foundation.h>
#import "KTVUserModel.h"

@interface KTVSeatModel : NSObject

/// status: 0 close, 1 open
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) KTVUserModel *userModel;

@end
