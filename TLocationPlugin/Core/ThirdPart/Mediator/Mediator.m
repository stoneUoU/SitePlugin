//
//  Mediator.m
//
//  Created by qiumx on 16/8/17.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import "Mediator.h"
#import "ModuleConfig.h"
#import <objc/runtime.h>

static NSString *kDCUniMPViewControllerString = @"DCUniMPViewController";
//static NSString *kHSAHomeHotSearchViewControllerString = @"hotsearch";

static NSMutableDictionary<NSString *, UIConnector *> *md_connectorsMap = nil;
static NSMapTable *uniqueMapTable = nil;
static MediatorLoginBlock theLoginBlock;;

APP_CONSTRUCTOR_PRIORITY_NAME(101, Mediator, ^(){
    [Mediator loadAllLocalBundleConfig];
})

@interface Mediator ()
@end

@implementation Mediator
DEF_SINGLETON;

+ (BOOL)loadAllLocalBundleConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @synchronized(md_connectorsMap) {
            if (md_connectorsMap == nil){
                md_connectorsMap = [[NSMutableDictionary alloc] init];
            }
            [NSBundle allBundles];
            [NSBundle allFrameworks];
            for (NSString *path in [[NSBundle mainBundle] pathsForResourcesOfType:@"bundle" inDirectory:nil]) {
                [self loadWithBundle:[NSBundle bundleWithPath:path]];
            }
            for (NSString *fPath in [[NSBundle mainBundle] pathsForResourcesOfType:@"framework" inDirectory:nil]) {
                for (NSString *path in [[NSBundle bundleWithPath:fPath] pathsForResourcesOfType:@"bundle" inDirectory:nil]) {
                    [self loadWithBundle:[NSBundle bundleWithPath:path]];
                }
            }
        }
    });
    return YES;
}
    
+ (BOOL)loadWithBundle:(NSBundle*)bundle {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *configFromPath = [bundle pathForResource:@"moduleconfig" ofType:@"plist"];
    if (![fileManager fileExistsAtPath:configFromPath]) {
        return NO;
    }
    
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:configFromPath];
    
    if (!dic) {
        if (!dic) {//解密内容为空，则报错
#ifdef DEBUG
            NSString *message = @"您的包存在错误";
            message = [NSString stringWithFormat:@"解析错误:%@", configFromPath];
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [[Mediator topmostViewController] wm_alterTip:message];
                });
            });
#else
            
#endif
            NSLog(@"解密失败:%@", configFromPath);
        } else {
            NSLog(@"加密正常:%@", configFromPath);
        }
    } else {
        NSLog(@"加密不正常:%@", configFromPath);
    }
    
    
    if (dic&&[dic isKindOfClass:[NSDictionary class]]) {
        ModuleConfig *config = [ModuleConfig configWith:dic];
        
        if (!config.name) {
            return NO;
        }
        
        /*
         *解析delegateClass
         */
        if (config.delegateClass) {
            Class delegateClass = NSClassFromString(config.delegateClass);
            if (delegateClass&&[delegateClass conformsToProtocol:@protocol(ModuleDelegate)]) {
                [[MDManager sharedInstance] addModule:[[delegateClass alloc] init]];
            }
        }
        
        /**
         *  解析routerList配置生成对应的connector
         */
        UIConnector *connector = nil;
        Class connectorClass = NSClassFromString(config.connectorClass);
        SEL instanceSelector = NSSelectorFromString(@"connectorWith:");
        if (connectorClass&&[connectorClass isSubclassOfClass:[UIConnector class]]
            &&class_getClassMethod(connectorClass, instanceSelector)) {
            connector = [connectorClass connectorWith:config];
        } else {
            connector = [UIConnector connectorWith:config];
        }
        if (md_connectorsMap[config.name]) {
            NSAssert(NO,@"已经存在name-%@，注册错误-%@",config.name, bundle);
        }
        [md_connectorsMap setValue:connector forKey:config.name];
        
        /**
         *  解析serviceList配置并注册服务
         */
        [config.service_list enumerateObjectsUsingBlock:^(ServiceListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [ServiceCenter registerService:obj.name class:obj.className protocol:obj.protocol];
        }];
        return YES;
    }
    return NO;
}

