#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <React/RCTLog.h>
#import <React/RCTRootView.h>

#import <TTSDKFramework/TTSDKFramework.h>

#define TIMEOUT_SECONDS 600
#define TEXT_TO_LOOK_FOR @"Welcome to React"

@interface VeLiveRnDemoTests : XCTestCase

@end

@interface Player : NSObject

@property (nonatomic, assign) float volume;

@end


@interface Foo : NSObject

@property (nonatomic, strong) Player* p;
@property (nonatomic, assign) float volume;

- (void) setVolume:(float)volume;

@end

@implementation Player: NSObject

@end

@implementation Foo

- (instancetype) init
{
  self = [super init];
  _p = [[Player alloc] init];
  return self;
}

- (void) setVolume:(float)volume
{
  _p.volume = volume;
}

- (float)volume {
  return _p.volume;
}

@end

@implementation VeLiveRnDemoTests

- (void)testSomething
{
  Foo* f = [[Foo alloc] init];
  NSNumber *val = [NSNumber numberWithDouble:0.332];
  
  [f setValue:val forKey:@"volume"];
//  [f setValue:@(3.2123f) forKey:@"volume"];
//  f.volume = 3.2f;
  NSLog(@"volume: %f", f.volume);
}

- (BOOL)findSubviewInView:(UIView *)view matching:(BOOL (^)(UIView *view))test
{
  if (test(view)) {
    return YES;
  }
  for (UIView *subview in [view subviews]) {
    if ([self findSubviewInView:subview matching:test]) {
      return YES;
    }
  }
  return NO;
}

- (void)testRendersWelcomeScreen
{
  UIViewController *vc = [[[RCTSharedApplication() delegate] window] rootViewController];
  NSDate *date = [NSDate dateWithTimeIntervalSinceNow:TIMEOUT_SECONDS];
  BOOL foundElement = NO;

  __block NSString *redboxError = nil;
#ifdef DEBUG
  RCTSetLogFunction(
      ^(RCTLogLevel level, RCTLogSource source, NSString *fileName, NSNumber *lineNumber, NSString *message) {
        if (level >= RCTLogLevelError) {
          redboxError = message;
        }
      });
#endif

  while ([date timeIntervalSinceNow] > 0 && !foundElement && !redboxError) {
    [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    [[NSRunLoop mainRunLoop] runMode:NSRunLoopCommonModes beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];

    foundElement = [self findSubviewInView:vc.view
                                  matching:^BOOL(UIView *view) {
                                    if ([view.accessibilityLabel isEqualToString:TEXT_TO_LOOK_FOR]) {
                                      return YES;
                                    }
                                    return NO;
                                  }];
  }

#ifdef DEBUG
  RCTSetLogFunction(RCTDefaultLogFunction);
#endif

  XCTAssertNil(redboxError, @"RedBox error: %@", redboxError);
  XCTAssertTrue(foundElement, @"Couldn't find element with text '%@' in %d seconds", TEXT_TO_LOOK_FOR, TIMEOUT_SECONDS);
}

@end
