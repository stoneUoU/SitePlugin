//
//  NSDictionary+Block.h
//  KitDemo
//
//  Created by 红纸 on 16/9/9.
//  Copyright © 2016年 com.lvxian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Block)

/**
 *  遍历每一键值对
 */
- (void)wm_each:(void (^)(id k, id v))block;
/**
 *  遍历每一个key
 */
- (void)wm_eachKey:(void (^)(id k))block;
/**
 *  遍历每一值
 */
- (void)wm_eachValue:(void (^)(id v))block;

/**
 *  遍历字典每个键值对，block有结果的话添加
 */
- (NSArray *)wm_map:(id (^)(id key, id value))block;
/**
 *  从当前字典筛选数组中含有的key
 */
- (NSDictionary *)wm_pick:(NSArray *)keys;
/**
 *  从当前字典忽略某些key
 */
- (NSDictionary *)wm_omit:(NSArray *)key;

@end
