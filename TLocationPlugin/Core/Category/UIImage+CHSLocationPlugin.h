//
//  UIImage+CHSLocationPlugin.h
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/5.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (CHSLocationPlugin)

+ (nullable instancetype)t_imageNamed:(NSString *)name;

+ (nullable instancetype)chs_imageNamed:(NSString *)name;

+ (instancetype)t_imageWithColor:(UIColor *)color;
+ (instancetype)t_imageWithColor:(UIColor *)color size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
