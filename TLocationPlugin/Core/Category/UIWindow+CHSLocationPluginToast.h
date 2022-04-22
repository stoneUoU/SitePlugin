//
//  UIWindow+CHSLocationPluginToast.h
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/5.
//  
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIWindow (CHSLocationPluginToast)

+ (void)t_showTostForMessage:(NSString *)message;
+ (void)t_showTostForMessage:(NSString *)message fontSize:(CGFloat)fontSize;

+ (void)t_showTostForCLLocation:(CLLocation *)location;
+ (void)t_showTostForCLLocations:(NSArray<CLLocation *> *)locations;

@end

NS_ASSUME_NONNULL_END
