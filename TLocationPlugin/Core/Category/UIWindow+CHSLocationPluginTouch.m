//
//  UIWindow+CHSLocationPluginTouch.m
//  CHSLocationPlugin
//
//  Created by stone on 2019/9/4.
//  
//

#import <AudioToolbox/AudioToolbox.h>
#import "CHSLocationHelper.h"
#import "HSALocalData+hsa.h"
#import "CHSFetchLocationDataViewController.h"
#import "CHSLocationNavigationController.h"
#import "UIWindow+CHSLocationPluginTouch.h"
#import "UIApplication+CHSLocationPlugin.h"

@implementation UIWindow (CHSLocationPluginTouch)

static NSInteger _t_windowTouchedTimes = 0;

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (CHSLocationNavigationController.isShowing) {
        return;
    }
    if (_t_windowTouchedTimes == 0) {
        // 开始触摸, 5秒后清零
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _t_windowTouchedTimes = 0;
        });
    }
    ++_t_windowTouchedTimes;
    if (_t_windowTouchedTimes < 5) {
        return;
    }
    if (![HSALocalData appShake]) {
        _t_windowTouchedTimes = 0;
        return;
    }
    // 5秒内触摸5次
    CHSLocationNavigationController.isShowing = YES;
    _t_windowTouchedTimes = 0;
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIViewController *rootVC = [UIApplication sharedApplication].t_topViewController;
    CHSFetchLocationDataViewController *vc = [[CHSFetchLocationDataViewController alloc] init];
    CHSLocationNavigationController *nav = [[CHSLocationNavigationController alloc] initWithRootViewController:vc];
    [rootVC presentViewController:nav animated:YES completion:^{
        [UIApplication.sharedApplication performSelector:@selector(setStatusBarStyle:animated:) withObject:@(UIStatusBarStyleDefault) withObject:@(YES)];
    }];
}
@end
