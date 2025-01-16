//
//  MDLPlayerLoadingView.h
//  

#import <UIKit/UIKit.h>

@protocol MDPlayerLoadingViewDataSource <NSObject>
/// 网速信息
- (NSString *)netWorkSpeedInfo;
@end


@protocol MDPlayerLoadingViewProtocol <NSObject>

- (void)startLoading;
- (void)stopLoading;

@optional
/// 是否正在loading
@property (nonatomic) BOOL isLoading;
/// 是否全屏
@property (nonatomic , assign) BOOL isFullScreen;
/// 是否loading网速提示,如果显示网速则不显示免流提示（兼容之前显示免流提示的逻辑），配置后会定时回调代理获取网速信息
@property (nonatomic, assign) BOOL showNetSpeedTip;
/// 刷新网速时间间隔，单位s，显示网速才会生效，默认1s
@property (nonatomic, assign) NSTimeInterval refreshNetSpeedTipTimeInternal;
/// 数据源代理
@property (nonatomic, weak) id<MDPlayerLoadingViewDataSource> dataSource;

/// 配置loading提示
/// @param text text
- (void)setLoadingText:(NSString *)text;

- (void)layoutOffsetCenterY:(CGFloat)y;

@end

@interface MDLPlayerLoadingView : UIView<MDPlayerLoadingViewProtocol>

@property (nonatomic) BOOL isLoading;

/// show net speed tip
@property (nonatomic, assign) BOOL showNetSpeedTip;

@end



