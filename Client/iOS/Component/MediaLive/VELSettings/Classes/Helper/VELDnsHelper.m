// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "VELDnsHelper.h"
#include <arpa/inet.h>


@interface VELDnsHelper ()
@property (nonatomic, strong) NSMutableDictionary *ipHost;
@property (nonatomic, strong) NSMutableDictionary *hostIpList;
@end
@implementation VELDnsHelper
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static VELDnsHelper *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
///
- (NSMutableDictionary *)ipHost {
    @synchronized (self) {
        if (!_ipHost) {
            _ipHost = [[NSMutableDictionary alloc] initWithCapacity:10];
        }
        return _ipHost;
    }
}

- (NSMutableDictionary *)hostIpList {
    @synchronized (self) {
        if (!_hostIpList) {
            _hostIpList = [[NSMutableDictionary alloc] initWithCapacity:10];
        }
        return _hostIpList;
    }
}

- (void)parse:(NSString *)hostName {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSArray *ips = [self parseHost:hostName];
        NSMutableDictionary *mapping = [NSMutableDictionary new];
        if (ips && ips.count > 0) {
            for (NSString *ip in ips) {
                mapping[ip] = hostName;
            }
        }
        @synchronized (self) {
            if (ips.count > 0) {
                [[self hostIpList] setObject:ips forKey:hostName];
            }
            if (mapping.count > 0) {
                [[self ipHost] addEntriesFromDictionary:mapping];
            }
        }
    });
}


- (NSArray<NSString *> *)parseHost:(NSString *)hostName {
    if (hostName.length == 0) {
        return @[];
    }
    if ([[self hostIpList].allKeys containsObject:hostName]) {
        return [[self hostIpList] objectForKey:hostName];
    }
    
    Boolean result;
    CFStringRef hostNameRef = CFStringCreateWithCString(kCFAllocatorDefault, [hostName UTF8String], kCFStringEncodingASCII);
    
    CFHostRef hostRef = CFHostCreateWithName(kCFAllocatorDefault, hostNameRef);
    result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL);
    CFArrayRef addresses = NULL;
    if (result == TRUE) {
        addresses = CFHostGetAddressing(hostRef, &result);
    }
    NSMutableArray * ret = [NSMutableArray new];
    if(result == TRUE) {
        struct sockaddr_in* remoteAddr;
        for(int i = 0; i < CFArrayGetCount(addresses); i++) {
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);
            
            if(remoteAddr != NULL) {
                char ip[16];
                strcpy(ip, inet_ntoa(remoteAddr->sin_addr));
                NSString * ipStr = [NSString stringWithCString:ip encoding:NSUTF8StringEncoding];
                if ([@"0.0.0.0" isEqualToString:ipStr]) {
                    continue;
                }
                [ret addObject:ipStr];
            }
        }
    }
    CFRelease(hostNameRef);
    CFRelease(hostRef);
    return ret;
}

+ (void)parse:(NSString *)hostName {
    [[self sharedInstance] parse:hostName];
}

+ (NSArray<NSString *> *)parseHost:(NSString *)hostName {
    return [[self sharedInstance] parseHost:hostName];
}

+ (NSDictionary<NSString *,NSString *> *)getCachedIpHost {
    @synchronized (self) {
        return [[self sharedInstance] ipHost].copy;
    }
}

+ (NSDictionary<NSString *,NSArray<NSString *> *> *)getCachedHostIpList {
    @synchronized (self) {
        return [[self sharedInstance] hostIpList].copy;
    }
}
@end
