//
//  NSArray+Block.h
//  KitDemo
//
//  Created by 红纸 on 16/9/9.
//  Copyright © 2016年 com.lvxian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Block)

/**
 *  遍历
 *
 *  @param block 查询的Block
 */
- (void)wm_each:(void (^)(id object))block;
/**
 *  遍历，block携带index
 *
 *  @param block 携带Index的查询Block
 */
- (void)wm_eachWithIndex:(void (^)(id object, NSUInteger index))block;
/**
 *  遍历
 *  当Value遍历的时候，可以返回相应的obj，添加到数组中返回
 *
 *  @param block 携带Obj的Block
 *
 *  @return NSArray
 */
- (NSArray *)wm_map:(id (^)(id object))block;

/**
 *  过滤数组中数据
 *
 *  @param block  捕获到数组中的object给block，block内部将返回的数据进行判断，返回1则该object继续保持在数组
 *
 *  @return NSArray
 */
- (NSArray *)wm_filter:(BOOL (^)(id object))block;

/**
 * 过滤数组中数据
 *
 *  @param block 捕获到数组中的object给block，block内部将返回的数据进行判断，返回0取反，则该object继续保持在数组
 *
 *  @return NSArray
 */
- (NSArray *)wm_reject:(BOOL (^)(id object))block;

/**
 *  循环遍历检测数组中是否存在某个object
 *
 *  @param block 使用block捕获object来判断
 *
 *  @return id:object
 */
- (id)wm_detect:(BOOL (^)(id object))block;

/**
 *  循环遍历数组，accumulator为上次遍历的结果，第一次为nil
 *
 *  @param block 计算下次使用的accumlator
 *
 *  @return 返回block的最后一次计算结果
 */
- (id)wm_reduce:(id (^)(id accumulator, id object))block;

/**
 *  循环遍历数组，accumulator为上次遍历的结果，默认为initial
 *
 *  @param initial 第一次计算的初始值
 *  @param block   计算下次使用的accumlator
 *
 *  @return 返回block的最后一次计算结果
 */
- (id)wm_reduce:(id)initial withBlock:(id (^)(id accumulator, id object))block;

@end
