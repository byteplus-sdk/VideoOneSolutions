//
//  NSObject+ToElementDescription.h
//  MDPlayerUIModule
//
//  Created by real on 2022/1/7.
//

#import "MDInterfaceElementDescriptionImp.h"

@interface NSObject (ToElementDescription)

- (MDInterfaceElementDescriptionImp *)elementDescription;

- (UIView *)viewOfElementIdentifier:(NSString *)identifier inGroup:(NSSet<UIView *> *)viewGroup;

@end

