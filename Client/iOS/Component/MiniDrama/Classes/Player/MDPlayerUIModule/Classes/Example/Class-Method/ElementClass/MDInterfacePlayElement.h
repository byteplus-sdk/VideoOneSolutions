//
//  MDInterfacePlayElement.h
//  MDPlayerUIModule
//
//  Created by real on 2021/12/28.
//

#import "MDInterfaceElementDescriptionImp.h"
#import "MDInterfaceElementProtocol.h"

extern NSString *const mdplayButtonId;

extern NSString *const mdplayGestureId;

@interface MDInterfacePlayElement : NSObject <MDInterfaceElementProtocol>

+ (MDInterfaceElementDescriptionImp *)playButton;

+ (MDInterfaceElementDescriptionImp *)playGesture;

@end