+ (void)configLoginBlock:(MediatorLoginBlock)loginBlock {
    theLoginBlock = loginBlock;
}

+ (MediatorLoginBlock)getLoginBlock {
    return theLoginBlock;
}

#pragma mark -
+ (BOOL)canRouteURL:(NSURL *)URL {
    return [self canRouteURL:URL withItemBlock:nil];
}

+ (BOOL)canRouteURL:(NSURL *)URL withItemBlock:(CanRouterBlock)itemBlock {
   __block  RouterListItem *routerItem;
    
    /*
     自定义route处理
     */
    __block UIConnectorCustomRouteType customRouteType = UIConnectorCustomTypeNone;
    [md_connectorsMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIConnector * _Nonnull connector, BOOL * _Nonnull stop) {
        if ([connector conformsToProtocol:@protocol(UIConnectorCustomProtocol)]) {
            id<UIConnectorCustomProtocol> cProtocol = (id)connector;
            customRouteType = [cProtocol customConnectorForURL:URL complition:^(RouterListItem *_routerItem, NSDictionary *addParams) {
                routerItem = _routerItem;
            }];
            if (routerItem) {
                *stop = YES;
            }
        }
    }];
    
    switch (customRouteType) {
        case UIConnectorCustomTypeBreak:
        {
            if (itemBlock) {
                itemBlock(routerItem);
            }
            return YES;
        }
            break;
            
        case UIConnectorCustomTypeInstead:
        {
            
        }
            break;
            
        case UIConnectorCustomTypeContinue:
        default:
        {
            /*
             Web URL
             */
            if ([URL.wm_scheme isEqualToString:@"http"]
                ||[URL.wm_scheme isEqualToString:@"https"]) {
                routerItem = [UIConnector itemForWebURL:URL];
            }
            /*
             优先匹配host为模块名
             */
            NSString *host = URL.wm_host;
            UIConnector *connector = md_connectorsMap[host];
            if (!routerItem&&connector) {
                routerItem = [connector itemForURLPath:URL.wm_path];
            }
            /*
             匹配全路径
             */
            if (!routerItem) {
                NSString *URLPath = [host stringByAppendingPathComponent:URL.wm_path];
                [md_connectorsMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIConnector * _Nonnull connector, BOOL * _Nonnull stop) {
                    routerItem = [connector itemForURLPath:URLPath];
                    if (routerItem) {
                        *stop = YES;
                    }
                }];
            }
        }
            break;
    }
    if (itemBlock) {
        itemBlock(routerItem);
    }
    return routerItem?YES:NO;;
}

#pragma mark -
+ (BOOL)routeURL:(NSURL *)URL {
    return [self routeURL:URL withParams:nil];
}

+ (BOOL)routeURL:(NSURL *)URL withParams:(NSDictionary *)params {
    return [self routeURL:URL withParams:params completion:nil];
}

+ (BOOL)routeURL:(NSURL *)URL withParams:(NSDictionary *)params completion:(void (^)(id))completion {
    __block UIViewController *viewController = nil;
    __block RouterListItem *_routerItem = nil;
    
    [self viewControllerForURL:URL withParams:params complition:^(UIViewController * _Nullable vc, RouterListItem * _Nonnull routerItem) {
        viewController = vc;
        _routerItem = routerItem;
    }];
    
    if (_routerItem.needLogin && theLoginBlock) {
        //需要登录
        void (^completionCallback)(BOOL success) = ^(BOOL success) {
            if (success) {
                [Mediator openViewController:viewController withRouterItem:_routerItem];
            }
        };
        theLoginBlock(completionCallback, MediatorLoginReasonNone);
    } else {
        [Mediator openViewController:viewController withRouterItem:_routerItem];
    }
    if (completion) {
        completion(viewController);
    }
    return viewController?YES:NO;
}

