//
//  UIView+IBInspectable.m
//  Patient
//
//  Created by qiumx on 15/10/27.
//  Copyright © 2015年 FLy. All rights reserved.
//

#import "UIView+IBInspectable.h"

@implementation UIView (WMIBInspectable)
#pragma mark - setCornerRadius/borderWidth/borderColor
- (void)setCornerRadius:(CGFloat)cornerRadius{
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
}

- (CGFloat)cornerRadius{
    return self.layer.cornerRadius;
}

- (void)setBorderWidth:(CGFloat)borderWidth{
    self.layer.borderWidth = borderWidth;
}

- (CGFloat)borderWidth{
    return self.layer.borderWidth;
}

- (void)setBorderColor:(UIColor *)borderColor{
    self.layer.borderColor = borderColor.CGColor;
}

- (UIColor *)borderColor{
    return [UIColor colorWithCGColor:self.layer.borderColor];
}
- (void)setMasksToBounds:(BOOL)bounds{
    self.layer.masksToBounds = bounds;
}

- (BOOL)masksToBounds{
    return self.layer.masksToBounds;
}
@end
