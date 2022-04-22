//
//  MDManager.m
//  MediatorDemo
//
//  Created by qiumx on 2016/11/3.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import "MDManager.h"

@interface MDManager ()
@property (nonatomic, strong) NSMutableSet<id<ModuleDelegate>> *modules;
@end

@implementation MDManager
DEF_SINGLETON;

- (NSMutableSet<id<ModuleDelegate>> *)modules {
    if (!_modules) {
        _modules = [[NSMutableSet alloc] init];
    }
    return _modules;
}

- (void)addModule:(id<ModuleDelegate>)module {
    if (module
        &&[module conformsToProtocol:@protocol(ModuleDelegate)]) {
        [self.modules addObject:module];
    }
}

- (void)performDelegateSelector:(SEL)selector, ... {
    // 区分代理分发优先级
    NSMutableDictionary <NSNumber *, NSMutableArray *> *moduleInfos = @{}.mutableCopy;
    
    for (id<ModuleDelegate> module in self.modules) {
        ModuleDlegatePriority priority = ModuleDlegatePriorityNormal;
        if ([module respondsToSelector:@selector(priority)]) {
            priority = module.priority;
        }
        NSMutableArray *modules = moduleInfos[@(priority)] ?: @[].mutableCopy;
        [modules addObject:module];
        moduleInfos[@(priority)] = modules;
    }
    
    NSMutableArray *descendModules = @[].mutableCopy;
    NSArray *descendKeys = [moduleInfos.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj2 compare:obj1];
    }];
    for (NSNumber *modulePriorityKey in descendKeys) {
        [descendModules addObjectsFromArray:moduleInfos[modulePriorityKey]];
    }
    
    for (id<ModuleDelegate> module in descendModules) {
        if ([module respondsToSelector:selector]&&[module isKindOfClass:[NSObject class]]) {
            va_list args;
            va_start(args, selector);
            NSObject *moduleObj = (NSObject*)module;
            NSMethodSignature * sig = [moduleObj methodSignatureForSelector:selector];
            if (!sig) { [moduleObj doesNotRecognizeSelector:selector]; continue; }
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            if (!inv) { [moduleObj doesNotRecognizeSelector:selector]; continue; }
            [inv setTarget:moduleObj];
            [inv setSelector:selector];
            [NSObject md_setInv:inv withSig:sig andArgs:args];
            [inv invoke];
        }
    }
}

- (void)performDelegateBlock:(void (^)(id<ModuleDelegate> _Nonnull, id _Nonnull, BOOL * _Nonnull))block selector:(SEL)selector, ... {
    BOOL stop = NO;
    for (id<ModuleDelegate> module in self.modules) {
        if ([module respondsToSelector:selector]&&[module isKindOfClass:[NSObject class]]) {
            va_list args;
            va_start(args, selector);
            NSObject *moduleObj = (NSObject*)module;
            NSMethodSignature * sig = [moduleObj methodSignatureForSelector:selector];
            if (!sig) { [moduleObj doesNotRecognizeSelector:selector]; continue; }
            NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
            if (!inv) { [moduleObj doesNotRecognizeSelector:selector]; continue; }
            [inv setTarget:moduleObj];
            [inv setSelector:selector];
            [NSObject md_setInv:inv withSig:sig andArgs:args];
            [inv invoke];
            block(module, [NSObject md_getReturnFromInv:inv withSig:sig], &stop);
            if (stop) {
                break;
            }
        }
    }
}

@end
