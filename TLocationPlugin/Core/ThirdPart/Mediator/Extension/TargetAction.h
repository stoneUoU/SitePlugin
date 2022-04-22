//
//  TargetAction.h
//  TargetAction
//
//  Created by qiumx on 16/3/21.
//  Copyright © 2016年 qiumx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediatorDefine.h"

NS_ASSUME_NONNULL_BEGIN
@interface NSObject (TargetAction)
- (id)performAction:(NSString *)actionName, ...;
+ (id)md_getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig;
+ (void)md_setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig andArgs:(va_list)args;
@end
NS_ASSUME_NONNULL_END
