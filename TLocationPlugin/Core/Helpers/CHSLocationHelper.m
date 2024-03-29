//
//  CHSLocationHelper.m
//  CHSLocationPlugin
//
//  Created by stone on 2019/9/4.
//  
//

#import "CHSLocationHelper.h"
#import "CHSLocationPluginHelper.h"

@implementation CHSLocationHelper {
    NSString                    *_locationName;
    CLLocationDegrees           _latitude;
    CLLocationDegrees           _longitude;
    NSInteger                   _range;
    BOOL                        _usingHookLocation;
    BOOL                        _usingToast;
    NSArray<CHSLocationModel *>   * _cacheDataArray;
}

@synthesize locationName        = _locationName;
@synthesize latitude            = _latitude;
@synthesize longitude           = _longitude;
@synthesize range               = _range;
@synthesize usingHookLocation   = _usingHookLocation;
@synthesize usingToast          = _usingToast;
@synthesize cacheDataArray      = _cacheDataArray;


#pragma mark - Singletion
#pragma mark -

static CHSLocationHelper *_instance;
+ (CHSLocationHelper *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#if __has_feature(objc_arc)
        _instance = [[self alloc] init];
        NSString *path = _instance.cacheDataArrayArchivePath;
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            _instance->_cacheDataArray = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        }
#else
        _instance = [[[self alloc] init] autorelease];
#endif
    });
    return _instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}

- (instancetype)init {
    self = [super init];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (self) {}
    });
    return self;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

#if !__has_feature(objc_arc)
- (instancetype)retain { return self; }
- (NSUInteger)retainCount { return NSUIntegerMax; }
- (oneway void)release {}
- (instancetype)autorelease{ return self; }
#endif

#pragma mark - locationName
static NSString * const _t_locationNameKey = @"_T_CacheKeyTypeLocationName";
- (NSString *)locationName {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_locationName = [[NSUserDefaults standardUserDefaults] stringForKey:_t_locationNameKey];
    });
    return self->_locationName;
}
- (void)setLocationName:(NSString *)locationName {
    self->_locationName = locationName;
    [[NSUserDefaults standardUserDefaults] setObject:locationName forKey:_t_locationNameKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - latitude
static NSString * const _t_latitudeKey = @"_T_CacheKeyTypeLatitude";
- (CLLocationDegrees)latitude {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_latitude = [[NSUserDefaults standardUserDefaults] doubleForKey:_t_latitudeKey];
    });
    return self->_latitude;
}
- (void)setLatitude:(CLLocationDegrees)latitude {
    self->_latitude = latitude;
    [[NSUserDefaults standardUserDefaults] setDouble:latitude forKey:_t_latitudeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - longitude
static NSString * const _t_longitudeKey = @"_T_CacheKeyTypeLongitude";
- (CLLocationDegrees)longitude {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_longitude = [[NSUserDefaults standardUserDefaults] doubleForKey:_t_longitudeKey];
    });
    return self->_longitude;
}
- (void)setLongitude:(CLLocationDegrees)longitude {
    self->_longitude = longitude;
    [[NSUserDefaults standardUserDefaults] setDouble:longitude forKey:_t_longitudeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - range
static NSString * const _t_rangeKey = @"_T_CacheKeyTypeRange";
- (NSInteger)range {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_range = [[NSUserDefaults standardUserDefaults] integerForKey:_t_rangeKey];
        if (self->_range <= 0) {
            self->_range = 10;
        }
    });
    
    return self->_range;
}
- (void)setRange:(NSInteger)range {
    self->_range = range;
    if (self->_range <= 0) {
        self->_range = 10;
    }
    [[NSUserDefaults standardUserDefaults] setInteger:self->_range forKey:_t_rangeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - usingHookLocation
static NSString * const _t_usingHookLocationKey = @"_T_CacheKeyTypeUsingHookLocation";
- (BOOL)usingHookLocation {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_usingHookLocation = [[NSUserDefaults standardUserDefaults] boolForKey:_t_usingHookLocationKey];
    });
    return self->_usingHookLocation;
}
- (void)setUsingHookLocation:(BOOL)usingHookLocation {
    self->_usingHookLocation = usingHookLocation;
    [[NSUserDefaults standardUserDefaults] setBool:usingHookLocation forKey:_t_usingHookLocationKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - usingToast
static NSString * const _t_usingToastKey = @"_T_CacheKeyTypeUsingToast";
- (BOOL)usingToast {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self->_usingToast = [[NSUserDefaults standardUserDefaults] boolForKey:_t_usingToastKey];
    });
    return self->_usingToast;
}
- (void)setUsingToast:(BOOL)usingToast {
    self->_usingToast = usingToast;
    [[NSUserDefaults standardUserDefaults] setBool:usingToast forKey:_t_usingToastKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - cacheDataArray
- (NSString *)cacheDataArrayArchivePath {
    static NSString *_t_cacheDataArrayArchivePath = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray<NSString *> *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirPath = [paths lastObject];
        _t_cacheDataArrayArchivePath = [documentDirPath stringByAppendingPathComponent:@"_T_CacheKeyTypeDataArray.archiver"];
    });
    return _t_cacheDataArrayArchivePath;
}

