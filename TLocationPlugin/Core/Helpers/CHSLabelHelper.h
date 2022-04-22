//
//  CHSLabelHelper.h
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/15.
//  Copyright © 2022 TBD. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHSLabelHelper : NSObject

+ (CGFloat)hsa_caluHeightOfString:(NSString *)string withWidth:(CGFloat )width withFont:(UIFont *)font;

@end

NS_ASSUME_NONNULL_END
