// Copyright (c) 2023 BytePlus Pte. Ltd.
// SPDX-License-Identifier: Apache-2.0
#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import "VELIQKeyboardManager.h"
#import <ToolKit/ToolKit.h>

/**
 UIView hierarchy category.
 */
@interface UIView (VELIQ_UIView_Hierarchy)

///----------------------
/// @name viewControllers
///----------------------

/**
 Returns the UIViewController object that manages the receiver.
 */
@property (nullable, nonatomic, readonly, strong) UIViewController *viewContainingController;

/**
 Returns the topMost UIViewController object in hierarchy.
 */
@property (nullable, nonatomic, readonly, strong) UIViewController *topMostController;

/**
 Returns the UIViewController object that is actually the parent of this object. Most of the time it's the viewController object which actually contains it, but result may be different if it's viewController is added as childViewController of another viewController.
 */
@property (nullable, nonatomic, readonly, strong) UIViewController *parentContainerViewController;

///-----------------------------------
/// @name Superviews/Subviews/Siglings
///-----------------------------------

/**
 Returns the superView of provided class type.

 @param classType class type of the object which is to be search in above hierarchy and return

 @param belowView view object in upper hierarchy where method should stop searching and return nil
 */
-(nullable __kindof UIView*)superviewOfClassType:(nonnull Class)classType belowView:(nullable UIView*)belowView;
-(nullable __kindof UIView*)superviewOfClassType:(nonnull Class)classType;

///-------------------------
/// @name Special TextFields
///-------------------------

/**
 Returns searchBar if receiver object is UISearchBarTextField, otherwise return nil.
 */
@property (nullable, nonatomic, readonly) UISearchBar *textFieldSearchBar;

/**
 Returns YES if the receiver object is UIAlertSheetTextField, otherwise return NO.
 */
@property (nonatomic, getter=isAlertViewTextField, readonly) BOOL alertViewTextField;

///----------------
/// @name Transform
///----------------

/**
 Returns current view transform with respect to the 'toView'.
 */
-(CGAffineTransform)convertTransformToView:(nullable UIView*)toView;

///-----------------
/// @name Hierarchy
///-----------------

/**
 Returns a string that represent the information about it's subview's hierarchy. You can use this method to debug the subview's positions.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *subHierarchy;

/**
 Returns an string that represent the information about it's upper hierarchy. You can use this method to debug the superview's positions.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *superHierarchy;

/**
 Returns an string that represent the information about it's frame positions. You can use this method to debug self positions.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *debugHierarchy;

@end


/**
 NSObject category to used for logging purposes
 */
@interface NSObject (VELIQ_Logging)

/**
 Short description for logging purpose.
 */
@property (nonnull, nonatomic, readonly, copy) NSString *_IQDescription;

@end


@interface UITableView (PreviousNextIndexPath)

-(nullable NSIndexPath*)previousIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath;

@end

@interface UICollectionView (PreviousNextIndexPath)

-(nullable NSIndexPath*)previousIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath;

@end

#define kIQCGPointInvalid CGPointMake(CGFLOAT_MAX, CGFLOAT_MAX)

typedef void (^SizeBlock)(CGSize size);

@interface VELIQKeyboardManager()<UIGestureRecognizerDelegate>

/*******************************************/

/** used to adjust contentInset of UITextView. */
@property(nonatomic, assign) UIEdgeInsets     startingTextViewContentInsets;

/** used to adjust scrollIndicatorInsets of UITextView. */
@property(nonatomic, assign) UIEdgeInsets   startingTextViewScrollIndicatorInsets;

/** used with textView to detect a textFieldView contentInset is changed or not. (Bug ID: #92)*/
@property(nonatomic, assign) BOOL    isTextViewContentInsetChanged;

/*******************************************/

/** To save UITextField/UITextView object voa textField/textView notifications. */
@property(nullable, nonatomic, weak) UIView       *textFieldView;

/** To save rootViewController.view.frame.origin. */
@property(nonatomic, assign) CGPoint    topViewBeginOrigin;

/** To save rootViewController */
@property(nullable, nonatomic, weak) UIViewController *rootViewController;

/** To overcome with popGestureRecognizer issue Bug ID: #1361 */
@property(nullable, nonatomic, weak) UIViewController *rootViewControllerWhilePopGestureRecognizerActive;
@property(nonatomic, assign) CGPoint    topViewBeginOriginWhilePopGestureRecognizerActive;

/** To know if we have any pending request to adjust view position. */
@property(nonatomic, assign) BOOL   hasPendingAdjustRequest;

/*******************************************/

/** Variable to save lastScrollView that was scrolled. */
@property(nullable, nonatomic, weak) UIScrollView     *lastScrollView;

/** LastScrollView's initial contentInsets. */
@property(nonatomic, assign) UIEdgeInsets   startingContentInsets;

/** LastScrollView's initial scrollIndicatorInsets. */
@property(nonatomic, assign) UIEdgeInsets   startingScrollIndicatorInsets;

/** LastScrollView's initial contentOffset. */
@property(nonatomic, assign) CGPoint        startingContentOffset;

/*******************************************/

/** To save keyboard animation duration. */
@property(nonatomic, assign) CGFloat    animationDuration;

/** To mimic the keyboard animation */
@property(nonatomic, assign) NSInteger  animationCurve;

/*******************************************/

/** TapGesture to resign keyboard on view's touch. It's a readonly property and exposed only for adding/removing dependencies if your added gesture does have collision with this one */
@property(nonnull, nonatomic, strong, readwrite) UITapGestureRecognizer  *resignFirstResponderGesture;

/**
 moved distance to the top used to maintain distance between keyboard and textField. Most of the time this will be a positive value.
 */
@property(nonatomic, assign, readwrite) CGFloat movedDistance;

/*******************************************/

@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *disabledDistanceHandlingClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *enabledDistanceHandlingClasses;


@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *disabledTouchResignedClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *enabledTouchResignedClasses;
@property(nonatomic, strong, nonnull, readwrite) NSMutableSet<Class> *touchResignedGestureIgnoreClasses;

/*******************************************/

@end

@implementation VELIQKeyboardManager
{
	@package

    /*******************************************/
    
    /** To save keyboardWillShowNotification. Needed for enable keyboard functionality. */
    NSNotification          *_kbShowNotification;
    
    /** To save keyboard size. */
    CGRect                   _kbFrame;

    CGSize                   _keyboardLastNotifySize;
    NSMutableDictionary<id<NSCopying>, SizeBlock>* _keyboardSizeObservers;

    /*******************************************/
}

//UIKeyboard handling
@synthesize enable                              =   _enable;
@synthesize keyboardDistanceFromTextField       =   _keyboardDistanceFromTextField;

//Resign handling
@synthesize shouldResignOnTouchOutside          =   _shouldResignOnTouchOutside;
@synthesize resignFirstResponderGesture         =   _resignFirstResponderGesture;

//Animation handling
@synthesize layoutIfNeededOnUpdate              =   _layoutIfNeededOnUpdate;

#pragma mark - Initializing functions

/*  Singleton Object Initialization. */
-(instancetype)init
{
	if (self = [super init])
    {

        [self registerAllNotifications];

        //Creating gesture for @shouldResignOnTouchOutside. (Enhancement ID: #14)
        self.resignFirstResponderGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized:)];
        self.resignFirstResponderGesture.cancelsTouchesInView = NO;
        [self.resignFirstResponderGesture setDelegate:self];
        self.resignFirstResponderGesture.enabled = self.shouldResignOnTouchOutside;
        self.topViewBeginOrigin = kIQCGPointInvalid;
        self.topViewBeginOriginWhilePopGestureRecognizerActive = kIQCGPointInvalid;
        
        //Setting it's initial values
        self.animationDuration = 0.25;
        self.animationCurve = UIViewAnimationCurveEaseInOut;
        [self setEnable:YES];
        [self setKeyboardDistanceFromTextField:5.0];
        [self setShouldResignOnTouchOutside:YES];
        [self setLayoutIfNeededOnUpdate:NO];


        self->_keyboardSizeObservers = [[NSMutableDictionary alloc] init];
        //Initializing disabled classes Set.
        self.disabledDistanceHandlingClasses = [[NSMutableSet alloc] initWithObjects:[UITableViewController class],[UIAlertController class], nil];
        self.enabledDistanceHandlingClasses = [[NSMutableSet alloc] init];
        
        
        self.disabledTouchResignedClasses = [[NSMutableSet alloc] initWithObjects:[UIAlertController class], nil];
        self.enabledTouchResignedClasses = [[NSMutableSet alloc] init];
        self.touchResignedGestureIgnoreClasses = [[NSMutableSet alloc] initWithObjects:[UIControl class],[UINavigationBar class], nil];
    }
    return self;
}

