//
//  PageManager.h
//  PageManager
//
//  Created by qiumx on 15/4/21.
//  Copyright (c) 2015年 qiumx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef DEBUG
#   define PMLOG(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);

#else

#define PMLOG(...)

#endif

@interface PageManager : NSObject

// Current view controller showing on the screen
@property (weak, nonatomic) UIViewController *currentViewController;
@property (weak, nonatomic) UIViewController *currentLoadedViewController;

@property (strong, nonatomic) NSString *baseViewControllerClassName;
@property (strong, nonatomic) NSString *errorViewControllerClassName;

+ (instancetype)sharedInstance;

- (UIViewController*)pushViewController:(NSString *)viewControllerName;
- (UIViewController*)pushViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param;
- (UIViewController*)pushViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param animated:(BOOL)animated;


- (UIViewController*)popViewControllerWithParam:(NSDictionary*)param;
- (NSArray*)popToViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param;

- (NSArray*)popToLastViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param;


- (NSArray *)popToRootViewController:(NSDictionary *)param;
- (NSArray *)popToRootViewController:(NSDictionary *)param animated:(BOOL)animated;
- (UIViewController*)getCurrentShowViewController;

//..xiehx begin
- (void)popThenPushViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param animated:(BOOL)animated;

- (void)popToRootThenPushViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param animated:(BOOL)animated;

/*Discussion:
 1,The navigation pop to the nearest viewController whose className isEqual to popToViewControllerName. That means if there's two viewControllers in the navigation. it will pop to the one whose index is bigger in the navigation's viewControllers.
 2,if there's no viewController that it's class isEqual to popToViewControllerName. the method won't pop any viewController but will push newViewController.
 */
- (void)popToViewControllerThenPushViewController:(NSString *)popToViewControllerName
                                  pushedViewController:(NSString *)pushedViewControllerName
                                             withParam:(NSDictionary *)param
                                              animated:(BOOL)animated;
- (void)popCtrlsThenPushWithName:(NSArray *)popedViewControllers
              pushedViewCtrlName:(NSString *)pushedViewCtrlName
                           param:(NSDictionary *)param
                        animated:(BOOL)animated;
- (void)popCtrlsThenPushCtrls:(NSArray *)popedViewControllers
         pushedViewController:(NSArray *)pushedViewControllers
                     animated:(BOOL)animated;

//..xiehx end

- (UIViewController *)createViewControllerFromName:(NSString *)name param:(NSDictionary *)param;
- (NSString*)nibFileName:(Class)theClass;

- (void)presentViewController:(NSString *)viewControllerName;
- (void)presentViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param;
- (void)presentViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param inNavigationController:(BOOL)isInNavigationController;
- (void)presentViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param inNavigationController:(BOOL)isInNavigationController animated:(BOOL)animated;

- (void)fadeInViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param;
- (UIViewController *)fadeOutViewControllerWithParam:(NSDictionary *)param;

- (void)pushExistingViewController:(UIViewController *)viewController;
- (void)pushExistingViewController:(UIViewController *)viewController withParam:(NSDictionary *)param;
- (void)pushExistingViewController:(UIViewController *)viewController withParam:(NSDictionary *)param animated:(BOOL)animated;

@end

@interface UINavigationController (popToBeforeClass)
- (void)popToBeforeClass:(Class)theClass animated:(BOOL)animated;
@end

@interface NSArray (PageManager)

- (NSArray *)filterViewControllersWithClassName:(NSString*)className;
- (NSArray *)filterArrayForRightOfClassName:(NSString *)className containSeparator:(BOOL)containSeparator;

@end
