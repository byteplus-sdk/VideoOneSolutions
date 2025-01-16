//
//  MDPlayerLoadingModule.h
//  MDPlayerKit
//

#import "MDPlayerBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol MDPlayerLoadingViewProtocol;

@interface MDPlayerLoadingModule : MDPlayerBaseModule

@property (nonatomic, strong, readonly, nullable) UIView<MDPlayerLoadingViewProtocol> *loadingView;

- (UIView<MDPlayerLoadingViewProtocol> *)createLoadingView;

@end

NS_ASSUME_NONNULL_END
