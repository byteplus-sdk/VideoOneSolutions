// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import "MDPlayerContextItemHandler.h"
#import "BTDMacros.h"

@interface MDPlayerContextItemHandler ()

@property(nonatomic, copy, readwrite) NSArray<NSString *> *keys;

@property(nonatomic, copy) MDPlayerContextHandler handler;

@property(nonatomic, weak) id observer;

@property(nonatomic, assign) BOOL hasBindObserver;

@end

@implementation MDPlayerContextItemHandler

- (instancetype)initWithObserver:(id)observer keys:(NSArray<NSString *> *)keys handler:(MDPlayerContextHandler)handler {
    if (self = [super init]) {
        self.observer = observer;
        self.keys = keys;
        self.handler = handler;
        self.hasBindObserver = (nil != observer);
    }
    return self;
}

- (void)executeHandlerWithKey:(NSString *)key andValue:(id)value {
    if (BTD_isEmptyString(key)) {
        return;
    }
    if ((self.hasBindObserver && nil == self.observer) || nil == self.handler) {
        self.handler = nil;
        return;
    }
    !self.handler ?: self.handler(value, key);
}

@end
