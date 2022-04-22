//
//  Mediator+Mediator.h
//  PageManagerDemo
//  V1.0.2
//  Created by qiumx on 16/8/17.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PageManager.h"
#import "TargetAction.h"
#import "MDManager.h"
#import "UIConnector.h"
#import "ServiceCenter.h"
#import "MediatorCategory.h"
#import "ParamSession.h"
#import "MediatorDefine.h"
#import "MetaMarco.h"
#import "BaseDefaults.h"

typedef enum : NSUInteger {
    MediatorLoginReasonNone = 0,
    MediatorLoginReasonTokenExpired,
    MediatorLoginReasonLoginRemotely,
} MediatorLoginReason;
typedef void(^MediatorLoginBlock)(void(^ _Nullable completionCallback)(BOOL success), MediatorLoginReason reason);

NS_ASSUME_NONNULL_BEGIN
@interface Mediator : NSObject
AS_SINGLETON;
/**
 * 从bundle 目录加载所有的bundle配置文件
 * @return 检查拷贝完成返回YES
 */
+ (BOOL)loadAllLocalBundleConfig;

/**
 * 配置登录代码块，needLogin属性需要配置loginBlock才能生效
 * @param loginBlock 登录代码块（静态持有，注意block中使用的变量）
 */
+ (void)configLoginBlock:(MediatorLoginBlock)loginBlock;
/* 获取loginBlock */
+ (MediatorLoginBlock)getLoginBlock;

/**
 *  判断某个URL能否导航
 * `注意:`如果有原生页面匹配这返回YES，否则NO
 */
+ (BOOL)canRouteURL:(nonnull NSURL *)URL;
+ (BOOL)canRouteURL:(NSURL *)URL withItemBlock:(nullable CanRouterBlock)itemBlock;

/**
 *  通过URL直接完成页面跳转
 */
+ (BOOL)routeURL:(nonnull NSURL *)URL;
+ (BOOL)routeURL:(nonnull NSURL *)URL withParams:(nullable NSDictionary *)params;
+ (BOOL)routeURL:(nonnull NSURL *)URL withParams:(nullable NSDictionary *)params completion:(void(^ _Nullable)(id _Nullable result))completion;
/**
 *  多个页面
 */
+ (BOOL)routeURLs:(nonnull NSArray *)URLs withParams:(nullable NSDictionary *)params completion:(void(^ _Nullable)(id _Nullable result))completion;
/**
 *  多个页面,同时pop最近的几个ViewController
 */
+ (BOOL)routeURLs:(NSArray *)URLs withParams:(NSDictionary *)params popViewControllerCount:(NSInteger)popCount completion:(void (^)(id result))completion;
+ (BOOL)routeURLs:(NSArray *)URLs withParams:(NSDictionary *)params popURLs:(NSArray *)popURLs completion:(void (^)(id result))completion;

/**
 *  通过URL获取viewController实例
 */
+ (nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL;
+ (nullable UIViewController *)viewControllerForURL:(nonnull NSURL *)URL withParams:(nullable NSDictionary *)params;

/*
 *  获取当前ViewController
 */
+ (UIViewController *)topmostViewController;
/*
 *  获取当前NavigationController
 */
+ (UINavigationController *)topmostNavigationController;
/*
 * 返回到RootViewController，包含dismiss所有present VC
 */
+ (void)backToRootViewControllerCompletion:(void (^ __nullable)(void))completion;
/*
 *  dismiss所有present VC
 */
+ (void)dismissAllPresentedViewControllerAnimated:(BOOL)animated completion:(void (^ __nullable)(void)) completion;

/**
 *  通过服务名获取服务
 */
+ (nullable id)getService:(nullable NSString *)serviceName;

@end

@interface Mediator (Extension)

/*
 拦截某些类名的跳转，ex：web容器要访问已经配置原生界面的url
 */
+ (NSURL*)interceptClassName:(NSString *)className withParams:(NSDictionary *)params;
@end
NS_ASSUME_NONNULL_END