+ (BOOL)openViewController:(UIViewController*)viewController withRouterItem:(RouterListItem*)routerItem {
    if (viewController) {
        if (viewController.wm_isInViewStack) {
            [viewController wm_routeToTop];
        } else {
            RouterType routerType = [UIConnector getTypeFromString:routerItem.type];
            viewController.wm_routerType = routerType;
            if ([routerItem.type containsString:@"present"] || [NSStringFromClass([Mediator.topmostViewController class]) isEqualToString:kDCUniMPViewControllerString]) {  //当uni-app存在的情况下，DCUniMPViewController中push界面无效，得present方式
                [self presentedViewController:viewController baseViewController:[Mediator topmostViewController] animated:YES];
//                [self presentedViewController:viewController baseViewController:[Mediator topmostViewController] animated:[routerItem.name isEqualToString:kHSAHomeHotSearchViewControllerString] ? NO : YES];
            }else {
                [self pushViewController:viewController baseViewController:[Mediator topmostNavigationController]];
            }
        }
        return YES;
    } else {
        return NO;
    }
}

+ (BOOL)routeURLs:(NSArray *)URLs withParams:(NSDictionary *)params completion:(void (^)(id result))completion {
    return [self routeURLs:URLs withParams:params popViewControllerCount:0 completion:completion];
}

+ (BOOL)routeURLs:(NSArray *)URLs withParams:(NSDictionary *)params popViewControllerCount:(NSInteger)popCount completion:(void (^)(id))completion {
    NSMutableArray*popVcArr = nil;
    if (popCount>0) {
        NSArray *viewControllers = [Mediator topmostNavigationController].viewControllers;
        NSInteger loc = viewControllers.count-popCount;
        //不能pop rootVC
        if (loc<1) {
            loc = 1;
        }
        popVcArr = [[viewControllers subarrayWithRange:NSMakeRange(loc, viewControllers.count-loc)] mutableCopy];
    }
    UINavigationController *navController = [Mediator topmostNavigationController];
    if (!navController) {
        return NO;
    }
    
    __block NSMutableArray *vcArr = [NSMutableArray array];
    
    [URLs enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = [self viewControllerForURL:URL withParams:params complition:^(UIViewController * _Nullable viewController, RouterListItem * _Nonnull routerItem) {
            
        }];
        if (vc) {
            vc.hidesBottomBarWhenPushed = YES;
            [vcArr addObject:vc];
        }
    }];
    
    NSMutableArray *newVCs = [[NSMutableArray alloc] initWithArray:navController.viewControllers];
    if (popVcArr.count>0) {
        [newVCs removeObjectsInArray:popVcArr];
    }
    if (vcArr.count>0) {
        for (id vc in vcArr) {
            if ([newVCs containsObject:vc]) {
                NSInteger loc = [newVCs indexOfObject:vc];
                [newVCs removeObjectsInRange:NSMakeRange(loc, newVCs.count-loc)];
            }
            [newVCs addObject:vc];
        }
    }
    [navController setViewControllers:newVCs animated:YES];
    if (completion) {
        completion(vcArr);
    }
    return YES;
}

