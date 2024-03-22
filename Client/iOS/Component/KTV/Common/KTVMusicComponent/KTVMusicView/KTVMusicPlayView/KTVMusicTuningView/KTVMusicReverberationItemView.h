//
//  KTVMusicReverberationItemView.h
//  veRTC_Demo
//
//  Created by on 2022/1/19.
//  
//

#import "BaseButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface KTVMusicReverberationItemView : BaseButton

@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, copy) NSString *message;

@property (nonatomic, copy) NSString *imageName;

@end

NS_ASSUME_NONNULL_END
