//
//  CALayer+CHSLocationPlugin.m
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/6.
//  
//

#import "CALayer+CHSLocationPlugin.h"

@implementation CALayer (CHSLocationPlugin)

- (UIColor *)t_borderUIColor {
    return [UIColor colorWithCGColor:self.borderColor];
}

- (void)setT_borderUIColor:(UIColor *)t_borderUIColor {
    self.borderColor = t_borderUIColor.CGColor;
}

@end
