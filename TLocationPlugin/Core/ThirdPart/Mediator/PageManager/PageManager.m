//
//  PageManager.m
//  PageManager
//
//  Created by qiumx on 15/4/21.
//  Copyright (c) 2015年 qiumx. All rights reserved.
//

#import "PageManager.h"
#import <objc/runtime.h>
#import "Mediator.h"

@interface PageManager()

- (void)updateViewController:(UIViewController *)viewController withParam:(NSDictionary *)param;
- (UIViewController *)createViewControllerFromName:(NSString *)name param:(NSDictionary *)param;

@end

@implementation PageManager

#pragma mark - Life Cycle

- (void)dealloc
{
    
}

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (UIViewController *)currentViewController {
    return [Mediator topmostViewController];
}

- (UIViewController *)currentLoadedViewController {
    return self.currentViewController;
}


#pragma mark - Public
#pragma mark Push To Navigation Controller

- (UIViewController*)pushViewController:(NSString *)viewControllerName
{
    return [self pushViewController:viewControllerName withParam:nil];
}

- (UIViewController*)pushViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param
{
    return [self pushViewController:viewControllerName withParam:param animated:YES];
}

- (UIViewController*)pushViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param animated:(BOOL)animated
{
    //拦截替换viewController
    NSURL *interceptURL = [Mediator interceptClassName:viewControllerName withParams:param];
    if (interceptURL) {
        __block UIViewController *viewController;
        [Mediator routeURL:interceptURL withParams:param completion:^(id  _Nullable result) {
            viewController = result;
        }];
        return viewController;
    }
    UIViewController *viewController = [self createViewControllerFromName:viewControllerName param:param];
    if (!viewController) {
        return nil;
    }
    
    UINavigationController *navigationController = [Mediator topmostNavigationController];
    if (navigationController) {
        viewController.hidesBottomBarWhenPushed = YES;
        [navigationController pushViewController:viewController animated:animated];
    }
    return viewController;
}

- (void)pushExistingViewController:(UIViewController *)viewController
{
    [self pushExistingViewController:viewController withParam:nil];
}

- (void)pushExistingViewController:(UIViewController *)viewController withParam:(NSDictionary *)param
{
    [self pushExistingViewController:viewController withParam:param animated:YES];
}

- (void)pushExistingViewController:(UIViewController *)viewController withParam:(NSDictionary *)param animated:(BOOL)animated
{
    if (!viewController) {
        return;
    }
    if (param && ![param isKindOfClass:[NSDictionary class]]) {
        return;
    }
        
    if (param) {
        [self updateViewController:viewController withParam:param];
    }
    
    UINavigationController *navigationController = [Mediator topmostNavigationController];
    if (navigationController) {
        viewController.hidesBottomBarWhenPushed = YES;
        [navigationController pushViewController:viewController animated:animated];
    }
}

#pragma mark Pop View Controller

- (UIViewController*)popViewControllerWithParam:(NSDictionary*)param
{
    UINavigationController *navigationController = [Mediator topmostNavigationController];
    NSArray *viewControllers = navigationController.viewControllers;
    if([viewControllers count] < 2){
        return nil;
    }

    UIViewController *viewController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    if(!viewController){
        return nil;
    }

    [self updateViewController:viewController withParam:param];
    return [navigationController popViewControllerAnimated:YES];
}

- (NSArray*)popToViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param
{
    return [self popToViewController:viewControllerName isReverse:NO withParam:param];
}

- (NSArray*)popToLastViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param
{
    return [self popToViewController:viewControllerName isReverse:YES withParam:param];
}

- (NSArray *)popToRootViewController:(NSDictionary *)param{
    return [self popToRootViewController:param animated:YES];
}


- (NSArray *)popToRootViewController:(NSDictionary *)param animated:(BOOL)animated{
    __block UIViewController *viewController = nil;
    UINavigationController *navigationController = [Mediator topmostNavigationController];
    NSArray *viewControllers = navigationController.viewControllers;
    viewController = [viewControllers firstObject];

    NSArray * resultAry = nil;
    if(viewController){
        [self updateViewController:viewController withParam:param];
        resultAry = [navigationController popToViewController:viewController animated:animated];
    }
    return resultAry;
}