+ (BOOL)routeURLs:(NSArray *)URLs withParams:(NSDictionary *)params popURLs:(NSArray *)popURLs completion:(void (^)(id result))completion {
    __block NSMutableArray *vcArr = [NSMutableArray array];
    [URLs enumerateObjectsUsingBlock:^(NSURL *URL, NSUInteger idx, BOOL * _Nonnull stop) {
        UIViewController *vc = [self viewControllerForURL:URL withParams:params complition:^(UIViewController * _Nullable viewController, RouterListItem * _Nonnull routerItem) {
            
        }];
        if (vc) {
            vc.hidesBottomBarWhenPushed = YES;
            [vcArr addObject:vc];
        }
    }];
    __block NSMutableArray*popVcArr = [NSMutableArray array];
    NSArray *viewControllers = [Mediator topmostNavigationController].viewControllers;
    [popURLs enumerateObjectsUsingBlock:^(NSURL *popURL, NSUInteger idx, BOOL * _Nonnull stop) {
       [Mediator canRouteURL:popURL withItemBlock:^(RouterListItem * _Nonnull routerItem) {
           if (routerItem.className) {
               NSArray *filterVCs = [viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                   return NSClassFromString(routerItem.className)&&[evaluatedObject isMemberOfClass:NSClassFromString(routerItem.className)];
               }]];
               [popVcArr addObjectsFromArray:filterVCs];
           }
       }];
    }];
    UINavigationController *navController = [Mediator topmostNavigationController];
    if (!navController) {
        return NO;
    }
    
    NSMutableArray *newVCs = [[NSMutableArray alloc] initWithArray:navController.viewControllers];
    if (popVcArr.count>0) {
        [newVCs removeObjectsInArray:popVcArr];
    }
    if (vcArr.count>0) {
        for (id vc in vcArr) {
            if ([newVCs containsObject:vc]) {
                NSInteger loc = [newVCs indexOfObject:vc];
                [newVCs removeObjectsInRange:NSMakeRange(loc, newVCs.count-loc)];
            }
            [newVCs addObject:vc];
        }
    }
    [navController setViewControllers:newVCs animated:YES];
    if (completion) {
        completion(vcArr);
    }
    return YES;
}

#pragma mark -

+ (UIViewController *)viewControllerForURL:(NSURL *)URL {
    return [self viewControllerForURL:URL withParams:nil];
}

+ (UIViewController *)viewControllerForURL:(NSURL *)URL withParams:(NSDictionary *)params {
    return [self viewControllerForURL:URL withParams:params complition:NULL];
}

