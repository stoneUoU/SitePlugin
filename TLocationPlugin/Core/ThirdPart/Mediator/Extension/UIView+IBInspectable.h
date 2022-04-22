//
//  UIView+IBInspectable.h
//  Patient
//
//  Created by qiumx on 15/10/27.
//  Copyright © 2015年 FLy. All rights reserved.
//

#import <UIKit/UIKit.h>

//http://nshipster.cn/ibinspectable-ibdesignable/
//Xcode6 新特性，使得下面的属性在Interface Builder中也可以展现
@interface UIView (WMIBInspectable)
//圆角
@property (assign,nonatomic) IBInspectable CGFloat cornerRadius;
//边框宽度
@property (assign,nonatomic) IBInspectable CGFloat   borderWidth;
//是否裁剪
@property (assign,nonatomic) IBInspectable BOOL      masksToBounds;
//边框颜色
@property (strong,nonatomic) IBInspectable UIColor   *borderColor;
@end
