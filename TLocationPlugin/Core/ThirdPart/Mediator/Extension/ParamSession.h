//
//  ParamSession.h
//  Pods
//
//  Created by qiumx on 2016/12/7.
//
//

#import <UIKit/UIKit.h>
#import "TargetAction.h"

typedef enum : NSUInteger {
    ParamSessionPolicyDefault = 0,//使用一次后销毁
    ParamSessionPolicyReuse,//可以重复赋值，直到注册者被销毁
    ParamSessionPolicyForever,//永久存在
} ParamSessionPolicy;

@interface ParamSession : NSObject
@property (weak, nonatomic) UIViewController *registerVC;
@property (strong, nonatomic) NSDictionary *param;
@property (nonatomic) ParamSessionPolicy policy;
+ (ParamSession *)wm_paramForKey:(NSString*)key;
@end

@interface UIViewController (ParamSession)
/*
 URL获取对应类名作为键值存储传参，route时会被赋值到对应的类名
 */
- (void)wm_setParam:(NSDictionary*)param forURL:(NSURL *)URL;
- (void)wm_setParam:(NSDictionary*)param forURL:(NSURL *)URL withPolicy:(ParamSessionPolicy)policy;

/*
 以key来存取传参，ps：以类名为key时，route该类会自动获取传参，与URL同理
 */
- (void)wm_setParam:(NSDictionary*)param forKey:(NSString *)key;
- (void)wm_setParam:(NSDictionary*)param forKey:(NSString *)key withPolicy:(ParamSessionPolicy)policy;
@end
