//
//  MediatorDefine.h
//  Pods
//
//  Created by qiumx on 2019/4/29.
//

///构造函数,在`main`函数之前并在`load`函数之后执行, priority为101~200（越低优先级越高，1~100为系统保留）
#ifndef APP_CONSTRUCTOR_PRIORITY_NAME
#define APP_CONSTRUCTOR_PRIORITY_NAME(priority, name, block) __attribute__((constructor(priority))) \
static void name##_APP_CONSTRUCTOR(void) {\
block();\
}
#endif
//声明函数为构造函数,默认150优先级
#ifndef APP_CONSTRUCTOR_NAME
#define APP_CONSTRUCTOR_NAME(name, block) APP_CONSTRUCTOR_PRIORITY_NAME(150, name, block)
#endif

//URL宏,建议使用
#define URL(urlString) [NSURL wm_URLWithString:urlString]

//单例方法声明
#undef    AS_SINGLETON
#define AS_SINGLETON \
+ (nullable instancetype)sharedInstance;

//单例方法实现
#undef    DEF_SINGLETON
#define DEF_SINGLETON \
+ (nullable instancetype)sharedInstance \
{ \
static dispatch_once_t once; \
static id __singleton__; \
dispatch_once( &once, ^{ __singleton__ = [[self alloc] init]; } ); \
return __singleton__; \
}

/*************************    iOS Version    ***********************************/

/**
 *  检测系统版本
 */
#define iOS_Version [[[UIDevice currentDevice] systemVersion] floatValue]

//系统版本大小关系
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_IOS11_OR_LATER   ([[[UIDevice currentDevice] systemVersion] compare:@"11" options:NSNumericSearch] == NSOrderedDescending)
#define IS_IOS10_OR_LATER   ([[[UIDevice currentDevice] systemVersion] compare:@"10" options:NSNumericSearch] == NSOrderedDescending)
#define IS_IOS9_OR_LATER    ([[[UIDevice currentDevice] systemVersion] compare:@"9" options:NSNumericSearch] == NSOrderedDescending)
#define IS_IOS8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] == NSOrderedDescending)
#define IS_IOS7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch] == NSOrderedDescending)
#define IS_NOT_IOS7         !([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] == NSOrderedSame)

#define WM_IOS_AVAILABLE(v) @available(iOS v , *)

//iPhone尺寸：https://www.jianshu.com/p/f94724d235b0

#define SCREEN_3_5_INCH_WIDTH  320.0f
#define SCREEN_3_5_INCH_HEIGHT 480.0f
#define SCREEN_4_INCH_WIDTH    320.0f
#define SCREEN_4_INCH_HEIGHT   568.0f
#define SCREEN_4_7_INCH_WIDTH  375.0f
#define SCREEN_4_7_INCH_HEIGHT 667.0f
#define SCREEN_5_5_INCH_WIDTH  414.0f
#define SCREEN_5_5_INCH_HEIGHT 736.0f
#define SCREEN_5_8_INCH_WIDTH  375.0f // iPhone13 Mini || iPhoneXs || iPhoneX
#define SCREEN_5_8_INCH_HEIGHT 812.0f
#define SCREEN_6_5_INCH_WIDTH  414.0f // 6.1寸的XR宽高和6.5的XSMax 两者的pt相同，但是px不同
#define SCREEN_6_5_INCH_HEIGHT 896.0f
#define SCREEN_6_7_INCH_WIDTH  428.0f // 适配iPhone12 Pro Max || iPhone13 Pro Max
#define SCREEN_6_7_INCH_HEIGHT 926.0f

#define SCREEN_12_PRO_INCH_WIDTH  390.0f // 适配iPhone12 Pro || iPhone12  || iPhone13  || iPhone13 Pro
#define SCREEN_12_PRO_INCH_HEIGHT 844.0f

#define SCREEN_12_MINI_INCH_WIDTH  360.0f // 适配iPhone12 mini
#define SCREEN_12_MINI_INCH_HEIGHT 780.0f

#define IS_SCREEN_3_5_INCH (([UIScreen mainScreen].bounds.size.height == SCREEN_3_5_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_3_5_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_3_5_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_3_5_INCH_HEIGHT))
#define IS_SCREEN_4_INCH   (([UIScreen mainScreen].bounds.size.height == SCREEN_4_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_4_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_4_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_4_INCH_HEIGHT))
#define IS_SCREEN_4_7_INCH (([UIScreen mainScreen].bounds.size.height == SCREEN_4_7_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_4_7_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_4_7_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_4_7_INCH_HEIGHT))
#define IS_SCREEN_5_5_INCH (([UIScreen mainScreen].bounds.size.height == SCREEN_5_5_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_5_5_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_5_5_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_5_5_INCH_HEIGHT))
#define IS_SCREEN_5_8_INCH (([UIScreen mainScreen].bounds.size.height == SCREEN_5_8_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_5_8_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_5_8_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_5_8_INCH_HEIGHT))
#define IS_SCREEN_6_5_INCH (([UIScreen mainScreen].bounds.size.height == SCREEN_6_5_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_6_5_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_6_5_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_6_5_INCH_HEIGHT))
#define IS_SCREEN_6_7_INCH (([UIScreen mainScreen].bounds.size.height == SCREEN_6_7_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_6_7_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_6_7_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_6_7_INCH_HEIGHT))

#define IS_SCREEN_12_PRO_INCH (([UIScreen mainScreen].bounds.size.height == SCREEN_12_PRO_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_12_PRO_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_12_PRO_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_12_PRO_INCH_HEIGHT))

#define IS_SCREEN_12_MINI_INCH (([UIScreen mainScreen].bounds.size.height == SCREEN_12_MINI_INCH_HEIGHT && [UIScreen mainScreen].bounds.size.width == SCREEN_12_MINI_INCH_WIDTH)||([UIScreen mainScreen].bounds.size.height == SCREEN_12_MINI_INCH_WIDTH && [UIScreen mainScreen].bounds.size.width == SCREEN_12_MINI_INCH_HEIGHT))

#define IS_IPHONEX (IS_SCREEN_6_5_INCH || IS_SCREEN_5_8_INCH || IS_SCREEN_6_7_INCH || IS_SCREEN_12_MINI_INCH || IS_SCREEN_12_PRO_INCH)

/******************************    UI      ***********************************/
#define SCREENHEIGHT  ([UIScreen mainScreen].bounds.size.height)
#define SCREENWIDTH   ([UIScreen mainScreen].bounds.size.width)

#define RGB(R, G, B)    [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#define RGBA(R,G,B,A)   [UIColor colorWithRed:(R)/255.0f \
green:(G)/255.0f blue:(B)/255.0f alpha:(A)]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define iPhone5Height  568
#define iPhone5Width   320
#define iPhone6Width   375
#define StatusBarHeight ((![[UIApplication sharedApplication] isStatusBarHidden]) ? [[UIApplication sharedApplication] statusBarFrame].size.height : (IS_IPHONEX ? 44.f:20.f))
#define NavBarHeight    44
#define SearchBarHeight 44
#define TabBarHeight    ( IS_IPHONEX ? 83 : 50 )
#define BottomDangerAreaHeight   ( IS_IPHONEX ? 34 : 0 )
#define TopAddDangerAreaHeight   ( IS_IPHONEX ? 24 : 0 )
#define isIPhoneSE      (SCREENWIDTH == 320.f && SCREENHEIGHT == 568.f ? YES : NO)

#define kHSAPackageName             [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"]
#define kHSAAppVersion              [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define kHSAAppBuildVersion         [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
