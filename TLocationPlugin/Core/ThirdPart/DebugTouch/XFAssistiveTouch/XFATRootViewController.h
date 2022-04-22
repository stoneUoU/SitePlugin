//
//  XFATRootViewController.h
//  XFAssistiveTouchExample
//
//  Created by 徐亚非 on 2016/9/24.
//  Copyright © 2016年 XuYafei. All rights reserved.
//

#import "XFATViewController.h"
#import "WYDebugTouchModuleModel.h"

NS_ASSUME_NONNULL_BEGIN

@class XFATRootViewController;

@protocol XFATRootViewControllerDelegate <NSObject>

- (NSInteger)numberOfItemsInViewController:(XFATRootViewController *)viewController;
- (XFATItemView *)viewController:(XFATRootViewController *)viewController itemViewAtPosition:(XFATPosition *)position;
- (void)viewController:(XFATRootViewController *)viewController didSelectedAtPosition:(XFATPosition *)position;

@end

@interface XFATRootViewController : XFATViewController

@property (nonatomic, weak) id<XFATRootViewControllerDelegate> delegate;
@property (nonatomic, strong) WYDebugTouchModuleModel *model;

@end

NS_ASSUME_NONNULL_END
