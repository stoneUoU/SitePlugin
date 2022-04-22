//
//  WYDebugTouch.h
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/8.
//
//

#import <Foundation/Foundation.h>

static NSString * const kWYDebugTouchIsDefaultEnableFlag = @"WYDebugTouchIsDefaultEnableFlag";

@class WYDebugTouchModuleModel;

@interface WYDebugTouch : NSObject

+ (void)registerModuleWithName:(NSString *)moduleName
                    imageName:(NSString *)imageName
                  handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock;

+ (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
            highLightImageName:(NSString *)highLightImageName
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock;

+ (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
            highLightImageName:(NSString *)highLightImageName
                     isOnBlock:(void (^)(NSString *moduleName, BOOL *isOn))isOnBlock
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock;

+ (void)registerModuleWithName:(NSString *)moduleName
                        params:(NSDictionary *)params
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock;

+ (BOOL)isEnable;

+ (void)setIsEnable:(BOOL)isEnable;

+ (void)setup;

+ (void)setupWithAutoIndent:(BOOL)autoIndent;

+ (void)refreshAllModuleState;

+ (NSArray<WYDebugTouchModuleModel *> *)registerModuleArray;

+ (void)showTouch;

+ (void)dismissTouch;

+ (BOOL)isShakeWillShowAlert;

@end
