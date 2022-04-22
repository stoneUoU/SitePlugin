//
//  WYDebugTouchNavigationController.h
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/15.
//
//

#import <Foundation/Foundation.h>
#import "XFATNavigationController.h"

@interface WYDebugTouchNavigationController : XFATNavigationController

/**
 是否自动Window内缩，默认是
 */
@property (nonatomic) BOOL autoIndent;

/**
 使得Window内缩
 */
- (void)indent;


/**
 消失
 */
- (void)dismissWithAnimation:(BOOL)anmiated;


/**
 显示
 */
- (void)showWithAnimation:(BOOL)anmiated;

- (BOOL)windowIsHidden;

@end
