//
//  HSALocalData+hsa.h
//  HSA-Kit-iOS
//
//  Created by stone on 2020/2/11.
//

#import "HSALocalData.h"

NS_ASSUME_NONNULL_BEGIN

@interface HSALocalData (hsa)

/**
 *  存手机是否开启振动:
 */
+ (void)saveAppShake:(BOOL )appShake;

+ (BOOL )appShake;

@end

NS_ASSUME_NONNULL_END
