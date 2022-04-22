//
//  UIColor+CHSLocationPlugin.h
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/14.
//  Copyright © 2022 TBD. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (CHSLocationPlugin)

+ (UIColor *)color_OCHexStr: (NSString *) hexString;

+ (CGFloat)colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length;

@end

NS_ASSUME_NONNULL_END