#pragma mark - Dealloc
-(void)dealloc
{
    //  Disable the keyboard manager.
	[self setEnable:NO];
    
    //Removing notification observers on dealloc.
    [self unregisterAllNotifications];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Property functions
-(void)setEnable:(BOOL)enable
{
	// If not enabled, enable it.
    if (enable == YES &&
        _enable == NO)
    {
		//Setting YES to _enable.
		_enable = enable;
        
		//If keyboard is currently showing. Sending a fake notification for keyboardWillShow to adjust view according to keyboard.
		if (_kbShowNotification)	[self keyboardWillShow:_kbShowNotification];

        [self showLog:@"Enabled"];
    }
	//If not disable, desable it.
    else if (enable == NO &&
             _enable == YES)
    {
		//Sending a fake notification for keyboardWillHide to retain view's original position.
		[self keyboardWillHide:nil];
        
		//Setting NO to _enable.
		_enable = enable;
		
        [self showLog:@"Disabled"];
    }
	//If already disabled.
	else if (enable == NO &&
             _enable == NO)
	{
        [self showLog:@"Already Disabled"];
	}
	//If already enabled.
	else if (enable == YES &&
             _enable == YES)
	{
        [self showLog:@"Already Enabled"];
	}
}

-(BOOL)privateIsEnabled
{
    BOOL enable = _enable;
    {
        __strong __typeof__(UIView) *strongTextFieldView = _textFieldView;

        UIViewController *textFieldViewController = [strongTextFieldView viewContainingController];
        
        if (textFieldViewController)
        {
            //If it is searchBar textField embedded in Navigation Bar
            if ([strongTextFieldView textFieldSearchBar] != nil && [textFieldViewController isKindOfClass:[UINavigationController class]]) {
                
                UINavigationController *navController = (UINavigationController*)textFieldViewController;
                if (navController.topViewController) {
                    textFieldViewController = navController.topViewController;
                }
            }

            if (enable == NO)
            {
                //If viewController is kind of enable viewController class, then assuming it's enabled.
                for (Class enabledClass in _enabledDistanceHandlingClasses)
                {
                    if ([textFieldViewController isKindOfClass:enabledClass])
                    {
                        enable = YES;
                        break;
                    }
                }
            }
            
            if (enable)
            {
                //If viewController is kind of disable viewController class, then assuming it's disable.
                for (Class disabledClass in _disabledDistanceHandlingClasses)
                {
                    if ([textFieldViewController isKindOfClass:disabledClass])
                    {
                        enable = NO;
                        break;
                    }
                }
                
                //Special Controllers
                if (enable == YES)
                {
                    NSString *classNameString = NSStringFromClass([textFieldViewController class]);
                    
                    //_UIAlertControllerTextFieldViewController
                    if ([classNameString containsString:@"UIAlertController"] && [classNameString hasSuffix:@"TextFieldViewController"])
                    {
                        enable = NO;
                    }
                }
            }
        }
    }
    
    return enable;
}

//	Setting keyboard distance from text field.
-(void)setKeyboardDistanceFromTextField:(CGFloat)keyboardDistanceFromTextField
{
    //Can't be less than zero. Minimum is zero.
	_keyboardDistanceFromTextField = MAX(keyboardDistanceFromTextField, 0);

    [self showLog:[NSString stringWithFormat:@"keyboardDistanceFromTextField: %.2f",_keyboardDistanceFromTextField]];
}

/** Enabling/disable gesture on touching. */
-(void)setShouldResignOnTouchOutside:(BOOL)shouldResignOnTouchOutside
{
    [self showLog:[NSString stringWithFormat:@"shouldResignOnTouchOutside: %@",shouldResignOnTouchOutside?@"Yes":@"No"]];
    
    _shouldResignOnTouchOutside = shouldResignOnTouchOutside;
    
    //Enable/Disable gesture recognizer   (Enhancement ID: #14)
    [_resignFirstResponderGesture setEnabled:[self privateShouldResignOnTouchOutside]];
}

-(BOOL)privateShouldResignOnTouchOutside
{
    BOOL shouldResignOnTouchOutside = _shouldResignOnTouchOutside;
    
    __strong __typeof__(UIView) *strongTextFieldView = _textFieldView;
    {
        UIViewController *textFieldViewController = [strongTextFieldView viewContainingController];
        
        if (textFieldViewController)
        {
            //If it is searchBar textField embedded in Navigation Bar
            if ([strongTextFieldView textFieldSearchBar] != nil && [textFieldViewController isKindOfClass:[UINavigationController class]]) {
                
                UINavigationController *navController = (UINavigationController*)textFieldViewController;
                if (navController.topViewController) {
                    textFieldViewController = navController.topViewController;
                }
            }

            if (shouldResignOnTouchOutside == NO)
            {
                //If viewController is kind of enable viewController class, then assuming shouldResignOnTouchOutside is enabled.
                for (Class enabledClass in _enabledTouchResignedClasses)
                {
                    if ([textFieldViewController isKindOfClass:enabledClass])
                    {
                        shouldResignOnTouchOutside = YES;
                        break;
                    }
                }
            }
            
            if (shouldResignOnTouchOutside)
            {
                //If viewController is kind of disable viewController class, then assuming shouldResignOnTouchOutside is disable.
                for (Class disabledClass in _disabledTouchResignedClasses)
                {
                    if ([textFieldViewController isKindOfClass:disabledClass])
                    {
                        shouldResignOnTouchOutside = NO;
                        break;
                    }
                }
                
                //Special Controllers
                if (shouldResignOnTouchOutside == YES)
                {
                    NSString *classNameString = NSStringFromClass([textFieldViewController class]);
                    
                    //_UIAlertControllerTextFieldViewController
                    if ([classNameString containsString:@"UIAlertController"] && [classNameString hasSuffix:@"TextFieldViewController"])
                    {
                        shouldResignOnTouchOutside = NO;
                    }
                }
            }
        }
    }
    
    return shouldResignOnTouchOutside;
}

/** Setter of movedDistance property. */
-(void)setMovedDistance:(CGFloat)movedDistance
{
    _movedDistance = movedDistance;
    if (self.movedDistanceChanged != nil) {
        self.movedDistanceChanged(movedDistance);
    }
}

#pragma mark - Private Methods

/** Getting keyWindow. */
-(UIWindow *)keyWindow
{
    UIView *textFieldView = _textFieldView;

    if (textFieldView.window)
    {
        return textFieldView.window;
    }
    else
    {
        static __weak UIWindow *cachedKeyWindow = nil;
        
        /*  (Bug ID: #23, #25, #73)   */
        UIWindow *originalKeyWindow = nil;

        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            NSSet<UIScene *> *connectedScenes = [UIApplication sharedApplication].connectedScenes;
            for (UIScene *scene in connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive && [scene isKindOfClass:[UIWindowScene class]]) {
                    UIWindowScene *windowScene = (UIWindowScene *)scene;
                    for (UIWindow *window in windowScene.windows) {
                        if (window.isKeyWindow) {
                            originalKeyWindow = window;
                            break;
                        }
                    }
                }
            }
        } else
        #endif
        {
        #if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            originalKeyWindow = [UIApplication sharedApplication].keyWindow;
        #endif
        }

        //If original key window is not nil and the cached keywindow is also not original keywindow then changing keywindow.
        if (originalKeyWindow)
        {
            cachedKeyWindow = originalKeyWindow;
        }

        __strong UIWindow *strongCachedKeyWindow = cachedKeyWindow;

        return strongCachedKeyWindow;
    }
}

-(void)optimizedAdjustPosition
{
    if (_hasPendingAdjustRequest == NO)
    {
        _hasPendingAdjustRequest = YES;
        
        __weak __typeof__(self) weakSelf = self;

        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            __strong __typeof__(self) strongSelf = weakSelf;

            [strongSelf adjustPosition];
            strongSelf.hasPendingAdjustRequest = NO;
        }];
    }
}

