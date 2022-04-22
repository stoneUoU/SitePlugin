//
//  BaseDefaults.h
//  Kit
//
//  Created by Jim on 2017/11/15.
//  Copyright © 2017年 com.lvxian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDefaultsStorable.h"

/* 基于NSUserDefaults的对象化的轻量级持久化方式.
 * 特性:
    - 持久化数据直接使用属性调用&赋值;
    - 支持全局账户, 支持多账户;
    - 支持版本不断迭代过程中的数据迁移;
    - 方便模块内持久化的统一管理, 方便跨模块调用;
 * 用法:
    - 继承BaseDefaults自定义一个子类, 声明属性, 直接对属性赋值/取值;
    - 基类会使用KVO监听每一个属性, 自动同步到[NSUserDefaults standardUserDefaults]中;
    - BaseDefaults支持的属性类型与NSUserDefaults支持的value类型完全一致;
    - 请不要用来存储容量比较大的数据&敏感数据;
    - 在`-migrate`方法中做旧版记录的迁移;
 */
/**
 * @brief   基于NSUserDefaults的对象化的轻量级持久化方式.
 */
@interface BaseDefaults : NSObject

/**
 * @brief   初始化方法
 
 * @note    默认只创建普通对象, 对象用完即被自动释放;
            如果此对象在工程中使用频繁, 可使用单例方式创建对象, `+usingSingleton`返回YES即可;
 */
+ (instancetype)standardDefaults;
/**
 * @brief   是否使用单例
 
 * @warning 如果替身确实非常有必要使用单例, 则每次get属性值之前可先使用`-synchronizeProperties`同步下数据;
            其他模块做替身时不要覆写此方法, 不然替身的数据可能会不同步;
 
 * @retun   默认返回NO; 如果要使用单例创建对象, 返回YES; 否则, 返回NO;
 */
+ (BOOL)usingSingleton;

/**
 * @brief   是否使用自定义的 NSUserDefaults 存储文件
 
 * @warning 为了避免 [NSUserDefaults standardDefaults] 数据存储越来越大，无特殊需求，这个方法都建议
            复写掉返回 YES，即使用自定义的文件存储

 @return    默认返回NO；建议复写返回YES
 */
- (BOOL)usingCustomDefaults;

/**
 * @brief   当前存储对象使用的名字，可通过以下方法获取到这个 NSUserDefaults 对象
            [NSUserDefaults alloc] initWithSuiteName:[self customDefaultsName]

 * @warning 通常不建议复写这个方法，基类生成这个方法的逻辑是：当前 App 的 BundleID 拼接当前类名生
            成的，可保证这个文件的唯一性，`-initWithSuiteName:`这个方法创建的 Defaults 文件是
            整个 Group 内应用和 Extension 共享的，所以为了避免两个不同应用读写同一份 Defaults
            文件导致的问题，传入的 SuiteName 应该是和当前应用强绑定的。
 
 @return    返回当前存储对象使用的名字
 */
- (NSString *)customDefaultsName;

/**
 * @brief   默认用self.class作为持久化key的一部分, 也可以覆写此方法, 以方便不同模块使用相同的持久化key
 */
- (NSString *)preferredClassNameForDefaultsKey;

/**
 * @brief   需要被忽略持久化存储的属性名的集合
 */
- (NSArray<NSString *> *)ignoredPropertyNamesForPersistentStore;

/**
 * @brief   是否支持多用户/账户
 
 * @note    如果需要区分账户, supportsMultiUser返回YES; 如果不需要区分账户, supportsMultiUser返回NO;
 
 * @warning 如果子类覆写了此方法, 其他模块中的替身也要同时覆写此方法;
 
 * @return  默认返回NO; 对应的userId默认返回@"DefaultsUserDefault";
 */
- (BOOL)supportsMultiUser;
/**
 * @warning 如果子类覆写了此方法, 其他模块中的替身也要同时覆写此方法;
 
 * @return  如果supportsMultiUser返回NO, 默认返回@"DefaultsUserDefault";
            如果supportsMultiUser返回YES, 默认返回[UserInfoUtils userId]/[CommonInfo userId];
 */
- (NSString *)userId;

/**
 * @brief   支持通过 key 直接持久化存储 value, 区别于使用属性的 setter 方法
 */
- (void)setDefaultsValue:(id)value forKey:(NSString *)key;
/**
 * @brief   支持通过 key 获取持久化 value, 区别于使用属性的 getter 方法
 */
- (id)defaultsValueForKey:(NSString *)key;

/**
 * @brief   版本迁移逻辑. 子类覆写`-migrate`方法, 内部调用`-migrateWithVersionIdentifier:block:`方法进行数据迁移;
 
 * @note    触发时机:
            - 全局模式: 1.对象初始化
            - 多账户模式: 1.对象初始化 2.登录 3.登出 4.被踢下线
 */
- (void)migrate;
/**
 * @brief   版本迁移逻辑. 每个版本迁移都有一个版本identifier, 在对应的block方法内做数据迁移;
 
 * @warning 版本identifier一旦上线不可更改, 如果想在新的版本中做数据迁移, 可在一个新的`-migrateWithVersionIdentifier:block:`方法内进行, 并自定义一个新的版本identifier;
 */
- (void)migrateWithVersionIdentifier:(NSString *)versionIdentifier block:(void (^)(void))block;

/**
 * @brief   如果登陆/登出/被踢下线的通知名与默认值不一致, 子类可覆写;
 
 * @note    默认值与Patient/Doctor一致, 故一般可忽略不用覆写;
 
 * @return  `-loginNotificationName` : 默认为@"kNoticeLoginSystem";
            `-logoutNotificationName`: 默认为@"kNoticeLogoutSystem";
            `-kickedOfflineNotificationName`: 默认为@"HttpRequestPermissionLimitedNotification";
 */
- (NSString *)loginNotificationName;
- (NSString *)logoutNotificationName;
- (NSString *)kickedOfflineNotificationName;

/**
 * @brief   可替换掉NSUserDefaults, 改用其他存储方式
 
 * @return  返回实现了BaseDefaultsStorable协议的实例对象
 */
- (id<BaseDefaultsStorable>)storage;

/**
 * @brief   用以优化批量同步数据的性能, 需要集中给属性赋值的时候, 可调用此方法在block里处理
 
 * @discuss 多线程下此优化方法是非完备的;
            如果同一个实例多个线程同时调用此方法, 只要其中一个走出了block, 就会把所有的优化结束掉, 继续使用非优化的方式同步数据, 但结果不会有影响;
 */
- (void)performBatchSynchronization:(void (^)(void))synchronizeBlock;

/**
 * @brief   手动同步最新的持久化数据到属性上;
 
 * @warning 用于单例替身取值不准确的场景, 建议单例替身每次get属性值之前先使用`-synchronizeProperties`同步下数据;
 */
- (void)synchronizeProperties;

/**
 * @brief   清除该类该账户下映射的所有存储数据
 */
- (void)clear;

/**
 * @brief   用于数据迁移之后, 批量删除[NSUserDefaults standardUserDefaults]中存储的值
 */
- (void)removeObjectsInStandardUserDefaultsForKeys:(NSArray<NSString *> *)keys;

@end
