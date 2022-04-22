//
//  HSALocalData+hsa.m
//  HSA-Kit-iOS
//
//  Created by stone on 2020/2/11.
//

#import "HSALocalData+hsa.h"

static NSString *kHSAAPPShake = @"hsaAPPShake";

@implementation HSALocalData (hsa)

+ (void)saveAppShake:(BOOL )appShake {
    [self setObject:@(appShake) forKey:kHSAAPPShake];
};

+ (BOOL )appShake {
    BOOL appShake = [self boolForKey:kHSAAPPShake];
    return appShake;
};

@end
