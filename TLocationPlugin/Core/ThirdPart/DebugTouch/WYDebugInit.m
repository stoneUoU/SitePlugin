//
//  WYDebugInit.m
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/18.
//  Copyright © 2022 TBD. All rights reserved.
//

#import "WYDebugInit.h"
#import "WYDebugTouch.h"

@implementation WYDebugInit

+ (void)load {
    if (![WYDebugTouch isEnable]) {
        NSLog(@"WYDebugTouch已被其他模块关闭");
    }
}

@end
