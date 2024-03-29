//
//  CHSLocationModel.h
//  CHSLocationPlugin
//
//  Created by stone on 2019/9/4.
//  
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHSLocationModel : NSObject <NSCoding, NSCopying>

/// 名称
@property (nonatomic, copy) NSString *name;

/// 纬度
@property (nonatomic, assign) CLLocationDegrees latitude;

/// 经度
@property (nonatomic, assign) CLLocationDegrees longitude;

/// 是否是当前选择的数据
@property (nonatomic, assign) BOOL isSelect;

@property (nonatomic, assign) BOOL hidden;

+ (instancetype)modelWithName:(NSString *)name
                     latitude:(CLLocationDegrees)latitude
                    longitude:(CLLocationDegrees)longitude;

+ (instancetype)modelWithSubLocality:(nullable NSString *)subLocality
                                name:(NSString *)name
                            latitude:(CLLocationDegrees)latitude
                           longitude:(CLLocationDegrees)longitude;

- (NSString *)locationText;

@end

NS_ASSUME_NONNULL_END