- (UIViewController*)getCurrentShowViewController{
    UINavigationController *navigationController = [Mediator topmostNavigationController];
    UIViewController* currentVC = [navigationController.viewControllers lastObject];
    PMLOG(@"currentVC->%@",NSStringFromClass([currentVC class]));
    return currentVC;
}

//..xiehx begin
- (void)popThenPushViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param animated:(BOOL)animated {
    UINavigationController *nav = [Mediator topmostNavigationController];
    if (!nav) {
        return;
    }
    NSArray *popedViewCtrls = nil;
    if (nav.viewControllers.count > 0) {
        popedViewCtrls = @[nav.viewControllers.lastObject];
    }
    [self popCtrlsThenPushWithName:popedViewCtrls pushedViewCtrlName:viewControllerName param:param animated:animated];
    return;
}

- (void)popToRootThenPushViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param animated:(BOOL)animated {
    UINavigationController *nav = [Mediator topmostNavigationController];
    if (!nav) {
        return;
    }
    NSMutableArray *popedViewCtrls = nil;
    if (nav.viewControllers.count > 1) {
        popedViewCtrls = [nav.viewControllers mutableCopy];
        [popedViewCtrls removeObjectAtIndex:0];
    }
    [self popCtrlsThenPushWithName:[popedViewCtrls copy] pushedViewCtrlName:viewControllerName param:param animated:animated];
    return;
}

- (void)popToViewControllerThenPushViewController:(NSString *)popToViewControllerName
                             pushedViewController:(NSString *)pushedViewControllerName
                                        withParam:(NSDictionary *)param
                                         animated:(BOOL)animated {
    
    UINavigationController *navController = [Mediator topmostNavigationController];
    if (!navController) {
        return ;
    }
    
    NSArray *popedArray = [navController.viewControllers filterArrayForRightOfClassName:popToViewControllerName containSeparator:NO];
    
    [self popCtrlsThenPushWithName:[popedArray copy] pushedViewCtrlName:pushedViewControllerName param:param animated:animated];
}

- (void)popCtrlsThenPushWithName:(NSArray *)popedViewControllers
              pushedViewCtrlName:(NSString *)pushedViewCtrlName
                           param:(NSDictionary *)param
                        animated:(BOOL)animated
{
    NSArray *pushedViewCtrls = nil;
    UIViewController *viewController = [self createViewControllerFromName:pushedViewCtrlName param:param];
    if (viewController) {
        viewController.hidesBottomBarWhenPushed = YES;
        pushedViewCtrls = @[viewController];
    }
    [self popCtrlsThenPushCtrls:popedViewControllers pushedViewController:pushedViewCtrls animated:animated];
}

/*Discussion:
     The viewController's name in pushedViewCtrlNames array and the param in params array is one-to-one corresponed according the index. That means if the viewController's param is nil, it should be set [NSNull null] in the params array; if all the viewController's param is nil, the params array can be set to nil;
 */
- (void)popCtrlsThenPushWithNames:(NSArray *)popedViewControllers
              pushedViewCtrlNames:(NSArray *)pushedViewCtrlNames
                           params:(NSArray *)params
                         animated:(BOOL)animated
{
    NSArray *viewCtrls = [self createViewCtrlsWithNames:pushedViewCtrlNames params:params];
    [self popCtrlsThenPushCtrls:popedViewControllers pushedViewController:viewCtrls animated:animated];
}

- (void)popCtrlsThenPushCtrls:(NSArray *)popedViewControllers
         pushedViewController:(NSArray *)pushedViewControllers
                     animated:(BOOL)animated
{
    UINavigationController *navController = [Mediator topmostNavigationController];
    if (!navController) {
        return;
    }
    
    NSMutableArray *newViewCtrls = [[NSMutableArray alloc] initWithArray:navController.viewControllers];
    [newViewCtrls removeObjectsInArray:popedViewControllers];
    [newViewCtrls addObjectsFromArray:pushedViewControllers];
    [navController setViewControllers:newViewCtrls animated:animated];
}

