//
//  HSADebugTouchTemp.h
//  HSA-DebugTools-iOS
//
//  Created by xiecj1 on 2019/11/1.
//

#import <UIKit/UIKit.h>

#define WY_IOS_AVAILABLE(v) @available(iOS v , *)
#define WY_DEPRECATED_IOS(_iosIntro, _iosDep, ...) __attribute__((deprecated(__VA_ARGS__)))
#define WY_NS_DEPRECATED_IOS(_iosIntro, _iosDep, ...) NS_DEPRECATED_IOS(_iosIntro, _iosDep, __VA_ARGS__)

/******************************    UI      ***********************************/
#define SCREENHEIGHT  ([UIScreen mainScreen].bounds.size.height)
#define SCREENWIDTH   ([UIScreen mainScreen].bounds.size.width)
#define RGB(R, G, B)    [UIColor colorWithRed:R/255.0f green:G/255.0f blue:B/255.0f alpha:1.0f]
#define RGBA(R,G,B,A)   [UIColor colorWithRed:(R)/255.0f \
green:(G)/255.0f blue:(B)/255.0f alpha:(A)]
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


#import <Security/Security.h>


NS_ASSUME_NONNULL_BEGIN

@interface WYKeychain : NSObject

/**
 *  Keychain标示 为了支持多设备，serive是作为搜索Key的，所以默认为com.guahao.keychain
 */
@property (nonatomic, readonly) NSString *service;

/**
 *  存储的Group 默认为Nil，执行时不添加，项目将默认使用BundleID
 */
@property (nonatomic, readonly) NSString *accessGroup;

///---------------------------------------------------
/// @快速创建方法
///---------------------------------------------------

+ (WYKeychain *)sharedKeychain;//单例

+ (WYKeychain *)keychain;

+ (WYKeychain *)keychainWithService:(NSString *)service;

+ (WYKeychain *)keychainWithService:(NSString *)service accessGroup:(NSString *)accessGroup;

///---------------------------------------------------
/// @init 方法
///---------------------------------------------------

- (instancetype)init;

- (instancetype)initWithService:(NSString *)service;

- (instancetype)initWithService:(NSString *)service accessGroup:(NSString *)accessGroup;

///---------------------------------------------------
/// @存储方法
///---------------------------------------------------

- (void)saveString:(NSString *)string forKey:(NSString *)key;

- (void)saveString:(NSString *)string forKey:(NSString *)key error:(NSError **)error;

- (void)saveData:(NSData *)data forKey:(NSString *)key;

- (void)saveData:(NSData *)data forKey:(NSString *)key error:(NSError **)error;

///---------------------------------------------------
/// @删除方法
///---------------------------------------------------

- (void)deleteEntryForKey:(NSString *)key;

- (void)deleteEntryForKey:(NSString *)key error:(NSError **)error;

- (void)clearAll;

///---------------------------------------------------
/// @查询方法
///---------------------------------------------------

- (NSArray<NSDictionary<NSString *,id> *> *)fetchAllAccount;

- (NSArray<NSDictionary<NSString *,id> *> *)fetchAllAccount:(NSError **)error;

- (NSString *)stringForKey:(NSString *)key;

- (NSString *)stringForKey:(NSString *)key error:(NSError **)error;

- (NSData *)dataForKey:(NSString *)key;

- (NSData *)dataForKey:(NSString *)key error:(NSError **)error;

- (BOOL)hasValueForKey:(NSString *)key;

- (BOOL)hasValueForKey:(NSString *)key error:(NSError **)error;

#pragma mark - 详解
- (NSString *)description;

@end


@interface NSObject (Runtime)

#pragma mark - Associate value

/**
 *  设置强引用类型关联
 *
 *  @param value 值
 *  @param key   key
 */
- (void)wy_setAssociateValue:(id)value withKey:(void *)key;
- (void)wy_setAssociateValue:(id)value withKeyString:(NSString *)key;


/**
 *  设置弱引用类型的关联
 *
 *  @param value 值
 *  @param key   key
 */
- (void)wy_setAssociateWeakValue:(id)value withKey:(void *)key;
- (void)wy_setAssociateWeakValue:(id)value withKeyString:(NSString *)key;

/**
 *  通过key获取关联的对象内容
 *
 *  @param key 存储时使用的key
 *
 *  @return self中关联到key的值
 */
- (id)wy_getAssociatedValueForKey:(void *)key;
- (id)wy_getAssociatedValueForKeyString:(NSString *)key;

/**
 *  移除所有self的关联内容
 */
- (void)wy_removeAssociatedValues;

#pragma mark - Swizzle Method

/**
 *  实例方法交换
 *
 *  @param originalSel oldMethod
 *  @param newSel      newMethod
 *
 *  @return 是否交换成功
 */
+ (BOOL)wy_swizzleInstanceMethod:(SEL)originalSel with:(SEL)newSel;

/**
 *  类方法交换
 *
 *  @param originalSel oldMethod
 *  @param newSel      newMethod
 *
 *  @return 是否 交换成功
 */
+ (BOOL)wy_swizzleClassMethod:(SEL)originalSel with:(SEL)newSel;


/**
 交换实例方法
 
 @param orignalCls 原方法存在的类
 @param originalSel 原方法名
 @param newCls 替换方法存在的类
 @param newSel 替换方法名
 @return 是否交换成功
 */
+ (BOOL)wy_swizzleInstanceMethodWithOrignalCls:(Class)orignalCls
                                    orignalSel:(SEL)originalSel
                                      newClass:(Class)newCls
                                        newCls:(SEL)newSel;

#pragma mark - is Override Super Method

/**
 判断父类方法是否被子类重写
 
 @param cls 子类class
 @param sel 检测的方法sel
 @return 是否被重写
 */
- (BOOL)wy_isMethodOverride:(Class)cls selector:(SEL)sel WY_DEPRECATED_IOS('1.1.2','1.1.4',"改用父类的方法");

/**
 判断父类方法是否被子类重写
 
 @param cls 子类class
 @param sel 检测的方法sel
 @return 是否被重写
 */
+ (BOOL)wy_isMethodOverride:(Class)cls selector:(SEL)sel;

@end


@interface HSADebugTouchTemp : NSObject


@end

@interface NSObject (SysFeedBack)

/**
 系统震动反馈
 */
- (void)wy_touchFeedBack;

@end

@interface NSObject (Selector)

- (id)wy_performSelectorWithArgsWithSelectorName:(NSString *)actionName, ...;

- (nullable id)wy_performSelectorWithArgs:(SEL)sel, ...;

- (void)wy_performSelectorWithArgs:(SEL)sel afterDelay:(NSTimeInterval)delay, ...;

- (nullable id)wy_performSelectorWithArgsOnMainThread:(SEL)sel waitUntilDone:(BOOL)wait, ...;

- (nullable id)wy_performSelectorWithArgs:(SEL)sel onThread:(NSThread *)thread waitUntilDone:(BOOL)wait, ...;

- (void)wy_performSelectorWithArgsInBackground:(SEL)sel, ...;

- (void)wy_performSelector:(SEL)sel afterDelay:(NSTimeInterval)delay;

+ (void)wykit_setInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig andArgs:(va_list)args;

+ (id)wykit_getReturnFromInv:(NSInvocation *)inv withSig:(NSMethodSignature *)sig;


@end

NS_ASSUME_NONNULL_END
