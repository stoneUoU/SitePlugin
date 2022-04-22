//
//  MediatorCategory.m
//  Pods
//
//  Created by qiumx on 2016/11/21.
//
//

#import "MediatorCategory.h"

@implementation NSURL (Mediator)

+ (instancetype)wm_URLWithString:(NSString *)urlString {
    if (!urlString||[urlString isEqualToString:@""]) {
        return nil;
    }
    if ([urlString rangeOfString:@"://"].location == NSNotFound) {
        NSString *ignorePrefix = @"/";
        if ([urlString hasPrefix:ignorePrefix]) {
            urlString = [urlString substringFromIndex:ignorePrefix.length];
        }
        if ([urlString hasPrefix:@"www."]) {
            urlString = [NSString stringWithFormat:@"http://%@", urlString];
        } else {
            urlString = [NSString stringWithFormat:@"native://%@", urlString]; 
        }
    }
    //排除左右空格
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    urlString = [urlString stringByTrimmingCharactersInSet:set];
    //解决urlString 含有中文^_^，注意要排除特殊字符
    NSString *encodeString = CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)urlString, (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]", NULL, kCFStringEncodingUTF8));
    
    return [NSURL URLWithString:encodeString];
}

- (NSString *)wm_scheme {
    return [self.scheme lowercaseString];
}

- (NSString *)wm_host {
    return [self.host lowercaseString];
}

- (NSString *)wm_path {
    NSString *path = self.path;
    NSString *ignorePrefix = @"/";
    if ([path hasPrefix:ignorePrefix]) {
        path = [path substringFromIndex:ignorePrefix.length];
    }
    if ([path hasSuffix:ignorePrefix]) {
        path = [path substringToIndex:path.length-ignorePrefix.length];
    }
    return [path lowercaseString];
}

- (NSMutableDictionary*)wm_queryParams {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSArray *paramsArr = [self.query componentsSeparatedByString:@"&"];
    for (NSString *paramString in paramsArr) {
        NSArray *paramsArr = [paramString componentsSeparatedByString:@"="];
        [params setValue:[[paramsArr lastObject] wm_stringByURLDecode] forKey:[paramsArr firstObject]];
    }
    return params;
}

- (WMHostCompareLevel)wm_isCompareHostSet:(NSSet*)hostSet {
    NSString *urlHost = self.wm_host;
    for (NSString *host in hostSet.allObjects) {
        if ([urlHost isEqualToString:[host lowercaseString]]) {//完全匹配域名
            return WMHostCompareLevelALL;
        }
        if ([urlHost hasSuffix:[[@"." stringByAppendingString:host] lowercaseString]]) {//匹配多级域名
            if ([host componentsSeparatedByString:@"."].count<3) {
                return WMHostCompareLevelTwo;
            } else if ([host componentsSeparatedByString:@"."].count==3) {
                return WMHostCompareLevelThree;
            }
            return WMHostCompareLevelFour;
        }
    }
    return WMHostCompareLevelNone;
}

@end

@implementation NSString (Mediator)

- (NSString *)wm_stringByURLEncode {
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded;
#pragma clang diagnostic pop
    }
}

- (NSString *)wm_stringByURLDecode {
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding];
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded;
#pragma clang diagnostic pop
    }
}

/*
 正则匹配webPath的业务id,如${id}，返回id:value字典键值对
 */
- (NSDictionary *)wm_regexCompare:(NSString*)URLPath {
    NSString *(^clearPrefixAndSuffix)(NSString *string) = ^(NSString *string) {
        NSString *ignorePrefix = @"/";
        if ([string hasPrefix:ignorePrefix]) {
            string = [string substringFromIndex:ignorePrefix.length];
        }
        if ([string hasSuffix:ignorePrefix]) {
            string = [string substringToIndex:string.length-ignorePrefix.length];
        }
        return string;
    };
    URLPath = clearPrefixAndSuffix(URLPath);
    
    NSString *regex = @"\\$\\{[^/:?]+\\}";
    NSString *valueRegex = @"[^/:?]+";
    NSString *lowCaseURLPath = [URLPath lowercaseString];
    NSRange rang = [self rangeOfString:regex options:NSRegularExpressionSearch];
    if (rang.location!=NSNotFound) {
        NSString *rStr = [self substringWithRange:rang];
        NSString *rWebPath = [self stringByReplacingOccurrencesOfString:rStr withString:valueRegex];
        NSRange rRang = [lowCaseURLPath rangeOfString:rWebPath options:NSRegularExpressionSearch];
        if (rRang.location==0&&rRang.length==lowCaseURLPath.length) {
            NSString *value = [URLPath stringByReplacingOccurrencesOfString:[self stringByReplacingOccurrencesOfString:rStr withString:@""] withString:@""];
            NSRange keyRang = NSMakeRange(@"${".length, 0);
            keyRang.length = rStr.length - keyRang.location - @"}".length;
            NSString *key = [rStr substringWithRange:keyRang];
            if (key&&value) {
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                params[key] = value;
                return params;
            }
        }
    }
    return nil;
}

