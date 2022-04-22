//
//  UIConnector.m
//  MediatorDemo
//
//  Created by qiumx on 16/8/17.
//  Copyright © 2016年 Jim. All rights reserved.
//

#import "YYKit.h"
#import "UIConnector.h"
#import "PageManager.h"
#import "MediatorCategory.h"

static NSCache *wd_itemCache = nil;
static NSMutableSet *wd_webItemsSet = nil;

@interface UIConnector ()
@property (nonatomic, strong) ModuleConfig *config;
@end

@implementation UIConnector

#pragma mark - Init

+ (nullable instancetype)connectorWith:(nullable ModuleConfig *)config
{
    id instance = [[self alloc] init];
    if ([instance isKindOfClass:[UIConnector class]])
    {
        UIConnector *connector = (UIConnector *)instance;
        connector.config = config;
        if (wd_webItemsSet==nil) {
            wd_webItemsSet = [[NSMutableSet alloc] init];
        }
        __block NSMutableArray *webItems = [NSMutableArray array];
        [config.router_list enumerateObjectsUsingBlock:^(RouterListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.webConfigs.count > 0 ||
                (obj.webConfig.webPath&&![obj.webConfig.webPath isEqualToString:@""])) {
                [webItems addObject:obj];
            }
        }];
        [wd_webItemsSet addObjectsFromArray:webItems];
    }
    return instance;
}

+ (void)setCacheItem:(RouterListItem*)item forKey:(NSString*)key {
    if (wd_itemCache==nil) {
        wd_itemCache = [[NSCache alloc] init];
        wd_itemCache.countLimit = 100;
    }
    if (item) {
        [wd_itemCache setObject:item forKey:key.md5String];
    }
}

+ (RouterListItem*)cacheItemForKey:(NSString*)key {
    return [wd_itemCache objectForKey:key.md5String];
}


#pragma mark - Public
- (BOOL)isHandleCustomActionForURL:(NSURL *)URL withParams:(nonnull NSDictionary *)params {
    return NO;
}

-(BOOL)canOpenURLPath:(nonnull NSString *)URLPath {
    return [self itemForURLPath:URLPath]?YES:NO;
}

+(BOOL)canOpenWebURL:(nonnull NSURL *)webURL {
    return [self itemForWebURL:webURL]?YES:NO;
}

- (RouterListItem *)itemForURLPath:(NSString *)URLPath {
    RouterListItem *item = [self getRouterListItemWithURLPath:URLPath];
    return item;
}

+ (RouterListItem *)itemForWebURL:(NSURL *)webURL {
    RouterListItem *item = [self getRouterListItemWithWebURL:webURL];
    return item;
}

#pragma mark - Private
/**
 *  根据url获取对应的配置信息
 */
- (nullable RouterListItem *)getRouterListItemWithURLPath:(nullable NSString *)URLPath
{
    if (!URLPath||[URLPath isEqualToString:@""]) {
        return nil;
    }
    __block NSString *ignorePrefix = @"/";
    if ([URLPath hasPrefix:ignorePrefix]) {
        URLPath = [URLPath substringFromIndex:ignorePrefix.length];
    }
    if ([UIConnector cacheItemForKey:URLPath]) {
        return [UIConnector cacheItemForKey:URLPath];
    }

    for (RouterListItem *item in self.config.router_list)
    {
        if ([item.name hasPrefix:ignorePrefix]) {
            item.name = [item.name substringFromIndex:ignorePrefix.length];
        }
        if ([URLPath caseInsensitiveCompare:item.name] == NSOrderedSame) {
            [UIConnector setCacheItem:item forKey:URLPath];
            return item;
        }
    }
    
    return nil;
}

+ (nullable RouterListItem *)getRouterListItemWithWebURL:(nullable NSURL *)webURL
{
    if (!webURL) {
        return nil;
    }
    NSString *URLPath = webURL.wm_path;
    if ([UIConnector cacheItemForKey:[webURL absoluteString]]) {
        return [UIConnector cacheItemForKey:[webURL absoluteString]];
    }
    
    __block RouterListItem *compareItem = nil;
    __block WMHostCompareLevel highLevel = WMHostCompareLevelNone;//记录最高级
    void (^compareHostBlock)(RouterListItem *) = ^(RouterListItem *item){
        //优先匹配自定义域名
        WMHostCompareLevel level = [webURL wm_isCompareHostSet:[NSSet setWithArray:item.webConfig.hosts?:@[]]];
        if (level == WMHostCompareLevelNone) {//自定义域名不匹配，则默认域名
            NSSet *hostSet = [NSSet setWithObjects:@"", nil];
            level = [webURL wm_isCompareHostSet:hostSet];
            if (level>WMHostCompareLevelTwo) {//默认域名匹配不超过2级
                level = WMHostCompareLevelTwo;
            }
        }
        if (highLevel<level) {//域名匹配越高，则优先
            highLevel = level;
            compareItem = item;
        } else if(highLevel==level && compareItem.webConfig.hosts.count>0 && item.webConfig.hosts.count==0) {//当域名匹配层级一致，优先未配置自定义域名
            highLevel = level;
            compareItem = item;
        }
    };
    
    //这里需要全部遍历完成，然后根据优先级选择合适的 RouterListItem，不能够(*stop = YES)中途停止遍历
    [wd_webItemsSet enumerateObjectsUsingBlock:^(RouterListItem *obj, BOOL * _Nonnull stop) {
        [obj.webConfigs enumerateObjectsUsingBlock:^(WebConfig * _Nonnull webConfig, NSUInteger idx, BOOL * _Nonnull stop) {
            RouterListItem *item = [obj copy];
            item.webConfig = [webConfig copy];

            NSString *webPath = webConfig.webPath;
            NSMutableDictionary *params = webConfig.params?[webConfig.params mutableCopy]:[NSMutableDictionary dictionary];
            params[@"requestURL"] = [webURL absoluteString];
            NSDictionary *rPrama = [webPath wm_regexCompare:webURL.path];//提取参数区分字母大小写
            
            if (rPrama) {
                [params addEntriesFromDictionary:rPrama];
                item.webConfig.params = params;
                compareHostBlock(item);
            } else if ([URLPath caseInsensitiveCompare:webPath] == NSOrderedSame) {
                item.webConfig.params = params;
                compareHostBlock(item);
            }
        }];
    }];
    if (compareItem) {
        [UIConnector setCacheItem:compareItem forKey:[webURL absoluteString]];
    }
    return compareItem;
}

@end

@implementation UIConnector (Category)

+ (RouterType)getTypeFromString:(NSString *)strType
{
    NSUInteger index = [[self routeTypeArray] indexOfObject:strType];
    if (index == NSNotFound) {
        return RouterPush;
    }else {
        return index;
    }
}

+ (NSString*)getStringFromType:(RouterType)type {
    if (type >= [[self routeTypeArray] count]) {
        return @"push";
    }else {
        return [[self routeTypeArray] objectAtIndex:type];
    }
}

+ (NSArray *)routeTypeArray {
    return @[@"push",
             @"fade",
             @"present",
             @"custom",
             @"present_custom",
             @"fall"];
}

@end