/* Adjusting RootViewController's frame according to interface orientation. */
-(void)adjustPosition
{
    UIView *textFieldView = _textFieldView;

    //  Getting RootViewController.  (Bug ID: #1, #4)
    UIViewController *rootController = _rootViewController;
    
    //  Getting KeyWindow object.
    UIWindow *keyWindow = [self keyWindow];
    
    //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
    if (_hasPendingAdjustRequest == NO ||
        textFieldView == nil ||
        rootController == nil ||
        keyWindow == nil)
        return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    //  Converting Rectangle according to window bounds.
    CGRect textFieldViewRectInWindow = [[textFieldView superview] convertRect:textFieldView.frame toView:keyWindow];
    CGRect textFieldViewRectInRootSuperview = [[textFieldView superview] convertRect:textFieldView.frame toView:rootController.view.superview];
    //  Getting RootView origin.
    CGPoint rootViewOrigin = rootController.view.frame.origin;

    
    CGFloat keyboardDistanceFromTextField = _keyboardDistanceFromTextField;

    CGSize kbSize;
    
    {
        CGRect kbFrame = _kbFrame;
        
        kbFrame.origin.y -= keyboardDistanceFromTextField;
        kbFrame.size.height += keyboardDistanceFromTextField;
        
        //Calculating actual keyboard displayed size, keyboard frame may be different when hardware keyboard is attached (Bug ID: #469) (Bug ID: #381) (Bug ID: #1506)
        CGRect intersectRect = CGRectIntersection(kbFrame, keyWindow.frame);
        
        if (CGRectIsNull(intersectRect))
        {
            kbSize = CGSizeMake(kbFrame.size.width, 0);
        }
        else
        {
            kbSize = intersectRect.size;
        }
    }


    CGFloat navigationBarAreaHeight = 0;

    if (rootController.navigationController != nil) {
        navigationBarAreaHeight = CGRectGetMaxY(rootController.navigationController.navigationBar.frame);
    } else {
        CGFloat statusBarHeight = 0;
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 13.0, *)) {
            statusBarHeight = [self keyWindow].windowScene.statusBarManager.statusBarFrame.size.height;

        } else
    #endif
        {
    #if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
    #endif
        }

        navigationBarAreaHeight = statusBarHeight;
    }

    CGFloat layoutAreaHeight = rootController.view.layoutMargins.top;
    
    CGFloat topLayoutGuide = MAX(navigationBarAreaHeight, layoutAreaHeight) + 5;
    CGFloat bottomLayoutGuide = ([textFieldView respondsToSelector:@selector(isEditable)] && [textFieldView isKindOfClass:[UIScrollView class]]) ? 0 : rootController.view.layoutMargins.bottom; //Validation of textView for case where there is a tab bar at the bottom or running on iPhone X and textView is at the bottom.

    //  +Move positive = textField is hidden.
    //  -Move negative = textField is showing.
    //  Calculating move position. Common for both normal and special cases.
    CGFloat move = MIN(CGRectGetMinY(textFieldViewRectInRootSuperview)-topLayoutGuide, CGRectGetMaxY(textFieldViewRectInWindow)-(CGRectGetHeight(keyWindow.frame)-kbSize.height)+bottomLayoutGuide);

    [self showLog:[NSString stringWithFormat:@"Need to move: %.2f",move]];

    UIScrollView *superScrollView = nil;
    UIScrollView *superView = (UIScrollView*)[textFieldView superviewOfClassType:[UIScrollView class]];

    //Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
    while (superView)
    {
        if (superView.isScrollEnabled)
        {
            superScrollView = superView;
            break;
        }
        else
        {
            //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
            superView = (UIScrollView*)[superView superviewOfClassType:[UIScrollView class]];
        }
    }
    
    __strong __typeof__(UIScrollView) *strongLastScrollView = _lastScrollView;

    //If there was a lastScrollView.    //  (Bug ID: #34)
    if (strongLastScrollView)
    {
        //If we can't find current superScrollView, then setting lastScrollView to it's original form.
        if (superScrollView == nil)
        {
            if (UIEdgeInsetsEqualToEdgeInsets(strongLastScrollView.contentInset, _startingContentInsets) == NO)
            {
                [self showLog:[NSString stringWithFormat:@"Restoring ScrollView contentInset to : %@",NSStringFromUIEdgeInsets(_startingContentInsets)]];
                
                __weak __typeof__(self) weakSelf = self;

                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong __typeof__(self) strongSelf = weakSelf;
                    
                    [strongLastScrollView setContentInset:strongSelf.startingContentInsets];
                    strongLastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
                } completion:NULL];
            }

            _startingContentInsets = UIEdgeInsetsZero;
            _startingScrollIndicatorInsets = UIEdgeInsetsZero;
            _startingContentOffset = CGPointZero;
            _lastScrollView = nil;
            strongLastScrollView = _lastScrollView;
        }
        //If both scrollView's are different, then reset lastScrollView to it's original frame and setting current scrollView as last scrollView.
        else if (superScrollView != strongLastScrollView)
        {
            if (UIEdgeInsetsEqualToEdgeInsets(strongLastScrollView.contentInset, _startingContentInsets) == NO)
            {
                [self showLog:[NSString stringWithFormat:@"Restoring ScrollView contentInset to : %@",NSStringFromUIEdgeInsets(_startingContentInsets)]];

                __weak __typeof__(self) weakSelf = self;
                
                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong __typeof__(self) strongSelf = weakSelf;
                    
                    [strongLastScrollView setContentInset:strongSelf.startingContentInsets];
                    strongLastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
                } completion:NULL];
            }

            _lastScrollView = superScrollView;
            strongLastScrollView = _lastScrollView;
            _startingContentInsets = superScrollView.contentInset;
            _startingContentOffset = superScrollView.contentOffset;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
            if (@available(iOS 11.1, *)) {
                _startingScrollIndicatorInsets = superScrollView.verticalScrollIndicatorInsets;
            } else
