//
//  ModuleConfig.h
//  MediatorDemo
//
//  Created by qiumx on 16/8/18.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ModuleBaseConfig : NSObject
+ (instancetype)configWith:(NSDictionary*)dic;
@end

@class RouterListItem;
@class ServiceListItem;
@class WebConfig;
@interface ModuleConfig : ModuleBaseConfig
@property (strong, nonatomic) NSString *version;    //版本号
@property (strong, nonatomic) NSString *name;   //模块名
@property (strong, nonatomic) NSString *scheme; //调试app间跳转协议
@property (strong, nonatomic) NSString *delegateClass; //用于管理module内部AppDeleate，必须遵循ModuleDelegate协议
@property (strong, nonatomic) NSString *connectorClass; //默认为UIConnector，可配置自定义类
@property (strong, nonatomic) NSArray<RouterListItem *> *router_list;  //路由列表
@property (strong, nonatomic) NSArray<ServiceListItem *> *service_list; //服务列表
@end

@interface RouterListItem : ModuleBaseConfig <NSCopying>
@property (strong, nonatomic) NSString *name;   //页面名
@property (strong, nonatomic) NSString *className;  //页面类名
@property (strong, nonatomic) NSString *type;   //打开形式
@property (strong, nonatomic) WebConfig *webConfig;
@property (strong, nonatomic) NSArray<WebConfig *> *webConfigs;//支持一个页面对应多个 web 配置项，如拦截多个 webPath
@property (nonatomic) BOOL needLogin;  //是否需要登录
@property (nonatomic) BOOL unique;  //是否应用中唯一存在页面
@end

@interface WebConfig : ModuleBaseConfig <NSCopying>
@property (strong, nonatomic) NSString *webPath;   //网页路径(支持正则匹配最后一位webPath的业务id,如test/${key}，匹配value以key作为键值赋值给原生页面),URL会以requestURL为键值赋值给原生页面（如果存在requestURL）
@property (strong, nonatomic) NSArray *hosts;   //域名列表（填则填写为准。不填，以默认支持为准）
@property (strong, nonatomic) NSDictionary *params; //固定传参
@end

@interface ServiceListItem : ModuleBaseConfig
@property (strong, nonatomic) NSString *name;   //服务名
@property (strong, nonatomic) NSString *className;  //服务类名
@property (strong, nonatomic) NSString *protocol;   //实现协议名
@end
