//
//  MDPlayerContextMacros.h
//  MDPlayerKit
//

#ifndef MDPlayerContextMacros_h
#define MDPlayerContextMacros_h

typedef void(^MDPlayerContextHandler)(id _Nullable object, NSString * _Nullable key);

typedef id _Nullable (^MDPlayerContextObjectCreator)(void);

static inline void MDPlayerContextRunOnMainThread(void (^ _Nullable block)(void)) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

#endif /* MDPlayerContextMacros_h */
