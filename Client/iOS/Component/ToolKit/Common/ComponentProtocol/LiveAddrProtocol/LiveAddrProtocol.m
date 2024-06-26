// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
//

#import "LiveAddrProtocol.h"

@implementation LiveAddrProtocol

- (void)getRTMPAddr:(NSString *)taskID
              block:(void (^)(NSString *addr))block {
    NSObject<LiveAddrDelegate> *delegate = [[NSClassFromString(@"RTMPGenerator") alloc] init];

    if ([delegate respondsToSelector:@selector(protocol:getRTMPAddr:block:)]) {
        [delegate protocol:self getRTMPAddr:taskID block:block];
    }
}



@end
