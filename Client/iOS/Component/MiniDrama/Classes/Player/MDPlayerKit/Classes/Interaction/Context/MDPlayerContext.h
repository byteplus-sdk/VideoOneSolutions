//
//  MDPlayerContext.h
//  MDPlayerKit
//

#import <Foundation/Foundation.h>
#import "MDPlayerContextInterface.h"
#import "MDPlayerContextDIInterface.h"

NS_ASSUME_NONNULL_BEGIN

#define MDPlayerContextDIBind(OBJECT, PROTOCOL, CONTEXT) ve_player_di_bind(OBJECT, @protocol(PROTOCOL), (MDPlayerContext *)CONTEXT);

#define MDPlayerContextDIUnBind(PROTOCOL, CONTEXT) ve_player_di_unbind(@protocol(PROTOCOL), (MDPlayerContext *)CONTEXT);

#define MDPlayerContextDILink(PROPERTY, PROTOCOL, CONTEXT) - (id<PROTOCOL>)PROPERTY { \
    if (!_##PROPERTY) { \
        _##PROPERTY = ve_playerLink_get_property(@protocol(PROTOCOL), (MDPlayerContext *)CONTEXT); \
    }\
    return _##PROPERTY;\
}

#define MDPlayerObserveKey(key,handler) MDPlayerContextObserveKey(self.context,key,handler)
#define MDPlayerObserveKeys(keys,handler) MDPlayerContextObserveKeys(self.context,keys,handler)
#define MDPlayerContextObserveKey(context,key,handler) MDPlayerObserveKeyFunction(context,key,self,handler)
#define MDPlayerContextObserveKeys(context,keys,handler) MDPlayerObserveKeysFunction(context,keys,self,handler)

/**
 * player context, after adding the listener through 'addKey', 
 * if the user sends a new object for this key through post, then notify each listening handler to receive the change.
 **/
@interface MDPlayerContext : NSObject

/// whether to store the Object carried by the event when sending the event, the default is YES.
@property(nonatomic, assign) BOOL enableStorageCache;

@end

@interface MDPlayerContext (Handler) <MDPlayerContextHandler>

@end

@interface MDPlayerContext (HandlerAdditions) <MDPlayerContextHandlerAdditions>

@end

@interface MDPlayerContext (DIService) <MDPlayerContextDIService>

@end

inline void ve_player_di_bind(NSObject *prop, Protocol *p, MDPlayerContext *context);
inline void ve_player_di_unbind(Protocol *p, MDPlayerContext *context);
inline id ve_playerLink_get_property(Protocol *p, MDPlayerContext *context);

inline id MDPlayerObserveKeyFunction(MDPlayerContext *context, NSString *key, NSObject *observer, MDPlayerContextHandler handler);
inline id MDPlayerObserveKeysFunction(MDPlayerContext *context, NSArray<NSString *> *keys, NSObject *observer, MDPlayerContextHandler handler);

NS_ASSUME_NONNULL_END
