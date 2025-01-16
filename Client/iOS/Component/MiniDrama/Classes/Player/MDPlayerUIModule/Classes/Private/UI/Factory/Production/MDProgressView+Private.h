//
//  MDProgressView+Private.h
//  MDPlayerUIModule
//
//  Created by real on 2021/11/18.
//

#import "MDProgressView.h"
@protocol MDInterfaceFactoryProduction;

@interface MDProgressView () <MDInterfaceFactoryProduction>

- (void)setAutoBackStartPoint:(BOOL)autoBackStartPoint;

@end
