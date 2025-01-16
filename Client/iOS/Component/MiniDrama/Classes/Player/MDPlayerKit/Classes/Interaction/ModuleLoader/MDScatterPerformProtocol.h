//
//  MDScatterPerformProtocol.h
//  MDPlayerKit
//

#ifndef MDScatterPerformProtocol_h
#define MDScatterPerformProtocol_h

NS_ASSUME_NONNULL_BEGIN

@protocol MDScatterPerformProtocol <NSObject>

/// The number of modules to load at once, default is 1
@property (nonatomic, assign) NSInteger loadCountPerTime;

@property (nonatomic, copy, nullable) void(^performBlock)(NSArray *objects, BOOL load);
/// enable , default no
@property (nonatomic, assign) BOOL enable;

- (void)loadObjects:(NSArray *)objects;

- (void)unloadObjects:(NSArray *)objects;

- (void)removeLoadObjects:(NSArray *)objects;

- (void)invalidate;

@end

NS_ASSUME_NONNULL_END

#endif /* MDScatterPerformProtocol_h */