+ (UIViewController *)viewControllerForURL:(NSURL *)URL withParams:(NSDictionary *)oParams complition:(RouterBlock)block {
    __block NSMutableDictionary *params = oParams?oParams.mutableCopy:[NSMutableDictionary dictionary];
    __block RouterListItem *routerItem = nil;
    /*
     自定义拦截处理
     */
    __block BOOL isHandleCustomAction = NO;
    [md_connectorsMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIConnector * _Nonnull connector, BOOL * _Nonnull stop) {
        if ([connector isHandleCustomActionForURL:URL withParams:params]) {
            isHandleCustomAction = YES;
            *stop = YES;
        }
    }];
    if (isHandleCustomAction) {
        if (block) {
            block(nil, nil);
        }
        return nil;
    }
    
    /*
     自定义route处理
     */
    __block UIConnectorCustomRouteType customRouteType = UIConnectorCustomTypeNone;
    [md_connectorsMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIConnector * _Nonnull connector, BOOL * _Nonnull stop) {
        if ([connector conformsToProtocol:@protocol(UIConnectorCustomProtocol)]) {
            id<UIConnectorCustomProtocol> cProtocol = (id)connector;
            customRouteType = [cProtocol customConnectorForURL:URL complition:^(RouterListItem *_routerItem, NSDictionary *addParams) {
                routerItem = _routerItem;
                if (addParams) {
                    [params addEntriesFromDictionary:addParams];
                }
            }];
            if (routerItem) {
                *stop = YES;
            }
        }
    }];
    
    BOOL isWebURL = NO;
    switch (customRouteType) {
        case UIConnectorCustomTypeBreak:
        {
            if (block) {
                block(nil, nil);
            }
            return nil;
        }
            break;
            
        case UIConnectorCustomTypeInstead:
        {
            
        }
            break;
         
        case UIConnectorCustomTypeContinue:
        default:
        {
            /*
             Web URL
             */
            if ([URL.wm_scheme isEqualToString:@"http"]
                ||[URL.wm_scheme isEqualToString:@"https"]) {
                isWebURL = YES;
                routerItem = [UIConnector itemForWebURL:URL];
                /*
                 不能处理的Web URL，则使用Web容器打开
                 */
                if (routerItem == nil) {
                    NSMutableDictionary *mParams = params?[params mutableCopy]:[NSMutableDictionary dictionary];
                    mParams[@"requestURL"] = [URL absoluteString];
                    return [self viewControllerForURL:URL(@"hsaweb/base") withParams:mParams complition:block];
                }
            }
            
            /*
             优先匹配host为模块名
             */
            NSString *host = URL.wm_host;
            UIConnector *connector = md_connectorsMap[host];
            if (!routerItem&&connector) {
                routerItem = [connector itemForURLPath:URL.wm_path];
            }
            /*
             匹配全路径
             */
            if (!routerItem) {
                NSString *URLPath = [host stringByAppendingPathComponent:URL.wm_path];
                [md_connectorsMap enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, UIConnector * _Nonnull connector, BOOL * _Nonnull stop) {
                    routerItem = [connector itemForURLPath:URLPath];
                    if (routerItem) {
                        *stop = YES;
                    }
                }];
            }
        }
            break;
    }
    
    UIViewController *viewController = nil;
    //拦截替换viewController
    NSURL *interceptURL = [Mediator interceptClassName:routerItem.className withParams:params];
    if (interceptURL) {
        return [Mediator viewControllerForURL:interceptURL withParams:params complition:block];
    }
    
    if (routerItem && viewController == nil) {
        /**
         *  使用PageManager 构建ViewController
         */
        viewController = [[PageManager sharedInstance] createViewControllerFromName:routerItem.className param:nil];
    }
    
    /** 唯一页面实例 */
    if (routerItem.unique) {
        if (uniqueMapTable==nil) {
            uniqueMapTable = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsWeakMemory];
        }
        UIViewController *uniqueVC = [uniqueMapTable objectForKey:routerItem.className];
        if (uniqueVC) {
            viewController = uniqueVC;
        } else if(viewController) {
            [uniqueMapTable setObject:viewController forKey:routerItem.className];
        }
    }
    
    if (viewController) {
        //web拦截传参
        if (isWebURL && routerItem.webConfig.params) {
            [params addEntriesFromDictionary:routerItem.webConfig.params];
        }
        /*
         解析URL传参
         */
        NSDictionary *queryParams = URL.wm_queryParams;
        if (queryParams) {
            [params addEntriesFromDictionary:queryParams];
        }
        
        /*
         session params
         */
        ParamSession *sessionParam = [ParamSession wm_paramForKey:NSStringFromClass([viewController class])];
        if (sessionParam) {
            [params addEntriesFromDictionary:sessionParam.param];
        }
        /*
         设置参数
         */
        [viewController wm_setParams:params];
        /*
         跳转参数转换
         */
        id routerTypeParam = params[@"RouterType"];
        if ([routerTypeParam isKindOfClass:[NSString class]]) {
            routerItem.type = routerTypeParam;
        } else if ([routerTypeParam isKindOfClass:[NSNumber class]]) {
            routerItem.type = [UIConnector getStringFromType:[routerTypeParam integerValue]];
        }
    }
    if (block) {
        block(viewController, routerItem);
    }
    return viewController;
}

#pragma mark -
+ (void)pushViewController:(nonnull UIViewController *)controller
        baseViewController:(nullable UIViewController *)baseViewController
{
    if (baseViewController == nil) {
        baseViewController = [Mediator topmostNavigationController];
    }
    if(baseViewController == nil) return;
    
    controller.hidesBottomBarWhenPushed = YES;
    if ([baseViewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController*)baseViewController pushViewController:controller animated:YES];
    }else if(baseViewController.navigationController){
        [baseViewController.navigationController pushViewController:controller animated:YES];
    }else{
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [baseViewController presentViewController:navController animated:YES completion:NULL];
    }
}