#endif
            {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
                _startingScrollIndicatorInsets = superScrollView.scrollIndicatorInsets;
#endif
            }

            [self showLog:[NSString stringWithFormat:@"Saving New contentInset: %@ and contentOffset : %@",NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]];
        }
        //Else the case where superScrollView == lastScrollView means we are on same scrollView after switching to different textField. So doing nothing
    }
    //If there was no lastScrollView and we found a current scrollView. then setting it as lastScrollView.
    else if(superScrollView)
    {
        _lastScrollView = superScrollView;
        strongLastScrollView = _lastScrollView;
        _startingContentInsets = superScrollView.contentInset;
        _startingContentOffset = superScrollView.contentOffset;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
        if (@available(iOS 11.1, *)) {
            _startingScrollIndicatorInsets = superScrollView.verticalScrollIndicatorInsets;
        } else
#endif
        {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
            _startingScrollIndicatorInsets = superScrollView.scrollIndicatorInsets;
#endif
        }

        [self showLog:[NSString stringWithFormat:@"Saving contentInset: %@ and contentOffset : %@",NSStringFromUIEdgeInsets(_startingContentInsets),NSStringFromCGPoint(_startingContentOffset)]];
    }
    
    //  Special case for ScrollView.
    {
        //  If we found lastScrollView then setting it's contentOffset to show textField.
        if (strongLastScrollView)
        {
            //Saving
            UIView *lastView = textFieldView;
            superScrollView = strongLastScrollView;

            //Looping in upper hierarchy until we don't found any scrollView in it's upper hirarchy till UIWindow object.
            while (superScrollView)
            {
                BOOL shouldContinue = NO;
                
                if (move > 0)
                {
                    shouldContinue = move > (-superScrollView.contentOffset.y-superScrollView.contentInset.top);
                }
                else
                {
                    //Special treatment for UITableView due to their cell reusing logic
                    if ([superScrollView isKindOfClass:[UITableView class]])
                    {
                        shouldContinue = superScrollView.contentOffset.y>0;

                        UITableView *tableView = (UITableView*)superScrollView;
                        UITableViewCell *tableCell = nil;
                        NSIndexPath *indexPath = nil;
                        NSIndexPath *previousIndexPath = nil;

                        if (shouldContinue &&
                            (tableCell = (UITableViewCell*)[textFieldView superviewOfClassType:[UITableViewCell class]]) &&
                            (indexPath = [tableView indexPathForCell:tableCell]) &&
                            (previousIndexPath = [tableView previousIndexPathOfIndexPath:indexPath]))
                        {
                            CGRect previousCellRect = [tableView rectForRowAtIndexPath:previousIndexPath];
                            if (CGRectIsEmpty(previousCellRect) == NO)
                            {
                                CGRect previousCellRectInRootSuperview = [tableView convertRect:previousCellRect toView:rootController.view.superview];
                                move = MIN(0, CGRectGetMaxY(previousCellRectInRootSuperview) - topLayoutGuide);
                            }
                        }
                    }
                    //Special treatment for UICollectionView due to their cell reusing logic
                    else if ([superScrollView isKindOfClass:[UICollectionView class]])
                    {
                        shouldContinue = superScrollView.contentOffset.y>0;
                        
                        UICollectionView *collectionView = (UICollectionView*)superScrollView;
                        UICollectionViewCell *collectionCell = nil;
                        NSIndexPath *indexPath = nil;
                        NSIndexPath *previousIndexPath = nil;

                        if (shouldContinue &&
                            (collectionCell = (UICollectionViewCell*)[textFieldView superviewOfClassType:[UICollectionViewCell class]]) &&
                            (indexPath = [collectionView indexPathForCell:collectionCell]) &&
                            (previousIndexPath = [collectionView previousIndexPathOfIndexPath:indexPath]))
                        {
                            UICollectionViewLayoutAttributes *attributes = [collectionView layoutAttributesForItemAtIndexPath:previousIndexPath];
                            
                            CGRect previousCellRect = attributes.frame;
                            if (CGRectIsEmpty(previousCellRect) == NO)
                            {
                                CGRect previousCellRectInRootSuperview = [collectionView convertRect:previousCellRect toView:rootController.view.superview];
                                move = MIN(0, CGRectGetMaxY(previousCellRectInRootSuperview) - topLayoutGuide);
                            }
                        }
                    }
                    else
                    {
                        //If the textField is hidden at the top
                        shouldContinue = textFieldViewRectInRootSuperview.origin.y < topLayoutGuide;
                        
                        if (shouldContinue) {
                            move = MIN(0, textFieldViewRectInRootSuperview.origin.y - topLayoutGuide);
                        }
                    }
                }
                
                if (shouldContinue == NO)
                {
                    move = 0;
                    break;
                }

                UIScrollView *nextScrollView = nil;
                UIScrollView *tempScrollView = (UIScrollView*)[superScrollView superviewOfClassType:[UIScrollView class]];
                
                //Getting UIScrollView whose scrolling is enabled.    //  (Bug ID: #285)
                while (tempScrollView)
                {
                    if (tempScrollView.isScrollEnabled )
                    {
                        nextScrollView = tempScrollView;
                        break;
                    }
                    else
                    {
                        //  Getting it's superScrollView.   //  (Enhancement ID: #21, #24)
                        tempScrollView = (UIScrollView*)[tempScrollView superviewOfClassType:[UIScrollView class]];
                    }
                }

                //Getting lastViewRect.
                CGRect lastViewRect = [[lastView superview] convertRect:lastView.frame toView:superScrollView];
                
                //Calculating the expected Y offset from move and scrollView's contentOffset.
                CGFloat shouldOffsetY = superScrollView.contentOffset.y - MIN(superScrollView.contentOffset.y,-move);
                
                //Rearranging the expected Y offset according to the view.
                shouldOffsetY = MIN(shouldOffsetY, lastViewRect.origin.y);
                
                //[textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
                //[superScrollView superviewOfClassType:[UIScrollView class]] == nil    If processing scrollView is last scrollView in upper hierarchy (there is no other scrollView upper hierarchy.)
                //shouldOffsetY >= 0     shouldOffsetY must be greater than in order to keep distance from navigationBar (Bug ID: #92)
                if ([textFieldView respondsToSelector:@selector(isEditable)]  && [textFieldView isKindOfClass:[UIScrollView class]] &&
                    nextScrollView == nil &&
                    (shouldOffsetY >= 0))
                {
                    //  Converting Rectangle according to window bounds.
                    CGRect currentTextFieldViewRect = [[textFieldView superview] convertRect:textFieldView.frame toView:keyWindow];
                    
                    //Calculating expected fix distance which needs to be managed from navigation bar
                    CGFloat expectedFixDistance = CGRectGetMinY(currentTextFieldViewRect) - topLayoutGuide;
                    
                    //Now if expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance) is lower than current shouldOffsetY, which means we're in a position where navigationBar up and hide, then reducing shouldOffsetY with expectedOffsetY (superScrollView.contentOffset.y + expectedFixDistance)
                    shouldOffsetY = MIN(shouldOffsetY, superScrollView.contentOffset.y + expectedFixDistance);
                    
                    //Setting move to 0 because now we don't want to move any view anymore (All will be managed by our contentInset logic. 
                    move = 0;
                }
                else
                {
                    //Subtracting the Y offset from the move variable, because we are going to change scrollView's contentOffset.y to shouldOffsetY.
                    move -= (shouldOffsetY-superScrollView.contentOffset.y);
                }

                
                CGPoint newContentOffset = CGPointMake(superScrollView.contentOffset.x, shouldOffsetY);
                
                if (CGPointEqualToPoint(superScrollView.contentOffset, newContentOffset) == NO)
                {
                    __weak __typeof__(self) weakSelf = self;

                    //Getting problem while using `setContentOffset:animated:`, So I used animation API.
                    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                        
                        __strong __typeof__(self) strongSelf = weakSelf;

                        [strongSelf showLog:[NSString stringWithFormat:@"Adjusting %.2f to %@ ContentOffset",(superScrollView.contentOffset.y-shouldOffsetY),[superScrollView _IQDescription]]];
                        [strongSelf showLog:[NSString stringWithFormat:@"Remaining Move: %.2f",move]];
                        
                        BOOL animatedContentOffset = ([textFieldView superviewOfClassType:[UIStackView class] belowView:superScrollView] != nil);   //  (Bug ID: #1365, #1508, #1541)

                        if (animatedContentOffset) {
                            [superScrollView setContentOffset:newContentOffset animated:UIView.areAnimationsEnabled];
                        } else {
                            superScrollView.contentOffset = newContentOffset;
                        }
                    } completion:^(BOOL finished){
                    }];
                }

                //  Getting next lastView & superScrollView.
                lastView = superScrollView;
                superScrollView = nextScrollView;
            }
            
            //Updating contentInset
            {
                CGRect lastScrollViewRect = [[strongLastScrollView superview] convertRect:strongLastScrollView.frame toView:keyWindow];

                CGFloat bottomInset = (kbSize.height)-(CGRectGetHeight(keyWindow.frame)-CGRectGetMaxY(lastScrollViewRect));
                CGFloat bottomScrollIndicatorInset = bottomInset - keyboardDistanceFromTextField;

                // Update the insets so that the scroll vew doesn't shift incorrectly when the offset is near the bottom of the scroll view.
                bottomInset = MAX(_startingContentInsets.bottom, bottomInset);
                bottomScrollIndicatorInset = MAX(_startingScrollIndicatorInsets.bottom, bottomScrollIndicatorInset);

                if (@available(iOS 11, *)) {
                    bottomInset -= strongLastScrollView.safeAreaInsets.bottom;
                    bottomScrollIndicatorInset -= strongLastScrollView.safeAreaInsets.bottom;
                }

                UIEdgeInsets movedInsets = strongLastScrollView.contentInset;
                movedInsets.bottom = bottomInset;

                if (UIEdgeInsetsEqualToEdgeInsets(strongLastScrollView.contentInset, movedInsets) == NO)
                {
                    [self showLog:[NSString stringWithFormat:@"old ContentInset : %@ new ContentInset : %@", NSStringFromUIEdgeInsets(strongLastScrollView.contentInset), NSStringFromUIEdgeInsets(movedInsets)]];
                    
                    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                        
                        strongLastScrollView.contentInset = movedInsets;
                        UIEdgeInsets newScrollIndicatorInset;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
                        if (@available(iOS 11.1, *)) {
                            newScrollIndicatorInset = strongLastScrollView.verticalScrollIndicatorInsets;
                        } else
#endif
                        {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
                            newScrollIndicatorInset = strongLastScrollView.scrollIndicatorInsets;
#endif
                        }

                        newScrollIndicatorInset.bottom = bottomScrollIndicatorInset;
                        strongLastScrollView.scrollIndicatorInsets = newScrollIndicatorInset;
                        
                    } completion:NULL];
                }
            }
        }
        //Going ahead. No else if.
    }
    
    {
        //Special case for UITextView(Readjusting textView.contentInset when textView hight is too big to fit on screen)
        //_lastScrollView       If not having inside any scrollView, (now contentInset manages the full screen textView.
        //[textFieldView isKindOfClass:[UITextView class]] If is a UITextView type
        if ([textFieldView isKindOfClass:[UIScrollView class]] && [(UIScrollView*)textFieldView isScrollEnabled] && [textFieldView respondsToSelector:@selector(isEditable)])
        {
            UIScrollView *textView = (UIScrollView*)textFieldView;

            CGFloat keyboardYPosition = CGRectGetHeight(keyWindow.frame)-(kbSize.height-keyboardDistanceFromTextField);

            CGRect rootSuperViewFrameInWindow = [rootController.view.superview convertRect:rootController.view.superview.bounds toView:keyWindow];

            CGFloat keyboardOverlapping = CGRectGetMaxY(rootSuperViewFrameInWindow) - keyboardYPosition;

            CGFloat textViewHeight = MIN(CGRectGetHeight(textFieldView.frame), (CGRectGetHeight(rootSuperViewFrameInWindow)-topLayoutGuide-keyboardOverlapping));
            
            if (textFieldView.frame.size.height-textView.contentInset.bottom>textViewHeight)
            {
                //_isTextViewContentInsetChanged,  If frame is not change by library in past, then saving user textView properties  (Bug ID: #92)
                if (self.isTextViewContentInsetChanged == NO)
                {
                    self.startingTextViewContentInsets = textView.contentInset;
                    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
                    if (@available(iOS 11.1, *)) {
                        self.startingTextViewScrollIndicatorInsets = textView.verticalScrollIndicatorInsets;
                    } else
#endif
                    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
                        self.startingTextViewScrollIndicatorInsets = textView.scrollIndicatorInsets;
#endif
                    }
                }

                CGFloat bottomInset = textFieldView.frame.size.height-textViewHeight;

                if (@available(iOS 11, *)) {
                    bottomInset -= textFieldView.safeAreaInsets.bottom;
                }

                UIEdgeInsets newContentInset = textView.contentInset;
                newContentInset.bottom = bottomInset;

                self.isTextViewContentInsetChanged = YES;

                if (UIEdgeInsetsEqualToEdgeInsets(textView.contentInset, newContentInset) == NO)
                {
                    __weak __typeof__(self) weakSelf = self;
                    
                    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                        
                        __strong __typeof__(self) strongSelf = weakSelf;
                        
                        [strongSelf showLog:[NSString stringWithFormat:@"Old UITextView.contentInset : %@ New UITextView.contentInset : %@", NSStringFromUIEdgeInsets(textView.contentInset), NSStringFromUIEdgeInsets(textView.contentInset)]];
                        
                        textView.contentInset = newContentInset;
                        textView.scrollIndicatorInsets = newContentInset;
                    } completion:NULL];
                }
            }
        }

        {
            __weak __typeof__(self) weakSelf = self;

            //  +Positive or zero.
            if (move>=0)
            {
                rootViewOrigin.y -= move;
                
                //  From now prevent keyboard manager to slide up the rootView to more than keyboard height. (Bug ID: #93)
                rootViewOrigin.y = MAX(rootViewOrigin.y, MIN(0, -(kbSize.height-keyboardDistanceFromTextField)));

                [self showLog:@"Moving Upward"];
                //  Setting adjusted rootViewOrigin.ty
                
                //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
                [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                    
                    __strong __typeof__(self) strongSelf = weakSelf;
                    
                    //  Setting it's new frame
                    CGRect rect = rootController.view.frame;
                    rect.origin = rootViewOrigin;
                    rootController.view.frame = rect;
                    
                    //Animating content if needed (Bug ID: #204)
                    if (strongSelf.layoutIfNeededOnUpdate)
                    {
                        //Animating content (Bug ID: #160)
                        [rootController.view setNeedsLayout];
                        [rootController.view layoutIfNeeded];
                    }
                    
                    [strongSelf showLog:[NSString stringWithFormat:@"Set %@ origin to : %@",rootController,NSStringFromCGPoint(rootViewOrigin)]];
                } completion:NULL];

                self.movedDistance = (_topViewBeginOrigin.y-rootViewOrigin.y);
            }
            //  -Negative
            else
            {
                CGFloat disturbDistance = rootController.view.frame.origin.y-_topViewBeginOrigin.y;
                
                //  disturbDistance Negative = frame disturbed. Pull Request #3
                //  disturbDistance positive = frame not disturbed.
                if(disturbDistance<=0)
                {
                    rootViewOrigin.y -= MAX(move, disturbDistance);
                    
                    [self showLog:@"Moving Downward"];
                    //  Setting adjusted rootViewRect
                    
                    //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
                    [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                        
                        __strong __typeof__(self) strongSelf = weakSelf;
                        
                        //  Setting it's new frame
                        CGRect rect = rootController.view.frame;
                        rect.origin = rootViewOrigin;
                        rootController.view.frame = rect;
                        
                        //Animating content if needed (Bug ID: #204)
                        if (strongSelf.layoutIfNeededOnUpdate)
                        {
                            //Animating content (Bug ID: #160)
                            [rootController.view setNeedsLayout];
                            [rootController.view layoutIfNeeded];
                        }
                        
                        [strongSelf showLog:[NSString stringWithFormat:@"Set %@ origin to : %@",rootController,NSStringFromCGPoint(rootViewOrigin)]];
                    } completion:NULL];

                    self.movedDistance = (_topViewBeginOrigin.y-rootController.view.frame.origin.y);
                }
            }
        }
    }
    
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

