//
//  ModuleConfig.m
//  MediatorDemo
//
//  Created by qiumx on 16/8/18.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import "YYKit.h"
#import "ModuleConfig.h"

@implementation ModuleBaseConfig


+ (instancetype)configWith:(NSDictionary *)dic {
    id instance = [[self alloc] init];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [instance setValue:obj forKey:key];
        }];
    }
    return instance;
}

@end

@implementation ModuleConfig

- (NSString *)name {
    return [_name lowercaseString];
}

- (void)setRouter_list:(NSArray<RouterListItem *> *)router_list
{
    NSArray *list;
    if ([router_list isKindOfClass:[NSDictionary class]]) {
        list = [(NSDictionary*)router_list allValues];
    } else if ([router_list isKindOfClass:[NSArray class]]) {
        list = router_list;
    }
    
    NSMutableArray *arr = [NSMutableArray array];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [arr addObject:[RouterListItem configWith:obj]];
        }
    }];
    _router_list = arr;
}


- (void)setService_list:(NSArray<ServiceListItem *> *)service_list
{
    NSArray *list;
    if ([service_list isKindOfClass:[NSDictionary class]]) {
        list = [(NSDictionary*)service_list allValues];
    } else if ([service_list isKindOfClass:[NSArray class]]) {
        list = service_list;
    }
    NSMutableArray *arr = [NSMutableArray array];
    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            [arr addObject:[ServiceListItem configWith:obj]];
        }
    }];
    _service_list = arr;
}

@end

@implementation RouterListItem

- (id)copyWithZone:(NSZone *)zone {
    RouterListItem *item = [[[self class] allocWithZone:zone] init];
    item.name = self.name;
    item.className = self.className;
    item.type = self.type;
    item.webConfig = [self.webConfig copy];
    item.webConfigs = [[NSArray alloc] initWithArray:self.webConfigs copyItems:YES];
    item.needLogin = self.needLogin;
    item.unique = self.unique;
    return item;
}

- (NSString *)name {
    return [_name lowercaseString];
}

- (void)setWebPath:(NSString *)webPath {
    if (!_webConfig) {
        _webConfig = [[WebConfig alloc] init];
        _webConfig.webPath = webPath;
    }
}

- (void)setWebConfig:(WebConfig *)webConfig {
    if ([webConfig isKindOfClass:[NSDictionary class]]) {
        _webConfig = [WebConfig configWith:(NSDictionary*)webConfig];
    } else {
        _webConfig = webConfig;
    }
    
    if (_webConfig&&[_webConfig.webPath isNotBlank]) {
        self.webConfigs = @[_webConfig];
    } else {
        self.webConfigs = @[];
    }
}

- (void)setWebConfigs:(NSArray<WebConfig *> *)webConfigs {
    NSMutableArray *mConfigs = @[].mutableCopy;
    for (WebConfig *item in webConfigs) {
        WebConfig *config;
        if ([item isKindOfClass:[NSDictionary class]]) {
            config = [WebConfig configWith:(NSDictionary*)item];
        } else if ([item isKindOfClass:[WebConfig class]]) {
            config = item;
        }
        if (config
            &&[config isKindOfClass:[WebConfig class]]
            &&[config.webPath isNotBlank]) {
            [mConfigs addObject:config];
        }
    }
    
    _webConfigs = mConfigs;
}

@end

@implementation WebConfig

- (id)copyWithZone:(NSZone *)zone {
    WebConfig *webConfig = [[[self class] allocWithZone:zone] init];
    webConfig.webPath = self.webPath;
    webConfig.hosts = [NSArray arrayWithArray:self.hosts];
    webConfig.params = [NSDictionary dictionaryWithDictionary:self.params];
    return webConfig;
}

- (void)setWebPath:(NSString *)webPath {
    NSString *ignorePrefix = @"/";
    if ([webPath hasPrefix:ignorePrefix]) {
        webPath = [webPath substringFromIndex:ignorePrefix.length];
    }
    if ([webPath hasSuffix:ignorePrefix]) {
        webPath = [webPath substringToIndex:webPath.length-ignorePrefix.length];
    }
    _webPath = webPath;
}

- (void)setHosts:(NSArray *)hosts {
    if ([hosts isKindOfClass:[NSArray class]]) {
        _hosts = hosts;
    }
}

- (void)setParams:(NSDictionary *)params {
    if ([params isKindOfClass:[NSDictionary class]]) {
        _params = params;
    }
}

@end

@implementation ServiceListItem

@end
