//
//  MDProgressView.h
//  MDPlayerUIModule
//
//  Created by real on 2021/11/18.
//

@interface MDProgressView : UIView

@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

@property (nonatomic, assign) NSTimeInterval currentValue;

@property (nonatomic, assign) NSTimeInterval bufferValue;

@property (nonatomic, assign) NSTimeInterval totalValue;

@end