+ (void)presentedViewController:(nonnull UIViewController *)controller
             baseViewController:(nullable UIViewController *)baseViewController animated:(BOOL )animated {
    if(baseViewController == nil){
        baseViewController = [self topmostViewController];
    }
    
    if(baseViewController == nil) return;
    
    if (baseViewController.presentedViewController) {
        [baseViewController dismissViewControllerAnimated:NO completion:nil];
    }
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    navController.transitioningDelegate = navController.transitioningDelegate;
    [baseViewController presentViewController:navController animated:animated completion:NULL];
}

#pragma mark -
+ (UIViewController *)topmostViewController
{
    //rootViewController需要是TabBarController,排除正在显示FirstPage的情况
    UIViewController *rootViewContoller = [UIApplication sharedApplication].delegate.window.rootViewController;
    return [rootViewContoller wm_topmostViewController];
}

+ (UINavigationController *)topmostNavigationController
{
    return [[Mediator topmostViewController] wm_nearestNavigationController];
}

+ (void)backToRootViewControllerCompletion:(void (^ __nullable)(void))completion {
    UIViewController *currentTopViewController = [Mediator topmostViewController];
    UINavigationController *currentNav = currentTopViewController.navigationController;
    if (currentNav) {
        if ([currentNav respondsToSelector:NSSelectorFromString(@"md_isSwitching")]&&[[currentNav performAction:@"md_isSwitching"] boolValue]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Mediator backToRootViewControllerCompletion:completion];
            });
            return;
        }
        [currentNav setViewControllers:@[currentNav.viewControllers.firstObject] animated:NO];
    }
    [Mediator dismissAllPresentedViewControllerAnimated:NO completion:^{
        if ([Mediator topmostViewController].navigationController.viewControllers.count>1) {
            [Mediator backToRootViewControllerCompletion:completion];
        } else {
            if (completion) {
                completion();
            }
        }
    }];
}

+ (void)dismissAllPresentedViewControllerAnimated:(BOOL)animated completion:(void (^ __nullable)(void))completion {
    UIViewController *currentTopViewController = [Mediator topmostViewController];
    if (currentTopViewController.presentingViewController) {
        currentTopViewController = currentTopViewController.presentingViewController;
        [currentTopViewController dismissViewControllerAnimated:animated completion:^{
            if (currentTopViewController == [Mediator topmostViewController].presentingViewController) {
                //如果在dismiss完成时，又新present出一个VC，则中止避免循环present和dismiss
                if (completion) {
                    completion();
                }
            } else {
                [Mediator dismissAllPresentedViewControllerAnimated:animated completion:completion];
            }
        }];
    } else if (currentTopViewController.presentedViewController) {
        [currentTopViewController dismissViewControllerAnimated:animated completion:^{
            [Mediator dismissAllPresentedViewControllerAnimated:animated completion:completion];
        }];
    } else {
        if (completion) {
            completion();
        }
    }
}

#pragma mark - 服务
+ (nullable id)getService:(nullable NSString *)serviceName
{
    return [ServiceCenter getService:serviceName];
}

@end

@implementation Mediator (Extension)
+ (NSURL*)interceptClassName:(NSString *)className withParams:(NSDictionary *)params {
    NSArray *interceptClassNames = @[@"BaseWebViewController", @"MessageNoticeWebViewController"];
    NSURL *interceptURL = nil;
    for (NSString *interceptClassName in interceptClassNames) {
        if ([className isEqualToString:interceptClassName]) {
            NSString *urlString = params[@"requestURL"]?:params[@"requestH5URL"];
            NSURL *URL = URL(urlString);
            __block RouterListItem * _routerItem;
            BOOL canRoute = [Mediator canRouteURL:URL withItemBlock:^(RouterListItem * _Nonnull routerItem) {
                _routerItem = routerItem;
            }];
            if (canRoute&&![_routerItem.className isEqualToString:interceptClassName]) {
                interceptURL = URL;
                break;
            }
        }
    }
    return interceptURL;
}

@end
