//
//  BaseDefaults.m
//  Kit
//
//  Created by Jim on 2017/11/15.
//  Copyright © 2017年 com.lvxian. All rights reserved.
//

#import "YYKit.h"
#import "BaseDefaults.h"
#import <objc/runtime.h>

static NSString * const DefaultsDefaultUserId = @"DefaultsUserDefault";
static NSString * const DefaultsMigrationVersionIdentifierPrefix = @"DefaultsMigrated";

static NSString * const DefaultsLoginSystemNotification = @"kNoticeLoginSystem";
static NSString * const DefaultsLogoutSystemNotification = @"kNoticeLogoutSystem";
static NSString * const DefaultsKickedOfflineNotification = @"HttpRequestPermissionLimitedNotification";

static NSString * const DefaultsAssociatedKey = @"DefaultsAssociatedKey";

@interface BaseDefaults () {
    /* 内部变量命名统一加双下划线, 是为了防止与子类属性自动生成的变量重名而引起混淆
     */
    NSMutableSet *__propertyNamesSet;
    NSString *__preferredUserId;
    BOOL __isAddingObserveForProperties;
    NSNumber *__isObservingForProperties;
    NSNumber *__isObservingForLoginout;
    NSNumber *__isMigrating;
    BOOL __isWaitingForWriting;
    NSMutableDictionary *__waitingForWritingDict;
}

@end

@implementation BaseDefaults

#pragma mark - Life cycle

+ (instancetype)standardDefaults
{
    Class class = [self class];
    if (![self usingSingleton]) {
        return [[class alloc] init];
    }
    @synchronized(class) {
        /* 这里是为了解决使用dispatch_once的方式生成的单例无法被子类化的问题;
         * 将子类的一个实例与子类绑定, 每次都取用这个被绑定的实例, 实现可子类化的单例;
         */
        id sharedInstance = objc_getAssociatedObject(class, &DefaultsAssociatedKey);
        if (!sharedInstance) {
            sharedInstance = [[class alloc] init];
            objc_setAssociatedObject(class, &DefaultsAssociatedKey, sharedInstance, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        return sharedInstance;
    }
}

+ (BOOL)usingSingleton
{
    return NO;
}

- (BOOL)usingCustomDefaults {
    return NO;
}

- (NSString *)customDefaultsName {
    return [NSString stringWithFormat:@"%@.%@", [[NSBundle mainBundle] bundleIdentifier],  NSStringFromClass(self.class)];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self supportsMultiUser]) {
            NSString *userId = [self userId];
            BOOL hasUserId = [userId isNotBlank];
            __preferredUserId = hasUserId ? userId : DefaultsDefaultUserId;
            [self addObserverForProperties];
            [self addNotificationForLoginout];
        } else {
            __preferredUserId = DefaultsDefaultUserId;
            [self addObserverForProperties];
        }
        [self migrateIfNeeded];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserverForProperties];
    [self removeNotificationForLoginout];
}

