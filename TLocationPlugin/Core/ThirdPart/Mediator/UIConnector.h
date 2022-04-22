//
//  UIConnector.h
//  MediatorDemo
//
//  Created by qiumx on 16/8/17.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ModuleConfig.h"

typedef void(^CanRouterBlock)(RouterListItem * _Nullable routerItem);
typedef void(^RouterBlock)(UIViewController * _Nullable viewController, RouterListItem * _Nullable routerItem);
typedef void(^CustomConnectorCallback)(RouterListItem * _Nullable routerItem, NSDictionary * _Nullable addParams);

// 只允许往后面加，因为要跟数组进行对应
typedef NS_ENUM(NSUInteger, RouterType) {
    RouterPush            = 0,
    RouterFade            = 1,
    RouterPresent         = 2,
    RouterCustom          = 3,
    RouterPresentCustom   = 4,
    RouterFall            = 5,
};
NS_ASSUME_NONNULL_BEGIN
@interface UIConnector : NSObject

/**
 *  实例化对象
 */

+ (nullable instancetype)connectorWith:(nullable ModuleConfig *)config;
/**
 * 自定义处理URL
 * @return 默认返回NO，若覆写返回YES，则Mediator不再处理本次路由
 */
- (BOOL)isHandleCustomActionForURL:(NSURL*)URL withParams:(NSDictionary *)params;
/**
 * 当前业务组件是否能打开
 */
-(BOOL)canOpenURLPath:(nonnull NSString *)URLPath;
+(BOOL)canOpenWebURL:(nonnull NSURL *)webURL;
/**
 * 当前业务组件可导航的URLPath/webURL的item
 */
-(RouterListItem *)itemForURLPath:(nonnull NSString *)URLPath;
+(RouterListItem *)itemForWebURL:(nonnull NSURL *)webURL;

@end

@interface UIConnector (Category)
+ (RouterType)getTypeFromString:(NSString *)strType;
+ (NSString*)getStringFromType:(RouterType)type;
@end

typedef enum : NSUInteger {
    UIConnectorCustomTypeNone = 0,
    UIConnectorCustomTypeInstead,//替换原 route
    UIConnectorCustomTypeBreak,//截断原 route
    UIConnectorCustomTypeContinue,//继续原 route
} UIConnectorCustomRouteType;
/**
 * 自定义 UIConnector 可实现该协议
 */
@protocol UIConnectorCustomProtocol <NSObject>
@required
- (UIConnectorCustomRouteType)customConnectorForURL:(NSURL*)URL complition:(CustomConnectorCallback)itemBlock;
@end

NS_ASSUME_NONNULL_END