- (NSArray *)createViewCtrlsWithNames:(NSArray *)viewControllerNames params:(NSArray *)params {
    NSMutableArray *viewCtrls = [[NSMutableArray alloc] init];
    [viewControllerNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            NSString *viewCtrlName = obj;
            NSDictionary *param = nil;
            if (idx < params.count && [params[idx] isKindOfClass:[NSDictionary class]]) {
                param = params[idx];
            }
            UIViewController *viewController = [self createViewControllerFromName:viewCtrlName param:param];
            if (viewController) {
                viewController.hidesBottomBarWhenPushed = YES;
                [viewCtrls addObject:viewController];
            }
        }
    }];
    if (viewCtrls.count == 0) {
        return nil;
    }
    else {
        return [viewCtrls copy];
    }
}
//..xiehx end

#pragma mark Present View Controller

- (void)presentViewController:(NSString *)viewControllerName
{
    [self presentViewController:viewControllerName withParam:nil];
}

- (void)presentViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param
{
    [self presentViewController:viewControllerName withParam:param inNavigationController:NO];
}

- (void)presentViewController:(NSString *)viewControllerName
                    withParam:(NSDictionary *)param
       inNavigationController:(BOOL)isInNavigationController
{
    [self presentViewController:viewControllerName
                      withParam:param
         inNavigationController:isInNavigationController
                       animated:YES];
}

- (void)presentViewController:(NSString *)viewControllerName
                    withParam:(NSDictionary *)param
       inNavigationController:(BOOL)isInNavigationController
                     animated:(BOOL)animated
{
    UIViewController *viewController = [self createViewControllerFromName:viewControllerName param:param];
    viewController.modalPresentationStyle = UIModalPresentationFullScreen;
    if (!viewController) {
        return;
    }
    if (isInNavigationController && self.currentViewController) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.currentViewController presentViewController:navigationController animated:animated completion:nil];
    } else {
        [self.currentViewController presentViewController:viewController animated:animated completion:nil];
    }
}
- (void)fadeInViewController:(NSString *)viewControllerName withParam:(NSDictionary *)param
{
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_4) {
        [self pushViewController:viewControllerName withParam:param animated:YES];
        return;
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    transition.type = kCATransitionFade;
    transition.delegate = (id)self;
    UINavigationController *navigationController = [Mediator topmostNavigationController];
    [navigationController.view.layer addAnimation:transition forKey:nil];
    navigationController.navigationBarHidden = NO;
    
    [self pushViewController:viewControllerName withParam:param animated:NO];
}

- (UIViewController *)fadeOutViewControllerWithParam:(NSDictionary *)param
{
    if (NSFoundationVersionNumber <= NSFoundationVersionNumber_iOS_8_4) {
        return [self popViewControllerWithParam:param];
    }
    
    CATransition *transition = [CATransition animation];
    transition.duration = 0.3f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    transition.type = kCATransitionFade;
    transition.delegate = (id)self;
    UINavigationController *navigationController = [Mediator topmostNavigationController];
    [navigationController.view.layer addAnimation:transition forKey:nil];
    navigationController.navigationBarHidden = NO;
    
    NSArray *viewControllers = navigationController.viewControllers;
    if([viewControllers count] < 2){
        return nil;
    }
    UIViewController *viewController = [viewControllers objectAtIndex:[viewControllers count] - 2];
    if(!viewController){
        return nil;
    }
    [self updateViewController:viewController withParam:param];
    return [navigationController popViewControllerAnimated:NO];
}


#pragma mark - Private

- (void)updateViewController:(UIViewController *)viewController withParam:(NSDictionary *)param
{
    NSArray *keys = [param allKeys];
    if ([keys count] == 0) {
        return;
    }
    for (NSString *key in keys) {
        SEL selector = NSSelectorFromString(key);
        if (selector == 0) {
            continue;
        }
        
        if ([viewController respondsToSelector:selector]) {
            id value = [param objectForKey:key];
            [viewController setValue:value forKey:key];
        }
    }
}

