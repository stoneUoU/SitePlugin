//
//  NSArray+Block.m
//  KitDemo
//
//  Created by 红纸 on 16/9/9.
//  Copyright © 2016年 com.lvxian. All rights reserved.
//

#import "NSArray+Block.h"

@implementation NSArray (Block)

- (void)wm_each:(void (^)(id object))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)wm_eachWithIndex:(void (^)(id object, NSUInteger index))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj, idx);
    }];
}

- (NSArray *)wm_map:(id (^)(id object))block {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    
    for (id object in self) {
        [array addObject:block(object) ?: [NSNull null]];
    }
    
    return array;
}

- (NSArray *)wm_filter:(BOOL (^)(id object))block {
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return block(evaluatedObject);
    }]];
}

- (NSArray *)wm_reject:(BOOL (^)(id object))block {
    return [self filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        return !block(evaluatedObject);
    }]];
}

- (id)wm_detect:(BOOL (^)(id object))block {
    for (id object in self) {
        if (block(object))
            return object;
    }
    return nil;
}

- (id)wm_reduce:(id (^)(id accumulator, id object))block {
    return [self wm_reduce:nil withBlock:block];
}

- (id)wm_reduce:(id)initial withBlock:(id (^)(id accumulator, id object))block {
    id accumulator = initial;
    
    for(id object in self)
        accumulator = accumulator ? block(accumulator, object) : object;
    
    return accumulator;
}

@end
