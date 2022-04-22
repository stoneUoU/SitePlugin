//
//  WYDebugTouchImplementation.m
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/17.
//
//

#import <AudioToolbox/AudioToolbox.h>

#import "Mediator.h"
#import "WYDebugTouch.h"
#import "WYDebugTouchImplementation.h"
#import "WYDebugTouchNavigationController.h"

@interface WYDebugTouchImplementation()

@end

@implementation WYDebugTouchImplementation

- (void)registerModuleWithName:(NSString *)moduleName
                    imageName:(NSString *)imageName
                  handleBlock:(void (^)(NSString *moduleName, BOOL *isHighLight))handleBlock {
    [WYDebugTouch registerModuleWithName:moduleName
                              imageName:imageName
                            handleBlock:handleBlock];
}

- (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
            highLightImageName:(NSString *)highLightImageName
                   handleBlock:(void (^)(NSString *moduleName, BOOL *isHighLight))handleBlock {
    [WYDebugTouch registerModuleWithName:moduleName
                               imageName:imageName
                      highLightImageName:highLightImageName
                             handleBlock:handleBlock];
}

- (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
            highLightImageName:(NSString *)highLightImageName
                     isOnBlock:(void (^)(NSString *moduleName, BOOL *isOn))isOnBlock
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock {
    [WYDebugTouch registerModuleWithName:moduleName
                               imageName:imageName
                      highLightImageName:highLightImageName
                               isOnBlock:isOnBlock
                             handleBlock:handleBlock];
}

- (void)registerModuleWithName:(NSString *)moduleName
                        params:(NSDictionary *)params
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock {
    [WYDebugTouch registerModuleWithName:moduleName params:params handleBlock:handleBlock];
}

- (BOOL)isEnable {
    return [WYDebugTouch isEnable];
}

- (void)setIsEnable:(BOOL)isEnable {
    [WYDebugTouch setIsEnable:isEnable];
}

- (void)showTouch {
    [WYDebugTouch showTouch];
}

- (void)dismissTouch {
    [WYDebugTouch dismissTouch];
}

- (BOOL)isShakeWillShowAlert {
    return [WYDebugTouch isShakeWillShowAlert];
}

- (void)showDebugAlertWithHandle:(void (^)(BOOL isOn))handle {
    if ([self isEnable]) {
        !handle ?: handle(YES);
        return;
    }
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"请问是否开启调试服务？" preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [WYDebugTouch setIsEnable:true];
        !handle ?: handle(YES);
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        !handle ?: handle(YES);
    }]];
    [[Mediator topmostViewController] presentViewController:controller animated:YES completion:nil];
}

@end
