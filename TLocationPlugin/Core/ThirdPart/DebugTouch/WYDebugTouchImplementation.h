
//
//  WYDebugTouchImplementation.h
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/17.
//
//

#import <Foundation/Foundation.h>

@protocol WYDebugTouchRegisteProtocol <NSObject>


#pragma mark - 1.0
/**
 注册模块

 @param moduleName 模块名
 @param imageName itemView的默认图片，如果再Bundle里面的话要写对应的Bundle
 @param handleBlock 点击Item或者Cell执行的自定义操作
 */
- (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
                   handleBlock:(void (^)(NSString *moduleName, BOOL *isHighLight))handleBlock;

/**
 注册模块

 @param moduleName 模块名
 @param imageName itemView的默认图片，如果再Bundle里面的话要写对应的Bundle
 @param highLightImageName itemView的高亮图片，如果再Bundle里面的话要写对应的Bundle
 @param handleBlock 点击Item或者Cell执行的自定义操作
 */
- (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
            highLightImageName:(NSString *)highLightImageName
                   handleBlock:(void (^)(NSString *moduleName, BOOL *isHighLight))handleBlock;


/**
 注册模块

 @param moduleName 模块名
 @param imageName itemView的默认图片，如果再Bundle里面的话要写对应的Bundle
 @param highLightImageName itemView的高亮图片，如果再Bundle里面的话要写对应的Bundle
 @param isOnBlock 在Touch需要显示的时候获取开关信息
 @param handleBlock 点击Item或者Cell执行的自定义操作
 */
- (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
            highLightImageName:(NSString *)highLightImageName
                     isOnBlock:(void (^)(NSString *moduleName, BOOL *isOn))isOnBlock
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock;

#pragma mark - 1.1


/**
 注册模块

 @param moduleName 模块名
 @param params 参数
 @param handleBlock 点击Item或者Cell执行的自定义操作
 
 Note: params keys
 defaultIsOn: Bool // 第一次打开的时候是否为打开
 defaultImageName: NSString // 默认的图片
 highLightImageName: NSString // 高亮显示的图片
 defaultTitleName: NSString // 默认显示的名称
 hightLightTitleName: NSString // 高亮显示的名称
 prioprity: NSInteger // 显示优先级 default:0 高优先级:100
 moduleType: NSInteger // 显示在哪个分组内 1: 数据 2: 网络 3:UI 4:混合应用
 */
- (void)registerModuleWithName:(NSString *)moduleName
                        params:(NSDictionary *)params
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock;

/**
 打开Touch
 */
- (void)showTouch;

/**
 隐藏Touch
 */
- (void)dismissTouch;

/**
 获取WYDebugTouch是否打开

 @return 开关状态
 */
- (BOOL)isEnable;


/**
 设置WYDebugTouch是否打开

 @param isEnable 开关状态
 */
- (void)setIsEnable:(BOOL)isEnable;


/**
 回调摇一摇是否会弹出Alert来显示DebugTouch

 @return 回调摇一摇是否会弹出Alert来显示DebugTouch
 */
- (BOOL)isShakeWillShowAlert;

- (void)showDebugAlertWithHandle:(void (^)(BOOL isOn))handle;

@end

@interface WYDebugTouchImplementation : NSObject<WYDebugTouchRegisteProtocol>


@end
