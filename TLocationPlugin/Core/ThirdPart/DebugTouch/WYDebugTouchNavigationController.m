//
//  WYDebugTouchNavigationController.m
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/15.
//
//

#import <objc/message.h>

#import "XFAssistiveTouch.h"
#import "WYDebugTouchMarco.h"
#import "HSADebugTouchTemp.h"
#import "WYDebugTouchNavigationController.h"

@implementation WYDebugTouchNavigationController

- (void)loadView {
    [super loadView];
}


- (void)timerFired {
    [UIView animateWithDuration:[XFATLayoutAttributes animationDuration] animations:^{
        [self setValue:@([XFATLayoutAttributes inactiveAlpha]) forKey:@"contentAlpha"];
    }];
    [super wy_performSelectorWithArgsWithSelectorName:@"stopTimer"];
    
    [self indent];
}

- (void)indent{
    if (!self.autoIndent) {
        return;
    }
    CGRect windowRect = [[[XFAssistiveTouch sharedInstance] assistiveWindow] frame];
    BOOL isLeft = windowRect.origin.x < 5;
    BOOL isRight = windowRect.origin.x + windowRect.size.width > SCREENWIDTH - 5 ;
    BOOL isTop = windowRect.origin.y < 5;
    BOOL isBottom = windowRect.origin.y + windowRect.size.height > SCREENHEIGHT - 5;
    
    if (isLeft) {
        windowRect.origin.x = - windowRect.size.width / 2;
    }
    
    if (isRight) {
        windowRect.origin.x = SCREENWIDTH - windowRect.size.width / 2;
    }
    
    if (isTop) {
        windowRect.origin.y = - windowRect.size.width / 2;
    }
    
    if (isBottom) {
        windowRect.origin.y = SCREENHEIGHT - windowRect.size.width / 2;
    }
    
    [UIView animateWithDuration:[XFATLayoutAttributes animationDuration] animations:^{
        [[[XFAssistiveTouch sharedInstance] assistiveWindow] setFrame:windowRect];
    }];
}

- (void)showWithAnimation:(BOOL)anmiated {
    if (anmiated) {
        [UIView animateWithDuration:[XFATLayoutAttributes animationDuration] animations:^{
            [[[XFAssistiveTouch sharedInstance] assistiveWindow] setHidden:false];
        }];
    }else{
        [[[XFAssistiveTouch sharedInstance] assistiveWindow] setHidden:false];
    }
}

- (void)dismissWithAnimation:(BOOL)anmiated {
    if (anmiated) {
        [UIView animateWithDuration:[XFATLayoutAttributes animationDuration] animations:^{
            [[[XFAssistiveTouch sharedInstance] assistiveWindow] setHidden:true];
        }];
    }else{
        [[[XFAssistiveTouch sharedInstance] assistiveWindow] setHidden:true];
    }
}

- (BOOL)windowIsHidden {
    return [[[XFAssistiveTouch sharedInstance] assistiveWindow] isHidden];
}

- (void)spread{
    [super spread];
    [WYDebugTouch refreshAllModuleState];
}

@end