-(void)restorePosition
{
    _hasPendingAdjustRequest = NO;

    //  Setting rootViewController frame to it's original position. //  (Bug ID: #18)
    if (_rootViewController && CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid) == false)
    {
        __weak __typeof__(self) weakSelf = self;
        
        //Used UIViewAnimationOptionBeginFromCurrentState to minimize strange animations.
        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            __strong __typeof__(self) strongSelf = weakSelf;
            UIViewController *strongRootController = strongSelf.rootViewController;
            
            {
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring %@ origin to : %@",strongRootController,NSStringFromCGPoint(strongSelf.topViewBeginOrigin)]];
                
                //Restoring
                CGRect rect = strongRootController.view.frame;
                rect.origin = strongSelf.topViewBeginOrigin;
                strongRootController.view.frame = rect;

                strongSelf.movedDistance = 0;
                
                if (strongRootController.navigationController.interactivePopGestureRecognizer.state == UIGestureRecognizerStateBegan) {
                    strongSelf.rootViewControllerWhilePopGestureRecognizerActive = strongRootController;
                    strongSelf.topViewBeginOriginWhilePopGestureRecognizerActive = strongSelf.topViewBeginOrigin;
                }
                
                //Animating content if needed (Bug ID: #204)
                if (strongSelf.layoutIfNeededOnUpdate)
                {
                    //Animating content (Bug ID: #160)
                    [strongRootController.view setNeedsLayout];
                    [strongRootController.view layoutIfNeeded];
                }
            }
            
        } completion:NULL];
        _rootViewController = nil;
    }
}

#pragma mark - Public Methods

/*  Refreshes textField/textView position if any external changes is explicitly made by user.   */
- (void)reloadLayoutIfNeeded
{
    if ([self privateIsEnabled] == YES)
    {
        UIView *textFieldView = _textFieldView;
        
        if (textFieldView &&
            _keyboardShowing == YES &&
            CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid) == false &&
            [textFieldView isAlertViewTextField] == NO)
        {
            [self optimizedAdjustPosition];
        }
    }
}

