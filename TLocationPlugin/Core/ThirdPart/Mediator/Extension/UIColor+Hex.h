//
//  UIColor+Hex.h
//  KitDemo
//
//  Created by 红纸 on 16/9/10.
//  Copyright © 2016年 com.lvxian. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Hex)
/**
 * Creates a new UIColor instance using a hex input and alpha value.
 *
 * @param hex {UInt32} Hex
 * @param alpha {CGFloat} Alpha
 *
 * @return {UIColor}
 */
+ (UIColor *)wm_colorWithHex:(UInt32)hex andAlpha:(CGFloat)alpha;

/**
 * Creates a new UIColor instance using a hex input.
 *
 * @param  hex {UInt32} Hex
 *
 * @return {UIColor}
 */
+ (UIColor *)wm_colorWithHex:(UInt32)hex;

/**
 * Creates a new UIColor instance using a hex string input.
 *
 * @param input {NSString} Hex string (ie: @"ff", @"#fff", @"ff0000", or @"ff00ffcc")
 *
 * @return {UIColor}
 */
+ (UIColor *)wm_colorWithHexString:(id)input;

/**
 * Returns the hex value of the receiver. Alpha value is not included.
 *
 * @return {UInt32}
 */
- (UInt32)wm_hexValue;

/**
 *  Return a random color Instace
 *
 *  @return random color
 */
+ (UIColor *)wm_randomColor;
@end
