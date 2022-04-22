//
//  ModuleDelegate.h
//  MediatorDemo
//
//  Created by qiumx on 2016/11/3.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import <UIKit/UIKit.h>

/// 代理分发的优先级
typedef NS_ENUM(NSInteger, ModuleDlegatePriority) {
    ModuleDlegatePriorityHigh = 1000,
    ModuleDlegatePriorityNormal = 10,
};

@protocol ModuleDelegate <UIApplicationDelegate>

@optional

/// 代理分发的优先级，默认 ModuleDlegatePriorityNormal
- (ModuleDlegatePriority)priority;

@end
