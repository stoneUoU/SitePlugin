//
//  CHSLocationNavigationController.m
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/5.
//  
//

#import "CHSLocationNavigationController.h"
#import "UIImage+CHSLocationPlugin.h"
#import "CHSLocationHelper.h"

@interface CHSLocationNavigationController ()

@property (nonatomic, assign) UIStatusBarStyle currentStatusBarStyle;

@end

@implementation CHSLocationNavigationController

- (void)dealloc {
    CHSLocationNavigationController.isShowing = NO;
    /// restore old style
    [UIApplication sharedApplication].statusBarStyle = self.currentStatusBarStyle;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    /// save old style
    self.currentStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.navigationBar.shadowImage = nil;
    self.navigationBar.tintColor = UIColor.whiteColor;
    self.navigationBar.tintColor = UIColor.blackColor;
    self.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: UIColor.blackColor,
        NSFontAttributeName: [UIFont boldSystemFontOfSize:17],
    };
}

#pragma mark - Setter/Getter
static BOOL _t_isShowing = NO;
+ (BOOL)isShowing {
    return _t_isShowing;
}

+ (void)setIsShowing:(BOOL)isShowing {
    _t_isShowing = isShowing;
    CHSLocationHelper.shared.suspend = isShowing;
}


- (UIModalPresentationStyle)modalPresentationStyle {
    return UIModalPresentationFullScreen;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return nil;
}

- (UIViewController *)childViewControllerForStatusBarHidden {
    return nil;
}

@end
