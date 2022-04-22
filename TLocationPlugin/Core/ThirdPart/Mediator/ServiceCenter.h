//
//  ServiceCenter.h
//  MediatorDemo
//
//  Created by qiumx on 16/8/17.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TargetAction.h"

@interface ServiceCenter : NSObject
AS_SINGLETON;
NS_ASSUME_NONNULL_BEGIN
/**
 * 通过key-value给服务总线注册服务
 *
 */
+ (BOOL)registerService:(NSString *)serviceName
                       class:(NSString *)serviceClassString
                    protocol:(NSString *)serviceProtocolString;
- (BOOL)registerService:(NSString *)serviceName
                  class:(NSString *)serviceClassString
               protocol:(NSString *)serviceProtocolString;
/**
 *  从服务总线中获取某个服务
 *
 */
+ (id)getService:(NSString *)serviceName;
- (id)getService:(NSString *)serviceName;
NS_ASSUME_NONNULL_END
@end