#pragma mark - UIKeyboad Notification methods
/*  UIKeyboardWillShowNotification. */
-(void)keyboardWillShow:(NSNotification*)aNotification
{
    _kbShowNotification = aNotification;
	
    //  Boolean to know keyboard is showing/hiding
    _keyboardShowing = YES;
    
    //  Getting keyboard animation.
    NSInteger curve = [[aNotification userInfo][UIKeyboardAnimationCurveUserInfoKey] integerValue];
    _animationCurve = curve<<16;

    //  Getting keyboard animation duration
    CGFloat duration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //Saving animation duration
    if (duration != 0.0)    _animationDuration = duration;
    
    CGRect oldKBFrame = _kbFrame;
    
    //  Getting UIKeyboardSize.
    _kbFrame = [[aNotification userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];

    [self notifyKeyboardSize:_kbFrame.size];

    if ([self privateIsEnabled] == NO)
    {
        [self restorePosition];
        _topViewBeginOrigin = kIQCGPointInvalid;
        return;
    }
	
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    UIView *textFieldView = _textFieldView;

    if (textFieldView && CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid))    //  (Bug ID: #5)
    {
        //  keyboard is not showing(At the beginning only). We should save rootViewRect.
        UIViewController *rootController = [textFieldView parentContainerViewController];
        _rootViewController = rootController;
        
        if (_rootViewControllerWhilePopGestureRecognizerActive == rootController)
        {
            _topViewBeginOrigin = _topViewBeginOriginWhilePopGestureRecognizerActive;
        }
        else
        {
            _topViewBeginOrigin = rootController.view.frame.origin;
        }
        
        _rootViewControllerWhilePopGestureRecognizerActive = nil;
        _topViewBeginOriginWhilePopGestureRecognizerActive = kIQCGPointInvalid;
        
        [self showLog:[NSString stringWithFormat:@"Saving %@ beginning origin: %@",rootController,NSStringFromCGPoint(_topViewBeginOrigin)]];
    }

    //If last restored keyboard size is different(any orientation accure), then refresh. otherwise not.
    if (!CGRectEqualToRect(_kbFrame, oldKBFrame))
    {
        //If _textFieldView is inside AlertView then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is AlertView textField then do not affect anything (Bug ID: #70).
        if (_keyboardShowing == YES &&
            textFieldView &&
            [textFieldView isAlertViewTextField] == NO)
        {
            [self optimizedAdjustPosition];
        }
    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/*  UIKeyboardDidShowNotification. */
- (void)keyboardDidShow:(NSNotification*)aNotification
{
    if ([self privateIsEnabled] == NO)	return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", aNotification.object]];

    UIView *textFieldView = _textFieldView;

    //  Getting topMost ViewController.
    UIViewController *controller = [textFieldView topMostController];

    //If _textFieldView viewController is presented as formSheet, then adjustPosition again because iOS internally update formSheet frame on keyboardShown. (Bug ID: #37, #74, #76)
    if (_keyboardShowing == YES &&
        textFieldView &&
        (controller.modalPresentationStyle == UIModalPresentationFormSheet || controller.modalPresentationStyle == UIModalPresentationPageSheet) &&
        [textFieldView isAlertViewTextField] == NO)
    {
        [self optimizedAdjustPosition];
    }
    
    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/*  UIKeyboardWillHideNotification. So setting rootViewController to it's default frame. */
- (void)keyboardWillHide:(NSNotification*)aNotification
{
    //If it's not a fake notification generated by [self setEnable:NO].
    if (aNotification)	_kbShowNotification = nil;
    
    //  Boolean to know keyboard is showing/hiding
    _keyboardShowing = NO;
    
    //  Getting keyboard animation duration
    CGFloat aDuration = [[aNotification userInfo][UIKeyboardAnimationDurationUserInfoKey] floatValue];
    if (aDuration!= 0.0f)
    {
        _animationDuration = aDuration;
    }
    
    //If not enabled then do nothing.
    if ([self privateIsEnabled] == NO)	return;
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", aNotification.object]];

    //Commented due to #56. Added all the conditions below to handle WKWebView's textFields.    (Bug ID: #56)
    //  We are unable to get textField object while keyboard showing on WKWebView's textField.  (Bug ID: #11)
//    if (_textFieldView == nil)   return;

    //Restoring the contentOffset of the lastScrollView
    __strong __typeof__(UIScrollView) *strongLastScrollView = _lastScrollView;

    if (strongLastScrollView)
    {
        __weak __typeof__(self) weakSelf = self;

        [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
            
            __strong __typeof__(self) strongSelf = weakSelf;

            if (UIEdgeInsetsEqualToEdgeInsets(strongLastScrollView.contentInset, strongSelf.startingContentInsets) == NO)
            {
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring ScrollView contentInset to : %@",NSStringFromUIEdgeInsets(strongSelf.startingContentInsets)]];

                strongLastScrollView.contentInset = strongSelf.startingContentInsets;
                strongLastScrollView.scrollIndicatorInsets = strongSelf.startingScrollIndicatorInsets;
            }
            
            // TODO: restore scrollView state
            // This is temporary solution. Have to implement the save and restore scrollView state
            UIScrollView *superscrollView = strongLastScrollView;
            do
            {
                CGSize contentSize = CGSizeMake(MAX(superscrollView.contentSize.width, CGRectGetWidth(superscrollView.frame)), MAX(superscrollView.contentSize.height, CGRectGetHeight(superscrollView.frame)));
                
                CGFloat minimumY = contentSize.height-CGRectGetHeight(superscrollView.frame);
                
                if (minimumY<superscrollView.contentOffset.y)
                {
                    CGPoint newContentOffset = CGPointMake(superscrollView.contentOffset.x, minimumY);
                    if (CGPointEqualToPoint(superscrollView.contentOffset, newContentOffset) == NO)
                    {
                        [self showLog:[NSString stringWithFormat:@"Restoring contentOffset to : %@",NSStringFromCGPoint(newContentOffset)]];

                        BOOL animatedContentOffset = ([strongSelf.textFieldView superviewOfClassType:[UIStackView class] belowView:superscrollView] != nil);   //  (Bug ID: #1365, #1508, #1541)

                        if (animatedContentOffset) {
                            [superscrollView setContentOffset:newContentOffset animated:UIView.areAnimationsEnabled];
                        } else {
                            superscrollView.contentOffset = newContentOffset;
                        }
                    }
                }
            } while ((superscrollView = (UIScrollView*)[superscrollView superviewOfClassType:[UIScrollView class]]));

        } completion:NULL];
    }
    
    [self restorePosition];

    //Reset all values
    _lastScrollView = nil;
    _kbFrame = CGRectZero;
    [self notifyKeyboardSize:_kbFrame.size];
    _startingContentInsets = UIEdgeInsetsZero;
    _startingScrollIndicatorInsets = UIEdgeInsetsZero;
    _startingContentOffset = CGPointZero;

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/*  UIKeyboardDidHideNotification. So topViewBeginRect can be set to CGRectZero. */
- (void)keyboardDidHide:(NSNotification*)aNotification
{
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", aNotification.object]];

    _topViewBeginOrigin = kIQCGPointInvalid;

    _kbFrame = CGRectZero;
    [self notifyKeyboardSize:_kbFrame.size];

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

-(void)registerKeyboardSizeChangeWithIdentifier:(nonnull id<NSCopying>)identifier sizeHandler:(void (^_Nonnull)(CGSize size))sizeHandler
{
    _keyboardSizeObservers[identifier] = sizeHandler;
}

-(void)unregisterKeyboardSizeChangeWithIdentifier:(nonnull id<NSCopying>)identifier
{
    _keyboardSizeObservers[identifier] = nil;
}

-(void)notifyKeyboardSize:(CGSize)size
{
    if (!CGSizeEqualToSize(size, _keyboardLastNotifySize)) {
        _keyboardLastNotifySize = size;
        for (SizeBlock block in _keyboardSizeObservers.allValues) {
            block(size);
        }
    }
}

#pragma mark - UITextFieldView Delegate methods
/**  UITextFieldTextDidBeginEditingNotification, UITextViewTextDidBeginEditingNotification. Fetching UITextFieldView object. */
-(void)textFieldViewDidBeginEditing:(NSNotification*)notification
{
    UIView *object = (UIView*)notification.object;
    if (object.window.isKeyWindow == NO) {
        return;
    }

    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", notification.object]];

    //  Getting object
    _textFieldView = object;
    
    UIView *textFieldView = _textFieldView;

    //Adding Geture recognizer to window    (Enhancement ID: #14)
    [_resignFirstResponderGesture setEnabled:[self privateShouldResignOnTouchOutside]];
    [textFieldView.window addGestureRecognizer:_resignFirstResponderGesture];

    if ([self privateIsEnabled] == NO)
    {
        [self restorePosition];
        _topViewBeginOrigin = kIQCGPointInvalid;
    }
    else
    {
        if (CGPointEqualToPoint(_topViewBeginOrigin, kIQCGPointInvalid))    //  (Bug ID: #5)
        {
            //  keyboard is not showing(At the beginning only).
            UIViewController *rootController = [textFieldView parentContainerViewController];
            _rootViewController = rootController;
            
            if (_rootViewControllerWhilePopGestureRecognizerActive == rootController)
            {
                _topViewBeginOrigin = _topViewBeginOriginWhilePopGestureRecognizerActive;
            }
            else
            {
                _topViewBeginOrigin = rootController.view.frame.origin;
            }
            
            _rootViewControllerWhilePopGestureRecognizerActive = nil;
            _topViewBeginOriginWhilePopGestureRecognizerActive = kIQCGPointInvalid;
            
            [self showLog:[NSString stringWithFormat:@"Saving %@ beginning origin: %@",rootController, NSStringFromCGPoint(_topViewBeginOrigin)]];
        }
        
        //If textFieldView is inside AlertView then do nothing. (Bug ID: #37, #74, #76)
        //See notes:- https://developer.apple.com/library/ios/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html If it is AlertView textField then do not affect anything (Bug ID: #70).
        if (_keyboardShowing == YES &&
            textFieldView &&
            [textFieldView isAlertViewTextField] == NO)
        {
            //  keyboard is already showing. adjust frame.
            [self optimizedAdjustPosition];
        }
    }
    
//    if ([textFieldView isKindOfClass:[UITextField class]])
//    {
//        [(UITextField*)textFieldView addTarget:self action:@selector(editingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

/**  UITextFieldTextDidEndEditingNotification, UITextViewTextDidEndEditingNotification. Removing fetched object. */
-(void)textFieldViewDidEndEditing:(NSNotification*)notification
{
    UIView *object = (UIView*)notification.object;
    if (object.window.isKeyWindow == NO) {
        return;
    }

    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", notification.object]];

    UIView *textFieldView = _textFieldView;

    //Removing gesture recognizer   (Enhancement ID: #14)
    [textFieldView.window removeGestureRecognizer:_resignFirstResponderGesture];
    
//    if ([textFieldView isKindOfClass:[UITextField class]])
//    {
//        [(UITextField*)textFieldView removeTarget:self action:@selector(editingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//    }

    // We check if there's a change in original frame or not.
    if(_isTextViewContentInsetChanged == YES &&
       [textFieldView respondsToSelector:@selector(isEditable)] && [textFieldView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *textView = (UIScrollView*)textFieldView;
        self.isTextViewContentInsetChanged = NO;
        if (UIEdgeInsetsEqualToEdgeInsets(textView.contentInset, self.startingTextViewContentInsets) == NO)
        {
            __weak __typeof__(self) weakSelf = self;
            
            [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                __strong __typeof__(self) strongSelf = weakSelf;
                
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring textView.contentInset to : %@",NSStringFromUIEdgeInsets(strongSelf.startingTextViewContentInsets)]];
                
                //Setting textField to it's initial contentInset
                textView.contentInset = strongSelf.startingTextViewContentInsets;
                textView.scrollIndicatorInsets = strongSelf.startingTextViewScrollIndicatorInsets;
                
            } completion:NULL];
        }
    }


    //Setting object to nil
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
    if (@available(iOS 16.0, *)) {
        if ([textFieldView isKindOfClass:[UITextView class]] && [(UITextView*)textFieldView isFindInteractionEnabled]) {
            //Not setting it nil, because it may be doing find interaction.
            //As of now, here textView.findInteraction.isFindNavigatorVisible returns NO
            //So there is no way to detect if this is dismissed due to findInteraction
        } else {
            textFieldView = nil;
        }
    } else
#endif
    {
        textFieldView = nil;
    }

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

//-(void)editingDidEndOnExit:(UITextField*)textField
//{
//    [self showLog:[NSString stringWithFormat:@"ReturnKey %@",NSStringFromSelector(_cmd)]];
//}

#pragma mark - UIStatusBar Notification methods
/**  UIApplicationWillChangeStatusBarOrientationNotification. Need to set the textView to it's original position. If any frame changes made. (Bug ID: #92)*/
- (void)willChangeStatusBarOrientation:(NSNotification*)aNotification
{
    UIInterfaceOrientation currentStatusBarOrientation = UIInterfaceOrientationUnknown;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        currentStatusBarOrientation = [self keyWindow].windowScene.interfaceOrientation;
    } else
#endif
    {
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 130000
        currentStatusBarOrientation = UIApplication.sharedApplication.statusBarOrientation;
#endif
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    UIInterfaceOrientation statusBarOrientation = [aNotification.userInfo[UIApplicationStatusBarOrientationUserInfoKey] integerValue];
#pragma clang diagnostic pop
    
    if (statusBarOrientation != currentStatusBarOrientation) {
        return;
    }
    
    CFTimeInterval startTime = CACurrentMediaTime();
    [self showLog:[NSString stringWithFormat:@">>>>> %@ started >>>>>",NSStringFromSelector(_cmd)] indentation:1];

    [self showLog:[NSString stringWithFormat:@"Notification Object: %@", aNotification.object]];

    __strong __typeof__(UIView) *strongTextFieldView = _textFieldView;

    //If textViewContentInsetChanged is changed then restore it.
    if (_isTextViewContentInsetChanged == YES &&
        [strongTextFieldView respondsToSelector:@selector(isEditable)] && [strongTextFieldView isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *textView = (UIScrollView*)strongTextFieldView;
        self.isTextViewContentInsetChanged = NO;
        if (UIEdgeInsetsEqualToEdgeInsets(textView.contentInset, self.startingTextViewContentInsets) == NO)
        {
            __weak __typeof__(self) weakSelf = self;
            
            //Due to orientation callback we need to set it's original position.
            [UIView animateWithDuration:_animationDuration delay:0 options:(_animationCurve|UIViewAnimationOptionBeginFromCurrentState) animations:^{
                
                __strong __typeof__(self) strongSelf = weakSelf;
                
                [strongSelf showLog:[NSString stringWithFormat:@"Restoring textView.contentInset to : %@",NSStringFromUIEdgeInsets(strongSelf.startingTextViewContentInsets)]];
                
                //Setting textField to it's initial contentInset
                textView.contentInset = strongSelf.startingTextViewContentInsets;
                textView.scrollIndicatorInsets = strongSelf.startingTextViewScrollIndicatorInsets;
            } completion:NULL];
        }
    }

    [self restorePosition];

    CFTimeInterval elapsedTime = CACurrentMediaTime() - startTime;
    [self showLog:[NSString stringWithFormat:@"<<<<< %@ ended: %g seconds <<<<<",NSStringFromSelector(_cmd),elapsedTime] indentation:-1];
}

#pragma mark AutoResign methods

/** Resigning on tap gesture. */
- (void)tapRecognized:(UITapGestureRecognizer*)gesture  // (Enhancement ID: #14)
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        //Resigning currently responder textField.
        [self resignFirstResponder];
    }
}

/** Note: returning YES is guaranteed to allow simultaneous recognition. returning NO is not guaranteed to prevent simultaneous recognition, as the other gesture's delegate may return YES. */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

/** To not detect touch events in a subclass of UIControl, these may have added their own selector for specific work */
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    //  Should not recognize gesture if the clicked view is either UIControl or UINavigationBar(<Back button etc...)    (Bug ID: #145)
    for (Class aClass in self.touchResignedGestureIgnoreClasses)
    {
        if ([[touch view] isKindOfClass:aClass])
        {
            return NO;
        }
    }

    return YES;
}

/** Resigning textField. */
- (BOOL)resignFirstResponder
{
    UIView *textFieldView = _textFieldView;

    if (textFieldView)
    {
        //  Retaining textFieldView
        UIView *textFieldRetain = textFieldView;
        
        //Resigning first responder
        BOOL isResignFirstResponder = [textFieldView resignFirstResponder];
        
        //  If it refuses then becoming it as first responder again.    (Bug ID: #96)
        if (isResignFirstResponder == NO)
        {
            //If it refuses to resign then becoming it first responder again for getting notifications callback.
            [textFieldRetain becomeFirstResponder];
            
            [self showLog:[NSString stringWithFormat:@"Refuses to Resign first responder: %@",textFieldView]];
        }
        
        return isResignFirstResponder;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Customised textField/textView support.

/**
 Add customised Notification for third party customised TextField/TextView.
 */
-(void)registerTextFieldViewClass:(nonnull Class)aClass
  didBeginEditingNotificationName:(nonnull NSString *)didBeginEditingNotificationName
    didEndEditingNotificationName:(nonnull NSString *)didEndEditingNotificationName
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidBeginEditing:) name:didBeginEditingNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldViewDidEndEditing:) name:didEndEditingNotificationName object:nil];
}

/**
 Remove customised Notification for third party customised TextField/TextView.
 */
-(void)unregisterTextFieldViewClass:(nonnull Class)aClass
    didBeginEditingNotificationName:(nonnull NSString *)didBeginEditingNotificationName
      didEndEditingNotificationName:(nonnull NSString *)didEndEditingNotificationName
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:didBeginEditingNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:didEndEditingNotificationName object:nil];
}

