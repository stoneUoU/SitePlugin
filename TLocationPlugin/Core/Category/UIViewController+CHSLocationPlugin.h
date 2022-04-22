//
//  UIViewController+CHSLocationPlugin.h
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/8.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (CHSLocationPlugin)

/// 获取当前 viewController 的顶层 controller
@property (nonatomic, readonly) UIViewController *t_topViewController;

/// 获取 viewController 的顶层 controller
+ (UIViewController *)t_findTopViewControllerFromViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