- (UIViewController *)createViewControllerFromName:(NSString *)name param:(NSDictionary *)param
{
    if (param && ![param isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    UIViewController *viewController = nil;
    Class class = NSClassFromString(name);
    
    if (!class || ![class isSubclassOfClass:[UIViewController class]]) {
        //不存在，展示错误页面
        if (_errorViewControllerClassName) {
            viewController = [self createViewControllerFromName:_errorViewControllerClassName param:param];
        }
        return viewController;
    }
    NSString *nibName = [self nibFileName:class];
    if (nibName) {
        viewController = [[class alloc] initWithNibName:nibName bundle:nil];
    } else {
        viewController = [[class alloc] init];
    }
    
    if (param) {
        [self updateViewController:viewController withParam:param];
    }
    
    return viewController;
}

- (NSString*)nibFileName:(Class)theClass {
    BOOL nibFileExist = ([[NSBundle mainBundle] pathForResource:NSStringFromClass(theClass) ofType:@"nib"] != nil);
    //如果没有对应的nib，但是父类不是UIViewController，则继续查找替用父类的nib
    if (nibFileExist == NO
        &&[NSStringFromClass([theClass superclass]) isEqualToString:NSStringFromClass([UIViewController class])] == NO) {
        return [self nibFileName:[theClass superclass]];
    }
    return nibFileExist?NSStringFromClass(theClass):nil;
}

- (NSArray*)popToViewController:(NSString *)viewControllerName isReverse:(BOOL)isReverse withParam:(NSDictionary *)param
{
    if(viewControllerName == nil){
        return nil;
    }
    
    Class viewControllerClass = NSClassFromString(viewControllerName);
    if(viewControllerClass == nil){
        return nil;
    }
    
    __block UIViewController *viewController = nil;
    UINavigationController *navigationController = [Mediator topmostNavigationController];
    NSArray *viewControllers = navigationController.viewControllers;
    if (isReverse) {
        [viewControllers enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if([obj isKindOfClass:viewControllerClass]){
                viewController = obj;
                *stop = YES;
            }
        }];
    }
    else
    {
        [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            if([obj isKindOfClass:viewControllerClass]){
                viewController = obj;
                *stop = YES;
            }
        }];
    }
    
    NSArray * resultAry = nil;
    if(viewController){
        [self updateViewController:viewController withParam:param];
        resultAry = [navigationController popToViewController:viewController
                                                                                animated:YES];
    }
    return resultAry;
}

@end


@implementation UINavigationController (popToBeforeClass)

- (void)popToBeforeClass:(Class)theClass animated:(BOOL)animated
{
    BOOL isFromApply = NO;
    NSArray *viewControllers = self.viewControllers;
    UIViewController *vc = nil;
    for (NSInteger i=viewControllers.count-1;i>=0;i--) {
        vc = viewControllers[i];
        if ([vc isKindOfClass:theClass]) {
            isFromApply = YES;
            break;
        }
    }
    if (isFromApply) {
        NSUInteger i = [viewControllers indexOfObject:vc];
        if (i>0) {
            vc = viewControllers[i-1];
        }
        [self popToViewController:vc animated:YES];
    } else {
        [self popViewControllerAnimated:YES];
    }
}

@end


@implementation NSArray (PageManager)

- (NSArray *)filterViewControllersWithClassName:(NSString*)className {
    NSArray *vcs = [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject isMemberOfClass:NSClassFromString(className)];
    }]];
    return vcs;
}

- (NSArray *)filterArrayForRightOfClassName:(NSString *)className containSeparator:(BOOL)containSeparator {
    if (self == nil || self.count == 0) {
        return nil;
    }
    NSArray *filterArray = [self filterViewControllersWithClassName:className];
    if (filterArray.count == 0) {
        return nil;
    }
    else {
        id obj = [filterArray lastObject];
        NSUInteger index = [self indexOfObject:obj];
        if (index == NSNotFound || index >= self.count) {
            return nil;
        }
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self];
        if (containSeparator) {
            [array removeObjectsInRange:NSMakeRange(0, index)];
        }
        else {
            [array removeObjectsInRange:NSMakeRange(0, index + 1)];
        }
        return [array copy];
    }
}

@end
