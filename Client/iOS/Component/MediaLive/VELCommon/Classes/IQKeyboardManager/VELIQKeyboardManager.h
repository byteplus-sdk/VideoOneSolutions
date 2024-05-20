// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <CoreGraphics/CoreGraphics.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 Codeless drop-in universal library allows to prevent issues of keyboard sliding up and cover UITextField/UITextView. Neither need to write any code nor any setup required and much more. A generic version of KeyboardManagement. https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
 */
@interface VELIQKeyboardManager : NSObject


/**
 Enable/disable managing distance between keyboard and textField. Default is YES(Enabled when class loads in `+(void)load` method).
 */
@property(nonatomic, assign, getter = isEnabled) BOOL enable;

/**
 To set keyboard distance from textField. can't be less than zero. Default is 10.0.
 */
@property(nonatomic, assign) CGFloat keyboardDistanceFromTextField;

/**
 Refreshes textField/textView position if any external changes is explicitly made by user.
 */
- (void)reloadLayoutIfNeeded;

/** 
 Boolean to know if keyboard is showing.
 */
@property(nonatomic, assign, readonly, getter = isKeyboardShowing) BOOL  keyboardShowing;

/**
 moved distance to the top used to maintain distance between keyboard and textField. Most of the time this will be a positive value.
 */
@property(nonatomic, assign, readonly) CGFloat movedDistance;

/**
 Will be called then movedDistance will be changed.
 */
@property(nullable, nonatomic, copy) void (^movedDistanceChanged)(CGFloat movedDistance);


///-----------------------------------------------------------
/// @name UITextField/UITextView Next/Previous/Resign handling
///-----------------------------------------------------------

/**
 Resigns Keyboard on touching outside of UITextField/View. Default is NO.
 */
@property(nonatomic, assign) BOOL shouldResignOnTouchOutside;

/** TapGesture to resign keyboard on view's touch. It's a readonly property and exposed only for adding/removing dependencies if your added gesture does have collision with this one */
@property(nonnull, nonatomic, strong, readonly) UITapGestureRecognizer  *resignFirstResponderGesture;

/**
 Resigns currently first responder field.
 */
- (BOOL)resignFirstResponder;


///---------------------------
/// @name UIAnimation handling
///---------------------------

/**
 If YES, then calls 'setNeedsLayout' and 'layoutIfNeeded' on any frame update of to viewController's view.
 */
@property(nonatomic, assign) BOOL layoutIfNeededOnUpdate;

///---------------------------------------------
/// @name Class Level enabling/disabling methods
///---------------------------------------------

/**
 Disable distance handling within the scope of disabled distance handling viewControllers classes. Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController. Default is [UITableViewController, UIAlertController, _UIAlertControllerTextFieldViewController].
 */
@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *disabledDistanceHandlingClasses;

/**
 Enable distance handling within the scope of enabled distance handling viewControllers classes. Within this scope, 'enabled' property is ignored. Class should be kind of UIViewController. Default is [].
 */
@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *enabledDistanceHandlingClasses;

/**
 Disabled classes to ignore 'shouldResignOnTouchOutside' property, Class should be kind of UIViewController. Default is [UIAlertController, UIAlertControllerTextFieldViewController]
 */
@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *disabledTouchResignedClasses;

/**
 Enabled classes to forcefully enable 'shouldResignOnTouchOutsite' property. Class should be kind of UIViewController. Default is [].
 */
@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *enabledTouchResignedClasses;

/**
 if shouldResignOnTouchOutside is enabled then you can customise the behaviour to not recognise gesture touches on some specific view subclasses. Class should be kind of UIView. Default is [UIControl, UINavigationBar]
 */
@property(nonatomic, strong, nonnull, readonly) NSMutableSet<Class> *touchResignedGestureIgnoreClasses;

///---------------------------------------------
/// @name Register for keyboard size events
///---------------------------------------------

/**
 register an object to get keyboard size change events
 */
-(void)registerKeyboardSizeChangeWithIdentifier:(nonnull id<NSCopying>)identifier
                                    sizeHandler:(void (^_Nonnull)(CGSize size))sizeHandler;

/**
 unregister the object which was registered before
 */
-(void)unregisterKeyboardSizeChangeWithIdentifier:(nonnull id<NSCopying>)identifier;


///----------------------------------------
/// @name Debugging & Developer options
///----------------------------------------

@property(nonatomic, assign) BOOL enableDebugging;

/**
 @warning Use these methods to completely enable/disable notifications registered by library internally. Please keep in mind that library is totally dependent on NSNotification of UITextField, UITextField, Keyboard etc. If you do unregisterAllNotifications then library will not work at all. You should only use below methods if you want to completely disable all library functions. You should use below methods at your own risk.
 */
-(void)registerAllNotifications;
-(void)unregisterAllNotifications;

@end
