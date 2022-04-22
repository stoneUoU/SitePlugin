//
//  MediatorCategory.h
//  Pods
//
//  Created by qiumx on 2016/11/21.
//
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "Mediator.h"

typedef enum : NSUInteger {
    WMHostCompareLevelNone = 0,
    WMHostCompareLevelTwo,
    WMHostCompareLevelThree,
    WMHostCompareLevelFour,
    WMHostCompareLevelALL,
} WMHostCompareLevel;

@protocol MediatorTopViewControllerProtocol <NSObject>
- (UIViewController*)topViewController;
@end

@interface NSURL (Mediator)
+ (instancetype)wm_URLWithString:(NSString *)urlString;
- (NSString *)wm_scheme;
- (NSString *)wm_host;
- (NSString *)wm_path;
- (NSMutableDictionary*)wm_queryParams;
- (WMHostCompareLevel)wm_isCompareHostSet:(NSSet*)hostSet;
@end

@interface NSString (Mediator)
- (NSString *)wm_stringByURLEncode;
- (NSString *)wm_stringByURLDecode;
/*
 正则匹配webPath的业务id,如${id}，返回id:value字典键值对
 */
- (NSDictionary *)wm_regexCompare:(NSString*)URLPath;
@end

@interface UIViewController (Mediator)
/*
 view controller转场动画类型
 */
@property (nonatomic) RouterType wm_routerType;

/*
 存在嵌套UITabbarViewController等情况，需要实现MediatorTopViewControllerProtocol协议的topViewController方法
 */
- (UIViewController*)wm_topmostViewController;
/*
 最近的NavigationController
 */
- (UINavigationController*)wm_nearestNavigationController;

/** 是否在视图栈中 */
- (BOOL)wm_isInViewStack;

/** 把VC路由到当前页面 */
- (void)wm_routeToTop;

/** 退出视图栈 */
- (void)wm_exitStack;

/* alter提示 */
- (void)wm_alterTip:(NSString*)tip;
@end

@interface NSObject (Mediator)
- (void)wm_setParams:(NSDictionary*)params;
@end
