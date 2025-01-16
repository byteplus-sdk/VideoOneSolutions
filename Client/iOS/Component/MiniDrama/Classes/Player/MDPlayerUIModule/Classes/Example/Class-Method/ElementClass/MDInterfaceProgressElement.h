//
//  MDInterfaceProgressElement.h
//  MDPlayerUIModule
//
//  Created by real on 2022/1/7.
//

#import "MDInterfaceElementDescriptionImp.h"
#import "MDInterfaceElementProtocol.h"

extern NSString *const mdprogressViewId;

extern NSString *const mdprogressGestureId;

@interface MDInterfaceProgressElement : NSObject <MDInterfaceElementProtocol>

+ (MDInterfaceElementDescriptionImp *)progressView;

+ (MDInterfaceElementDescriptionImp *)progressGesture;

@end
