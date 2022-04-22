//
//  ParamSession.m
//  Pods
//
//  Created by qiumx on 2016/12/7.
//
//

#import "ParamSession.h"
#import "Mediator.h"

static NSMutableDictionary *wp_sessions;

@implementation ParamSession

+ (ParamSession *)wm_paramForKey:(NSString*)key {
    ParamSession *session = [wp_sessions valueForKey:key];
    if (!session.registerVC) {
        if (session.policy==ParamSessionPolicyForever) {
            return session;
        } else {
            [wp_sessions removeObjectForKey:key];
            return nil;
        }
    }
    if (session.policy==ParamSessionPolicyDefault) {
        [wp_sessions removeObjectForKey:key];
    }
    return session;
}

@end

@implementation UIViewController (ParamSession)

- (void)wm_setParam:(NSDictionary *)param forURL:(NSURL *)URL {
    [self wm_setParam:param forURL:URL withPolicy:ParamSessionPolicyDefault];
}

-  (void)wm_setParam:(NSDictionary *)param forURL:(NSURL *)URL withPolicy:(ParamSessionPolicy)policy {
    [Mediator canRouteURL:URL withItemBlock:^(RouterListItem * _Nonnull routerItem) {
        if (routerItem) {
            [self wm_setParam:param forKey:routerItem.className withPolicy:policy];
        }
    }];
}

- (void)wm_setParam:(NSDictionary *)param forKey:(NSString *)key {
    [self wm_setParam:param forKey:key withPolicy:ParamSessionPolicyDefault];
}

- (void)wm_setParam:(NSDictionary *)param forKey:(NSString *)key withPolicy:(ParamSessionPolicy)policy {
    ParamSession *session = [[ParamSession alloc] init];
    session.registerVC = self;
    session.param = param;
    session.policy = policy;
    if (!wp_sessions) {
        wp_sessions = [[NSMutableDictionary alloc] init];
    }
    [wp_sessions setValue:session forKey:key];
}

@end