-(void)registerAllNotifications
{
    //  Registering for keyboard notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    
    //  Registering for UITextField notification.
    [self registerTextFieldViewClass:[UITextField class]
     didBeginEditingNotificationName:UITextFieldTextDidBeginEditingNotification
       didEndEditingNotificationName:UITextFieldTextDidEndEditingNotification];
    
    //  Registering for UITextView notification.
    [self registerTextFieldViewClass:[UITextView class]
     didBeginEditingNotificationName:UITextViewTextDidBeginEditingNotification
       didEndEditingNotificationName:UITextViewTextDidEndEditingNotification];
    
    //  Registering for orientation changes notification
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
#pragma clang diagnostic pop
}

-(void)unregisterAllNotifications
{
    //  Unregistering for keyboard notification.
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];

    //  Unregistering for UITextField notification.
    [self unregisterTextFieldViewClass:[UITextField class]
     didBeginEditingNotificationName:UITextFieldTextDidBeginEditingNotification
       didEndEditingNotificationName:UITextFieldTextDidEndEditingNotification];
    
    //  Unregistering for UITextView notification.
    [self unregisterTextFieldViewClass:[UITextView class]
     didBeginEditingNotificationName:UITextViewTextDidBeginEditingNotification
       didEndEditingNotificationName:UITextViewTextDidEndEditingNotification];
    
    //  Unregistering for orientation changes notification
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:[UIApplication sharedApplication]];
#pragma clang diagnostic pop
}

-(void)showLog:(NSString*)logString
{
    [self showLog:logString indentation:0];
}

-(void)showLog:(NSString*)logString indentation:(NSInteger)indent
{
    static NSInteger indentation = 0;
    
    if (indent < 0)
    {
        indentation = MAX(0, indentation + indent);
    }
    
    if (_enableDebugging)
    {
        NSMutableString *preLog = [[NSMutableString alloc] init];
        
        for (int i = 0; i<=indentation; i++) {
            [preLog appendString:@"|\t"];
        }

        [preLog appendString:logString];
        VOLogI(VOMediaLive,@"%@",preLog);
    }
    
    if (indent > 0)
    {
        indentation += indent;
    }
}

@end


@implementation UITableView (PreviousNextIndexPath)

-(nullable NSIndexPath*)previousIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath
{
    NSInteger previousRow = indexPath.row - 1;
    NSInteger previousSection = indexPath.section;
    
    //Fixing indexPath
    if (previousRow < 0)
    {
        previousSection -= 1;
        
        if (previousSection >= 0)
        {
            previousRow = [self numberOfRowsInSection:previousSection]-1;
        }
    }
    
    if (previousRow >= 0 && previousSection >= 0)
    {
        return [NSIndexPath indexPathForRow:previousRow inSection:previousSection];
    }
    
    return nil;
}

@end

@implementation UICollectionView (PreviousNextIndexPath)

-(nullable NSIndexPath*)previousIndexPathOfIndexPath:(nonnull NSIndexPath*)indexPath
{
    NSInteger previousRow = indexPath.row - 1;
    NSInteger previousSection = indexPath.section;
    
    //Fixing indexPath
    if (previousRow < 0)
    {
        previousSection -= 1;
        
        if (previousSection >= 0)
        {
            previousRow = [self numberOfItemsInSection:previousSection]-1;
        }
    }
    
    if (previousRow >= 0 && previousSection >= 0)
    {
        return [NSIndexPath indexPathForItem:previousRow inSection:previousSection];
    }
    
    return nil;
}
@end


@implementation UIView (VELIQ_UIView_Hierarchy)

-(UIViewController*)viewContainingController
{
    UIResponder *nextResponder =  self;
    
    do
    {
        nextResponder = [nextResponder nextResponder];

        if ([nextResponder isKindOfClass:[UIViewController class]])
            return (UIViewController*)nextResponder;

    } while (nextResponder);

    return nil;
}

