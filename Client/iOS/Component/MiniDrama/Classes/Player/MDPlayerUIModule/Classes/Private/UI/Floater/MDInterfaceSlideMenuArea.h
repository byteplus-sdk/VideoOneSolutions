//
//  MDInterfaceSlideMenuArea.h
//  MDPlayerUIModule
//
//  Created by real on 2021/9/24.
//

#import "MDInterfaceArea.h"
#import "MDInterfaceFloater.h"
#import "MDInterfaceElementDescription.h"

@interface MDInterfaceSlideMenuArea : MDInterfaceArea <MDInterfaceFloaterPresentProtocol>

- (void)fillElements:(NSArray<id<MDInterfaceElementDescription>> *)elements;

@end
