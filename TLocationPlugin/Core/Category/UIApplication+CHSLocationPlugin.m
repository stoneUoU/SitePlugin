//
//  UIApplication+CHSLocationPlugin.m
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/8.
//  
//

#import "UIApplication+CHSLocationPlugin.h"
#import "UIViewController+CHSLocationPlugin.h"

@implementation UIApplication (CHSLocationPlugin)

- (UIViewController *)t_topViewController {
    UIViewController *viewController = self.keyWindow.rootViewController;
    if (viewController) {
        return [UIViewController t_findTopViewControllerFromViewController:viewController];
    }
    return nil;
}

@end