@end

@implementation UIViewController (Mediator)

- (RouterType)wm_routerType {
    NSNumber *routerType = objc_getAssociatedObject(self, @selector(wm_routerType));
    if (routerType&&[routerType isKindOfClass:[NSNumber class]]) {
        return [routerType integerValue];
    }
    return RouterPush;
}

- (void)setWm_routerType:(RouterType)wm_routerType {
    objc_setAssociatedObject(self,  @selector(wm_routerType), @(wm_routerType), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIViewController*)wm_topmostViewController {
    if (self.presentedViewController
        &&![self.presentedViewController md_isExcludeTopmostViewController]) {
        return [self.presentedViewController wm_topmostViewController];
    } else if ([self isKindOfClass:[UITabBarController class]]) {
        return [[((UITabBarController*)self) selectedViewController] wm_topmostViewController];
    } else if ([self isKindOfClass:[UINavigationController class]]) {
        return [[((UINavigationController*)self) topViewController] wm_topmostViewController];
    } else if ([self conformsToProtocol:@protocol(MediatorTopViewControllerProtocol)]
               &&[self respondsToSelector:@selector(topViewController)]) {
        id<MediatorTopViewControllerProtocol> topViewControllerProtocol = (id)self;
        return [[topViewControllerProtocol topViewController] wm_topmostViewController];
    }
    return self;
}

- (BOOL)md_isExcludeTopmostViewController {
    NSArray *clsNames = @[@"UIAlertController"];
    BOOL isExclude = NO;
    for (NSString *clsName in clsNames) {
        Class cls = NSClassFromString(clsName);
        if (cls&&[self isKindOfClass:cls]) {
            isExclude = YES;
            break;
        }
    }
    return isExclude;
}

- (UINavigationController*)wm_nearestNavigationController {
    UIViewController *viewController = self;
    while (!viewController.navigationController) {
        if (viewController.presentingViewController) {
            viewController = viewController.presentingViewController;
            //presentingViewController是UINavigationController，则返回其topViewController
            if ([viewController isKindOfClass:[UINavigationController class]]) {
                viewController = ((UINavigationController*)viewController).topViewController;
            }
        } else {
            break;
        }
    }
    return viewController.navigationController;
}

- (BOOL)wm_isInViewStack {
    return self.parentViewController || self.presentingViewController;
}

- (void)wm_routeToTop {
    if (!self.wm_isInViewStack) {
        return;
    }
    //整理VC所在的关系栈
    __block NSMutableArray *stackVCs = [NSMutableArray array];
    UIViewController *VC = self;
    [stackVCs addObject:VC];
    while(VC.parentViewController||VC.presentingViewController) {
        VC = VC.parentViewController?:VC.presentingViewController;
        [stackVCs addObject:VC];
    }
    //根据关系栈路由VC节点
    [self wm_routeVC:[UIApplication sharedApplication].delegate.window.rootViewController forStack:stackVCs];
}

- (void)wm_routeVC:(UIViewController*)TVC forStack:(NSArray*)stackVCs {
    if ([TVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (UITabBarController*)TVC;
        UIViewController *nextVC = [tabVC.viewControllers firstObjectCommonWithArray:stackVCs];
        NSInteger index = [tabVC.viewControllers indexOfObject:nextVC];
        if (tabVC.selectedIndex != index) {
            [Mediator backToRootViewControllerCompletion:^{
                [tabVC setSelectedIndex:index];
            }];
        }
        //根据关系栈路由下一个VC节点
        [self wm_routeVC:nextVC forStack:stackVCs];
    } else if ([TVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController*)TVC;
        UIViewController *nextVC = [nav.viewControllers firstObjectCommonWithArray:stackVCs];
        if (nextVC && nextVC!=nav.visibleViewController) {
            [nav popToViewController:nextVC animated:NO];
        }
        //根据关系栈路由下一个VC节点
        [self wm_routeVC:nextVC forStack:stackVCs];
    } else if ([TVC conformsToProtocol:@protocol(MediatorTopViewControllerProtocol)]
               &&[TVC respondsToSelector:@selector(topViewController)]) {
        id<MediatorTopViewControllerProtocol> topViewControllerProtocol = (id)TVC;
        //根据关系栈路由下一个VC节点
        [self wm_routeVC:[topViewControllerProtocol topViewController] forStack:stackVCs];
    } else {
        if (TVC.presentedViewController) {
            if ([stackVCs containsObject:TVC.presentedViewController]) {
                [self wm_routeVC:TVC.presentedViewController forStack:stackVCs];
            } else {
                [TVC wm_dismissAllViewControllerAnimated:NO completion:^{
                    if (TVC.presentedViewController) {
                        [self wm_routeVC:TVC forStack:stackVCs];
                    }
                }];
            }
        }
        
    }
}

- (void)wm_exitStack {
    if (!self.wm_isInViewStack) {
        return;
    }
    if (self.navigationController) {
        if (self.navigationController.viewControllers.count>1) {
            if ([self.navigationController.viewControllers lastObject]==self) {
                [self.navigationController popViewControllerAnimated:YES];
            } else {
                NSMutableArray * viewControllers = [self.navigationController.viewControllers mutableCopy];
                [viewControllers removeObject:self];
                [self.navigationController setViewControllers:viewControllers animated:NO];
            }
        } else {
            if (self.navigationController.presentedViewController) {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
    } else {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:^{
                
            }];
        }
    }
}

//关闭所有在这个VC之上present的VC
- (void)wm_dismissAllViewControllerAnimated:(BOOL)animated completion: (void (^)(void))completion {
    UIViewController *topPresentVC = self.presentedViewController;
    while (topPresentVC.presentedViewController) {
        topPresentVC = topPresentVC.presentedViewController;
    }
    if (topPresentVC) {
        UIViewController *nextTopPresentVC = topPresentVC.presentingViewController;
        [topPresentVC dismissViewControllerAnimated:animated completion:^{
            if (nextTopPresentVC) {
                [nextTopPresentVC wm_dismissAllViewControllerAnimated:animated completion:completion];
            } else {
                completion();
            }
        }];
    } else {
        completion();
    }
}

- (void)wm_alterTip:(NSString *)tip {
    UIAlertController *alterVC =  [UIAlertController alertControllerWithTitle:@"警告" message:tip preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* actionDefault = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alterVC addAction:actionDefault];
    [self presentViewController:alterVC animated:YES completion:^{
        
    }];
}

@end

@implementation NSObject (Mediator)

- (void)wm_setParams:(NSDictionary*)params {
    if (params==nil||![params isKindOfClass:[NSDictionary class]]) {
        return;
    }
    __block NSObject *blockSelf = self;
    NSMutableDictionary *mParams = [params mutableCopy];
    [mParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
#define convert_number_with_selector(_selector) \
do { \
value = @([stringValue _selector]);\
} while (0)
        NSString *stringValue = obj;
        id value = obj;
        Class cls = [self class];
        while (cls != [NSObject class]) {
            unsigned int numIvars; //成员变量个数
            Ivar *vars = class_copyIvarList(cls, &numIvars);
            if (vars) {
                NSString *keyName=nil;
                for(int i = 0; i < numIvars; i++) {
                    Ivar thisIvar = vars[i];
                    keyName = [NSString stringWithUTF8String:ivar_getName(thisIvar)];  //获取成员变量的名字
                    if ([keyName hasPrefix:@"_"]) {
                        keyName = [keyName substringFromIndex:@"_".length];
                    }
                    if ([keyName caseInsensitiveCompare:key] == NSOrderedSame) {
                        char *type = (char *)ivar_getTypeEncoding(thisIvar);
                        switch (*type) {
                            case 'B':
                                convert_number_with_selector(boolValue);
                                
                            case 'i':
                            case 'l':
                            case 'L':
                                convert_number_with_selector(intValue);
                                
                            case 'q':
                            case 'Q':
                                convert_number_with_selector(longLongValue);
                                
                            case 'f':
                                convert_number_with_selector(floatValue);
                                
                            case 'd':
                            case 'D':
                                convert_number_with_selector(doubleValue);
                        }
                        [blockSelf setValue:value forKey:keyName];
                        [mParams removeObjectForKey:key];
                        break;
                    }
                }
                free(vars);
            }
            cls = [cls superclass];
        }
#undef convert_number_with_selector
    }];
    /* 关联属性不属于Ivar */
    [mParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        SEL selector = NSSelectorFromString(key);
        if ([blockSelf respondsToSelector:selector]) {
            [blockSelf setValue:obj forKey:key];
        }
    }];
}

@end