-(UIViewController *)topMostController
{
    NSMutableArray<UIViewController*> *controllersHierarchy = [[NSMutableArray alloc] init];
    
    UIViewController *topController = self.window.rootViewController;
    
    if (topController)
    {
        [controllersHierarchy addObject:topController];
    }
    
    while ([topController presentedViewController]) {
        
        topController = [topController presentedViewController];
        [controllersHierarchy addObject:topController];
    }
    
    UIViewController *matchController = [self viewContainingController];
    
    while (matchController && [controllersHierarchy containsObject:matchController] == NO)
    {
        do
        {
            matchController = (UIViewController*)[matchController nextResponder];
            
        } while (matchController && [matchController isKindOfClass:[UIViewController class]] == NO);
    }
    
    return matchController;
}

-(UIViewController *)parentContainerViewController
{
    UIViewController *matchController = [self viewContainingController];
    
    UIViewController *parentContainerViewController = nil;
    
    if (matchController.navigationController)
    {
        UINavigationController *navController = matchController.navigationController;
        
        while (navController.navigationController) {
            navController = navController.navigationController;
        }
        
        UIViewController *parentController = navController;
        
        UIViewController *parentParentController = parentController.parentViewController;
        
        while (parentParentController &&
               ([parentParentController isKindOfClass:[UINavigationController class]] == NO &&
                [parentParentController isKindOfClass:[UITabBarController class]] == NO &&
                [parentParentController isKindOfClass:[UISplitViewController class]] == NO))
        {
            parentController = parentParentController;
            parentParentController = parentController.parentViewController;
        }

        if (navController == parentController)
        {
            parentContainerViewController = navController.topViewController;
        }
        else
        {
            parentContainerViewController = parentController;
        }
    }
    else if (matchController.tabBarController)
    {
        if ([matchController.tabBarController.selectedViewController isKindOfClass:[UINavigationController class]])
        {
            parentContainerViewController = [(UINavigationController*)matchController.tabBarController.selectedViewController topViewController];
        }
        else
        {
            parentContainerViewController = matchController.tabBarController.selectedViewController;
        }
    }
    else
    {
        UIViewController *matchParentController = matchController.parentViewController;

        while (matchParentController &&
               ([matchParentController isKindOfClass:[UINavigationController class]] == NO &&
                [matchParentController isKindOfClass:[UITabBarController class]] == NO &&
                [matchParentController isKindOfClass:[UISplitViewController class]] == NO))
        {
            matchController = matchParentController;
            matchParentController = matchController.parentViewController;
        }
        
        parentContainerViewController = matchController;
    }
    
    UIViewController *finalController = parentContainerViewController;
    
    return finalController;
}

-(UIView*)superviewOfClassType:(nonnull Class)classType
{
    return [self superviewOfClassType:classType belowView:nil];
}

-(nullable __kindof UIView*)superviewOfClassType:(nonnull Class)classType belowView:(nullable UIView*)belowView
{
    UIView *superview = self.superview;
    
    while (superview)
    {
        if ([superview isKindOfClass:classType])
        {
            //If it's UIScrollView, then validating for special cases
            if ([superview isKindOfClass:[UIScrollView class]])
            {
                NSString *classNameString = NSStringFromClass([superview class]);

                //  If it's not UITableViewWrapperView class, this is internal class which is actually manage in UITableview. The speciality of this class is that it's superview is UITableView.
                //  If it's not UITableViewCellScrollView class, this is internal class which is actually manage in UITableviewCell. The speciality of this class is that it's superview is UITableViewCell.
                //If it's not _UIQueuingScrollView class, actually we validate for _ prefix which usually used by Apple internal classes
                if ([superview.superview isKindOfClass:[UITableView class]] == NO &&
                    [superview.superview isKindOfClass:[UITableViewCell class]] == NO &&
                    [classNameString hasPrefix:@"_"] == NO)
                {
                    return superview;
                }
            }
            else
            {
                return superview;
            }
        }
        else if (belowView == superview)
        {
            return nil;
        }
        
        superview = superview.superview;
    }
    
    return nil;
}

-(BOOL)_IQcanBecomeFirstResponder
{
    BOOL _IQcanBecomeFirstResponder = NO;
    
    if ([self conformsToProtocol:@protocol(UITextInput)]) {
        if ([self respondsToSelector:@selector(isEditable)] && [self isKindOfClass:[UIScrollView class]])
        {
            _IQcanBecomeFirstResponder = [(UITextView*)self isEditable];
        }
        else if ([self respondsToSelector:@selector(isEnabled)])
        {
            _IQcanBecomeFirstResponder = [(UITextField*)self isEnabled];
        }
    }
    
    if (_IQcanBecomeFirstResponder == YES)
    {
        _IQcanBecomeFirstResponder = ([self isUserInteractionEnabled] && ![self isHidden] && [self alpha]!=0.0 && ![self isAlertViewTextField]  && !self.textFieldSearchBar);
    }
    
    return _IQcanBecomeFirstResponder;
}


-(CGAffineTransform)convertTransformToView:(UIView*)toView
{
    if (toView == nil)
    {
        toView = self.window;
    }
    
    CGAffineTransform myTransform = CGAffineTransformIdentity;
    
    //My Transform
    {
        UIView *superView = [self superview];
        
        if (superView)  myTransform = CGAffineTransformConcat(self.transform, [superView convertTransformToView:nil]);
        else            myTransform = self.transform;
    }
    
    CGAffineTransform viewTransform = CGAffineTransformIdentity;
    
    //view Transform
    {
        UIView *superView = [toView superview];
        
        if (superView)  viewTransform = CGAffineTransformConcat(toView.transform, [superView convertTransformToView:nil]);
        else if (toView)  viewTransform = toView.transform;
    }
    
    return CGAffineTransformConcat(myTransform, CGAffineTransformInvert(viewTransform));
}


- (NSInteger)depth
{
    NSInteger depth = 0;
    
    if ([self superview])
    {
        depth = [[self superview] depth] + 1;
    }
    
    return depth;
}

- (NSString *)subHierarchy
{
    NSMutableString *debugInfo = [[NSMutableString alloc] initWithString:@"\n"];
    NSInteger depth = [self depth];
    
    for (int counter = 0; counter < depth; counter ++)  [debugInfo appendString:@"|  "];
    
    [debugInfo appendString:[self debugHierarchy]];
    
    for (UIView *subview in self.subviews)
    {
        [debugInfo appendString:[subview subHierarchy]];
    }
    
    return debugInfo;
}

- (NSString *)superHierarchy
{
    NSMutableString *debugInfo = [[NSMutableString alloc] init];

    if (self.superview)
    {
        [debugInfo appendString:[self.superview superHierarchy]];
    }
    else
    {
        [debugInfo appendString:@"\n"];
    }
    
    NSInteger depth = [self depth];
    
    for (int counter = 0; counter < depth; counter ++)  [debugInfo appendString:@"|  "];
    
    [debugInfo appendString:[self debugHierarchy]];

    [debugInfo appendString:@"\n"];
    
    return debugInfo;
}

-(NSString *)debugHierarchy
{
    NSMutableString *debugInfo = [[NSMutableString alloc] init];

    [debugInfo appendFormat:@"%@: ( %.0f, %.0f, %.0f, %.0f )",NSStringFromClass([self class]), CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)];
    
    if ([self isKindOfClass:[UIScrollView class]])
    {
        UIScrollView *scrollView = (UIScrollView*)self;
        [debugInfo appendFormat:@"%@: ( %.0f, %.0f )",NSStringFromSelector(@selector(contentSize)),scrollView.contentSize.width,scrollView.contentSize.height];
    }
    
    if (CGAffineTransformEqualToTransform(self.transform, CGAffineTransformIdentity) == false)
    {
        [debugInfo appendFormat:@"%@: %@",NSStringFromSelector(@selector(transform)),NSStringFromCGAffineTransform(self.transform)];
    }
    
    return debugInfo;
}

-(UISearchBar *)textFieldSearchBar
{
    UIResponder *searchBar = [self nextResponder];
    
    while (searchBar)
    {
        if ([searchBar isKindOfClass:[UISearchBar class]])
        {
            return (UISearchBar*)searchBar;
        }
        else if ([searchBar isKindOfClass:[UIViewController class]])    //If found viewcontroller but still not found UISearchBar then it's not the search bar textfield
        {
            break;
        }
        
        searchBar = [searchBar nextResponder];
    }
    
    return nil;
}

-(BOOL)isAlertViewTextField
{
    UIResponder *alertViewController = [self viewContainingController];
    
    BOOL isAlertViewTextField = NO;
    while (alertViewController && isAlertViewTextField == NO)
    {
        if ([alertViewController isKindOfClass:[UIAlertController class]])
        {
            isAlertViewTextField = YES;
            break;
        }

        alertViewController = [alertViewController nextResponder];
    }
    
    return isAlertViewTextField;
}

@end

@implementation NSObject (VELIQ_Logging)

-(NSString *)_IQDescription
{
    return [NSString stringWithFormat:@"<%@ %p>",NSStringFromClass([self class]),self];
}

@end
