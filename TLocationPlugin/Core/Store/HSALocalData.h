//
//  HSALocalData.h
//  HSA-Kit-iOS
//
//  Created by stone on 2020/2/11.
//

#import <Foundation/Foundation.h>

@interface HSALocalData : NSObject

/**
 *  保存到NSUserDefaults
 *
 *  @param object 保存内容
 *  @param key    保存Key
 */
+ (void)setObject:(NSObject *)object forKey:(NSString *)key;
/**
 *  获取保存的NSUserDefaults
 *
 *  @param key 保存的key
 *
 *  @return 保存的内容
 */
+ (id)objectForKey:(NSString *)key;

+ (BOOL)boolForKey:(NSString *)key;
+ (NSInteger)integerForKey:(NSString *)key;
+ (float)floatForKey:(NSString *)key;
+ (double)doubleForKey:(NSString *)key;

+ (void)setArchivedData:(id)data forKey:(NSString *)key;
+ (id)unarchiveObjectForKey:(NSString *)key;

@end

@interface NSString (Extension)

/**
 字符串是否为空
 
 @return YES/NO
 */
- (BOOL)hsa_isNotEmptyOrNil;

@end
