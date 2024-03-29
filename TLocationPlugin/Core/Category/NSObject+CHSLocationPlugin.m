//
//  NSObject+CHSLocationPlugin.m
//  CHSLocationPlugin
//
//  Created by stone on 2019/9/4.
//

#import <CoreLocation/CoreLocation.h>
#import "NSObject+CHSLocationPlugin.h"
#import "CHSSafeRuntimeCFunc.h"
#import "CHSLocationHelper.h"
#import "UIWindow+CHSLocationPluginToast.h"
#import <objc/runtime.h>
#import <dlfcn.h>

@implementation NSObject (CHSLocationPlugin)

+ (void)load {
    // Selector Name
    const char *old_location_sel_name = sel_getName(@selector(locationManager:didUpdateToLocation:fromLocation:));
    const char *new_location_sel_name = sel_getName(@selector(locationManager:didUpdateLocations:));
    /// 替换所有方法
    int all_classes_count;
    Class *all_classes = NULL;
    all_classes_count = objc_getClassList(NULL, 0);
    if (all_classes_count > 0 ) {
        all_classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * all_classes_count);
        objc_getClassList(all_classes, all_classes_count);
        for (int i = 0; i < all_classes_count; i++) {
            Class cls = all_classes[i];
            unsigned int methods_count;
            Method *methods = class_copyMethodList(cls, &methods_count);
            for (int i = 0; i < methods_count; i++) {
                const char *selName = sel_getName(method_getName(methods[i]));
                // 是定位函数
                if (strcmp(selName, old_location_sel_name) == 0 ||
                    strcmp(selName, new_location_sel_name) == 0) {
                    [self replaceCLLocationsFunctionToClass:cls];
                    break;
                }
            }
            free(methods);
        }
        free(all_classes);
    }
}

+ (void)replaceCLLocationsFunctionToClass:(Class)cls {
    if ([cls instancesRespondToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
        t_exchange_instance_method(cls, @selector(locationManager:didUpdateToLocation:fromLocation:), @selector(__t_locationManager:didUpdateToLocation:fromLocation:));
    }
    if ([cls instancesRespondToSelector:@selector(locationManager:didUpdateLocations:)]) {
        t_exchange_instance_method(cls, @selector(locationManager:didUpdateLocations:), @selector(__t_locationManager:didUpdateLocations:));
    }
}

- (void)__t_locationManager:(CLLocationManager *)manager
        didUpdateToLocation:(CLLocation *)newLocation
               fromLocation:(CLLocation *)oldLocation API_AVAILABLE(macos(10.6)) {
    BOOL useHook = CHSLocationHelper.shared.usingHookLocation && CHSLocationHelper.shared.hasCachedLocation;
    // 不使用或者暂时暂停使用，调用原方法
    if (!useHook || CHSLocationHelper.shared.isSuspend) {
        [self t_showTostForCLLocation:newLocation];
        [self __t_locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
        return;
    }
    /// CLLocation 使用WGS84坐标
    CLLocation *t_newLocation = [[CLLocation alloc] initWithCoordinate:CHSLocationHelper.shared.randomWGS84Coordinate altitude:newLocation.altitude horizontalAccuracy:newLocation.horizontalAccuracy verticalAccuracy:newLocation.verticalAccuracy course:newLocation.course speed:newLocation.speed timestamp:newLocation.timestamp];
    [self t_showTostForCLLocation:t_newLocation];
    [self __t_locationManager:manager didUpdateToLocation:t_newLocation fromLocation:oldLocation];
}

- (void)__t_locationManager:(CLLocationManager *)manager
         didUpdateLocations:(NSArray<CLLocation *> *)locations {
    BOOL useHook = CHSLocationHelper.shared.usingHookLocation && CHSLocationHelper.shared.hasCachedLocation;
    // 不使用或者暂时暂停使用，调用原方法
    if (!useHook || CHSLocationHelper.shared.isSuspend) {
        [self t_showTostForCLLocations:locations];
        [self __t_locationManager:manager didUpdateLocations:locations];
        return;
    }
    NSMutableArray<CLLocation *> *t_locations = [NSMutableArray<CLLocation *> array];
    for (CLLocation *location in locations) {
        /// CLLocation 使用WGS84坐标
        CLLocation *t_location = [[CLLocation alloc] initWithCoordinate:CHSLocationHelper.shared.randomWGS84Coordinate altitude:location.altitude horizontalAccuracy:location.horizontalAccuracy verticalAccuracy:location.verticalAccuracy course:location.course speed:location.speed timestamp:location.timestamp];
        [t_locations addObject:t_location];
    }
    
    [self t_showTostForCLLocations:t_locations];
    [self __t_locationManager:manager didUpdateLocations:t_locations];
}

- (void)t_showTostForCLLocations:(NSArray<CLLocation *> *)locations {
    if (CHSLocationHelper.shared.usingToast) {
        [UIWindow t_showTostForCLLocations:locations];
    }
}

- (void)t_showTostForCLLocation:(CLLocation *)location {
    if (CHSLocationHelper.shared.usingToast) {
        [UIWindow t_showTostForCLLocation:location];
    }
}

@end

