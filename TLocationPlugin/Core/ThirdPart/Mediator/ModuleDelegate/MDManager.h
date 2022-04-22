//
//  MDManager.h
//  MediatorDemo
//
//  Created by qiumx on 2016/11/3.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModuleDelegate.h"
#import "TargetAction.h"

NS_ASSUME_NONNULL_BEGIN
@interface MDManager : NSObject
AS_SINGLETON;
- (void)addModule:(id<ModuleDelegate>)module;
- (void)performDelegateSelector:(SEL)selector, ...;
- (void)performDelegateBlock:(void(^)(id<ModuleDelegate> module, id result, BOOL *stop))block selector:(SEL)selector, ...;
@end
NS_ASSUME_NONNULL_END
