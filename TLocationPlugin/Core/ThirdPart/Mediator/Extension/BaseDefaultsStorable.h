//
//  BaseDefaults.h
//  
//
//  Created by Jim on 2017/11/15.
//  Copyright © 2017年 com.lvxian. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol BaseDefaultsStorable <NSObject>

@required

- (nullable id)objectForKey:(NSString *)key;

- (void)setObject:(nullable id)object forKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

- (void)synchronize;

@end

NS_ASSUME_NONNULL_END
