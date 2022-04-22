//
//  UIApplication+CHSLocationPlugin.h
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/8.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (CHSLocationPlugin)

/// 获取 App 的顶层 controller
@property (nonatomic, readonly, nullable) UIViewController *t_topViewController;

@end

NS_ASSUME_NONNULL_END