- (void)destroy
{
    objc_setAssociatedObject(self, &DefaultsAssociatedKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark - Public

- (NSString *)preferredClassNameForDefaultsKey
{
    return NSStringFromClass([self class]);
}

- (NSArray<NSString *> *)ignoredPropertyNamesForPersistentStore
{
    return nil;
}

- (BOOL)supportsMultiUser
{
    return NO;
}

- (NSString *)userId
{
    return DefaultsDefaultUserId;
}

- (void)setDefaultsValue:(id)value forKey:(NSString *)key
{
    if (!key ||
        ![key isKindOfClass:[NSString class]] ||
        [key isEqualToString:@""]) {
        return;
    }
    NSString *localVariableKey = [NSString stringWithFormat:@"_%@", key];
    [self setValue:value forKey:localVariableKey];
    [self updateDefaultsDictWithKey:key value:value];
}

- (id)defaultsValueForKey:(NSString *)key
{
    if (!key ||
        ![key isKindOfClass:[NSString class]] ||
        [key isEqualToString:@""]) {
        return nil;
    }
    NSDictionary * _Nonnull defaultsDict = [self defaultsDict];
    return defaultsDict[key];
}

- (void)migrate
{
    
}

- (void)migrateWithVersionIdentifier:(NSString *)versionIdentifier block:(void (^)(void))block
{
    if (![versionIdentifier isNotBlank]) {
        NSAssert(NO, @"The migrating version identifier can not be empty.");
        return;
    }
    NSString *preferredVersionIdentifier = [NSString stringWithFormat:@"%@_%@", DefaultsMigrationVersionIdentifierPrefix, versionIdentifier];
    
    NSDictionary *defaultsDict = [self defaultsDict];
    if ([defaultsDict boolValueForKey:preferredVersionIdentifier default:NO]) {
        return;
    }
    if (!block) {
        return;
    }
    block();
    
    [self updateDefaultsDictWithKey:preferredVersionIdentifier value:@YES];
}

- (NSString *)loginNotificationName
{
    return DefaultsLoginSystemNotification;
}

- (NSString *)logoutNotificationName
{
    return DefaultsLogoutSystemNotification;
}

- (NSString *)kickedOfflineNotificationName
{
    return DefaultsKickedOfflineNotification;
}

- (id<BaseDefaultsStorable>)storage
{
    if ([self usingCustomDefaults]) {
        return (id<BaseDefaultsStorable>)[[NSUserDefaults alloc] initWithSuiteName:[self customDefaultsName]];
    } else {
        return (id)[NSUserDefaults standardUserDefaults];
    }
}

- (void)performBatchSynchronization:(void (^)(void))synchronizeBlock
{
    __isWaitingForWriting = YES;
    if (synchronizeBlock) {
        synchronizeBlock();
    }
    __isWaitingForWriting = NO;
    [self writeWaitingDictIntoStorage];
}

- (void)synchronizeProperties
{
    [self synchronizePropertiesWithEnumerateHandler:nil];
}

- (void)clear
{
    NSString *defaultsKey = [self defaultsKey];
    id<BaseDefaultsStorable> storage = [self storage];
    [storage removeObjectForKey:defaultsKey];
    [storage synchronize];
}

- (void)removeObjectsInStandardUserDefaultsForKeys:(NSArray<NSString *> *)keys
{
    id<BaseDefaultsStorable> storage = [self storage];
    for (NSString *key in keys) {
        [storage removeObjectForKey:key];
    }
    [storage synchronize];
}

#pragma mark - Observing For Properties

- (void)addObserverForProperties
{
    @synchronized(__isObservingForProperties) {
        if ([__isObservingForProperties boolValue]) {
            return;
        }
        __isObservingForProperties = @YES;
        __isAddingObserveForProperties = YES;
        
        __propertyNamesSet = nil;
        __propertyNamesSet = [NSMutableSet set];
        
        [self synchronizePropertiesWithEnumerateHandler:^(NSString *propertyName) {
            [self addObserver:self forKeyPath:propertyName options:NSKeyValueObservingOptionNew context:nil];
            [__propertyNamesSet addObject:propertyName];
        }];
        
        __isAddingObserveForProperties = NO;
    }
}

- (void)removeObserverForProperties
{
    @synchronized(__isObservingForProperties) {
        if (![__isObservingForProperties boolValue]) {
            return;
        }
        __isObservingForProperties = @NO;
        
        [__propertyNamesSet enumerateObjectsUsingBlock:^(id  _Nonnull obj, BOOL * _Nonnull stop) {
            [self removeObserver:self forKeyPath:obj];
        }];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (__isAddingObserveForProperties) {
        return;
    }
    if (__isWaitingForWriting) {
        if (!__waitingForWritingDict) {
            __waitingForWritingDict = [NSMutableDictionary dictionary];
        }
        [__waitingForWritingDict setValue:[self valueForKey:keyPath] forKey:keyPath];
    } else {
        [self updateDefaultsDictWithKey:keyPath value:[self valueForKey:keyPath]];
    }
}

#pragma mark - Observing For Loginout

- (void)addNotificationForLoginout
{
    if (![self supportsMultiUser]) {
        return;
    }
    @synchronized(__isObservingForLoginout) {
        if ([__isObservingForLoginout boolValue]) {
            return;
        }
        __isObservingForLoginout = @YES;
        
        NSString *loginNotificationName = [self loginNotificationName];
        NSString *logoutNotificationName = [self logoutNotificationName];
        NSString *kickedOfflineNotificationName = [self kickedOfflineNotificationName];
        
        if ([loginNotificationName isNotBlank]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didLogin:)
                                                         name:loginNotificationName
                                                       object:nil];
        }
        if ([logoutNotificationName isNotBlank]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didLogout:)
                                                         name:logoutNotificationName
                                                       object:nil];
        }
        if ([kickedOfflineNotificationName isNotBlank]) {
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(didLogout:)
                                                         name:kickedOfflineNotificationName
                                                       object:nil];
        }
    }
}