- (NSArray<CHSLocationModel *> *)cacheDataArray {
    return self->_cacheDataArray;
}

- (void)setCacheDataArray:(NSArray<CHSLocationModel *> *)cacheDataArray {
    self->_cacheDataArray = cacheDataArray;
}

- (NSUInteger)cacheDataArrayHash {
    NSUInteger hash = 0;
    for (CHSLocationModel *model in self->_cacheDataArray) {
        // 左移确保返回 hash 与顺序相关
        hash = (hash << 1) ^ model.hash;
    }
    return hash;
}

- (void)saveCacheDataArray {
    NSString *path = self.cacheDataArrayArchivePath;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
    if (self->_cacheDataArray != nil) {
        [NSKeyedArchiver archiveRootObject:self->_cacheDataArray toFile:self.cacheDataArrayArchivePath];
    }
}

- (BOOL)hasCachedLocation {
    return self.longitude != 0 && self.latitude != 0;
}

#pragma mark - Random Values
- (CLLocationDegrees)randomLatitude {
    return [self rangeDegressForDegrees:self.latitude];
}

- (CLLocationDegrees)randomLongitude {
    return [self rangeDegressForDegrees:self.longitude];
}

- (CLLocationCoordinate2D)randomGCJ02CoordinateCoordinate {
    /// 地图点击的坐标默认就是国测局坐标
    return CLLocationCoordinate2DMake(self.randomLatitude, self.randomLongitude);
}

- (CLLocationCoordinate2D)randomWGS84Coordinate {
    return [CHSLocationPluginHelper gcj02ToWgs84:self.randomGCJ02CoordinateCoordinate];
}


/// 取 15/16 位有效数字
- (CLLocationDegrees)rangeDegressForDegrees:(CLLocationDegrees)degrees {
    NSInteger randomRange = arc4random() % self.range;
    
    /// 从小数点后第五位开始加/减 randomRange
    CLLocationDegrees randomDegrees = randomRange * 0.00001;
    CLLocationDegrees newDegrees;
    
    /// 随机加减
    if (arc4random() % 2 == 0) {
        newDegrees = degrees + randomDegrees;
    } else {
        newDegrees = degrees - randomDegrees;
    }
    
    /// 转换为 String 处理
    NSString *newDegreesString = @(newDegrees).stringValue;
    NSRange decimalPointRange = [newDegreesString rangeOfString:@"."];
    if (decimalPointRange.location == NSNotFound) {
        newDegreesString = [newDegreesString stringByAppendingString:@"."];
    } else {
        /// + 后 5 位
        NSUInteger toIndex = decimalPointRange.location + decimalPointRange.length + 5;
        if (toIndex <= newDegreesString.length) {
            newDegreesString = [newDegreesString substringToIndex:toIndex];
        } else {
            /// 不进行截取操作
            /// 但是应该不可能到这里吧, 除非数据本来长度就很小而且 randomRange 是 10 的倍数
        }
    }
    
    /// 去除首尾 `空格`
    static NSCharacterSet *trimmingSet = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        trimmingSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    });
    [newDegreesString stringByTrimmingCharactersInSet:trimmingSet];
    /// 16 位有效数字 + 1 位小数点 + (负号 ? 1 : 0)
    NSUInteger toLenght = 16 + 1 + ([newDegreesString hasPrefix:@"-"] ? 1 : 0);
    while (newDegreesString.length < toLenght) {
        newDegreesString = [newDegreesString stringByAppendingFormat:@"%d", arc4random() % 10];
    };
    
    /// 转换为 double (CLLocationDegrees)
    newDegrees = newDegreesString.doubleValue;
    
    return newDegrees;
}

@end
