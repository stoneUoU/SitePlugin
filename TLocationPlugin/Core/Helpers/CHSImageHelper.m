//
//  CHSImageHelper.m
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/14.
//  Copyright © 2022 TBD. All rights reserved.
//

#import "CHSImageHelper.h"

@implementation CHSImageHelper


+ (void)drawLineByImageView:(UIImageView *)imageView withColor:(UIColor *)color {
    [imageView layoutIfNeeded];
    UIGraphicsBeginImageContext(imageView.frame.size);   //开始画线 划线的frame
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    //设置线条终点形状
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
    
    CGContextRef line = UIGraphicsGetCurrentContext();
    // 设置颜色
    CGContextSetStrokeColorWithColor(line, color.CGColor);
    CGFloat lengths[] = {5,2};//先画4个点再画2个点
    CGContextSetLineDash(line,0, lengths,2);//注意2(count)的值等于lengths数组的长度
    
    CGContextMoveToPoint(line, 0.0, 2.0);    //开始画线
    CGContextAddLineToPoint(line,imageView.frame.size.width,2.0);
    CGContextStrokePath(line);
    // UIGraphicsGetImageFromCurrentImageContext()返回的就是image
    UIImage *image =   UIGraphicsGetImageFromCurrentImageContext();
    imageView.image = image;
}


@end
