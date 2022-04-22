//
//  UIImage+CHSLocationPlugin.m
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/5.
//  
//

#import "UIImage+CHSLocationPlugin.h"
#import "NSBundle+CHSLocationPlugin.h"

@implementation UIImage (CHSLocationPlugin)

+ (nullable instancetype)t_imageNamed:(NSString *)name {
    static NSBundle *imageBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageBundle = [NSBundle bundleWithPath:[NSBundle.t_bundle pathForResource:@"CHSLocationPluginImages" ofType:@"bundle"]];
    });
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (nullable instancetype)chs_imageNamed:(NSString *)name {
    static NSBundle *imageBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageBundle = [NSBundle bundleWithPath:[NSBundle.t_bundle pathForResource:@"WYDebugTouch" ofType:@"bundle"]];
    });
    NSString *imagePath = [imageBundle pathForResource:name ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    return image;
}

+ (instancetype)t_imageWithColor:(UIColor *)color {
    return [self t_imageWithColor:color size:CGSizeMake(1, 1)];
}

+ (instancetype)t_imageWithColor:(UIColor *)color size:(CGSize)size {
    if (!color || size.width <= 0 || size.height <= 0) return nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