- (void)removeNotificationForLoginout
{
    @synchronized(__isObservingForLoginout) {
        if (![__isObservingForLoginout boolValue]) {
            return;
        }
        __isObservingForLoginout = @NO;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)didLogin:(id)sender
{
    if (![self supportsMultiUser]) {
        return;
    }
    __preferredUserId = [self userId];
    [self removeObserverForProperties];
    [self addObserverForProperties];
    [self migrateIfNeeded];
}

- (void)didLogout:(id)sender
{
    if (![self supportsMultiUser]) {
        return;
    }
    __preferredUserId = DefaultsDefaultUserId;
    [self removeObserverForProperties];
    [self addObserverForProperties];
    [self migrateIfNeeded];
}

#pragma mark - Private

- (void)migrateIfNeeded
{
    @synchronized(__isMigrating) {
        [self migrate];
    }
}

- (NSString *)defaultsKey
{
    return [NSString stringWithFormat:@"%@_%@", __preferredUserId, [self preferredClassNameForDefaultsKey]];
}

- (nonnull NSDictionary *)defaultsDict
{
    NSDictionary *defaultsDict = [[self storage] objectForKey:[self defaultsKey]];
    if (!defaultsDict || ![defaultsDict isKindOfClass:[NSDictionary class]]) {
        defaultsDict = [NSDictionary dictionary];
    }
    return defaultsDict;
}

- (void)updateDefaultsDictWithKey:(NSString *)key value:(id)value
{
    NSString *defaultsKey = [self defaultsKey];
    NSDictionary * _Nonnull defaultsDict = [self defaultsDict];
    
    NSMutableDictionary *mutableDefaultsDict = [NSMutableDictionary dictionaryWithDictionary:defaultsDict];
    mutableDefaultsDict[key] = value;
    NSDictionary *newDefaultsDict = [NSDictionary dictionaryWithDictionary:mutableDefaultsDict];
    
    id<BaseDefaultsStorable> storage = [self storage];
    [storage setObject:newDefaultsDict forKey:defaultsKey];
    [storage synchronize];
}

- (void)writeWaitingDictIntoStorage
{
    if (__waitingForWritingDict.count == 0) {
        return;
    }
    NSString *defaultsKey = [self defaultsKey];
    NSDictionary * _Nonnull defaultsDict = [self defaultsDict];
    
    NSMutableDictionary *mutableDefaultsDict = [NSMutableDictionary dictionaryWithDictionary:defaultsDict];
    [mutableDefaultsDict setValuesForKeysWithDictionary:__waitingForWritingDict];
    [__waitingForWritingDict removeAllObjects];
    NSDictionary *newDefaultsDict = [NSDictionary dictionaryWithDictionary:mutableDefaultsDict];
    
    id<BaseDefaultsStorable> storage = [self storage];
    [storage setObject:newDefaultsDict forKey:defaultsKey];
    [[self storage] synchronize];
}

- (void)synchronizePropertiesWithEnumerateHandler:(void (^)(NSString *propertyName))enumerateHandler
{
    unsigned int outCount = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    NSDictionary *defaultsDict = [self defaultsDict];
    
    for (NSInteger i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *propertyName = [NSString stringWithFormat:@"%s", property_getName(property)];
        
        if ([[self ignoredPropertyNamesForPersistentStore] containsObject:propertyName]) {
            continue;
        }
        
        id value = defaultsDict[propertyName];
        if (value) {
            [self setValue:value forKey:propertyName];
        }
        
        if (enumerateHandler) {
            enumerateHandler(propertyName);
        }
    }
    free(properties);
}

@end
