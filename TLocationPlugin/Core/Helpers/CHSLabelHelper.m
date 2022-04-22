//
//  CHSLabelHelper.m
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/15.
//  Copyright © 2022 TBD. All rights reserved.
//

#import "CHSLabelHelper.h"

@implementation CHSLabelHelper

+ (CGFloat)hsa_caluHeightOfString:(NSString *)string withWidth:(CGFloat )width withFont:(UIFont *)font {
    NSDictionary *attributes = @{NSFontAttributeName : font};     //字体属性，设置字体的font
    CGSize maxSize = CGSizeMake(width, CGFLOAT_MAX);
    CGSize size = [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil].size;
    return ceil(size.height);
}

@end
