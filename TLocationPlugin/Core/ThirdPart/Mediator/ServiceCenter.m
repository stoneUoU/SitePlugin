//
//  ServiceCenter.m
//  MediatorDemo
//
//  Created by qiumx on 16/8/17.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import "ServiceCenter.h"
#import "Mediator.h"

static NSString *const TITLE_SERVICECLASS = @"service_implclass";
static NSString *const TITLE_SERVICEOBJECT = @"service_implobject";

@interface ServiceCenter () {
}

@property (strong, nonatomic) NSMutableDictionary *serviceMap;
@property (strong, nonatomic) NSMutableDictionary *serviceImpMap;

@end

@implementation ServiceCenter
DEF_SINGLETON;

- (NSMutableDictionary *)serviceMap {
    if (!_serviceMap) {
        _serviceMap = [[NSMutableDictionary alloc] init];
    }
    return _serviceMap;
}

- (NSMutableDictionary *)serviceImpMap
{
    if (!_serviceImpMap) {
        _serviceImpMap = [[NSMutableDictionary alloc] init];
    }
    return _serviceImpMap;
}

+ (BOOL)registerService:(NSString *)serviceName class:(NSString *)serviceClassString protocol:(NSString *)serviceProtocolString {
    return [[ServiceCenter sharedInstance] registerService:serviceName class:serviceClassString protocol:serviceProtocolString];
}

- (BOOL)registerService:(NSString *)serviceName class:(NSString *)serviceClassString protocol:(NSString *)serviceProtocolString {
    
    BOOL success = NO;
    Class serviceClass = nil;
    if (serviceClassString && ![serviceClassString isEqualToString:@""]) {
        serviceClass = NSClassFromString(serviceClassString);
    }
    
    Protocol *serviceProtocol = nil;
    if (serviceProtocolString && ![serviceProtocolString isEqualToString:@""]) {
        serviceProtocol = NSProtocolFromString(serviceProtocolString);
    }
    
    //如果serviceClass 在bundle中不存在，不注册该服务
    if (serviceClass && serviceProtocol && [serviceClass conformsToProtocol:serviceProtocol]) {
        if ([self.serviceMap objectForKey:[serviceName lowercaseString]] != nil) {
            //注册的时候给予提醒，不允许相同服务名称进行注册，不区分大小写，有重复不予覆盖
            NSAssert(NO, @"service: %@ duplicate register in service bus", serviceName);
        } else {
            [self.serviceMap setObject:serviceClass forKey:[serviceName lowercaseString]];
            success = YES;
        }
    }
    
    // debug阶段给予提示
    else {
        NSAssert(NO, @"service: %@ invalid, reason is serviceImpl(%@) is not impleamted or not "
                 @"conform to protocol (%@)",
                 serviceName, serviceClassString, serviceProtocolString);
    }
    
    return success;
}

+ (id)getService:(NSString *)serviceName {
    return [[ServiceCenter sharedInstance] getService:serviceName];
}

- (id)getService:(NSString *)serviceName {
    //根据serviceName获取在服务总线上的注册
    
    Class serviceClass = [self.serviceMap objectForKey:[serviceName lowercaseString]];
    
    //如果服务的class不存在直接返回Nil
    if (!serviceClass) {
#ifdef DEBUG
        [[Mediator topmostViewController] wm_alterTip:@"调用服务(%@)不存在!请检查代码！"];
#else
#endif
        return nil;
    }
    
    id serviceImpl = [self.serviceImpMap objectForKey:NSStringFromClass(serviceClass)];
    //如果服务存在，检查服务是否启动，如果未启动，马上启动，并返回service实例
    if (!serviceImpl) {
        serviceImpl = [[serviceClass alloc] init];
        [self.serviceImpMap setValue:serviceImpl forKey:NSStringFromClass(serviceClass)];
    }
    
    return serviceImpl;
}

@end
