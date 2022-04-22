//
//  CHSAlertController.h
//  CHSLocationPlugin
//
//  Created by TBD on 2019/9/6.
//  
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CHSAlertController;
typedef void(^CHSAlertControllerBlock)(CHSAlertController *alert, UIAlertAction *action);

@interface CHSAlertController: UIAlertController

/// 一个取消按钮
+ (instancetype)singleActionAlertWithTitle:(nullable NSString *)title
                                   message:(nullable NSString *)message
                               actionTitle:(nullable NSString *)actionTitle
                               actionBlock:(nullable CHSAlertControllerBlock)actionBlock;


/// confirmTitle 在左, cancelTitle 在右
+ (instancetype)confirmAlertWithTitle:(nullable NSString *)title
                              message:(nullable NSString *)message
                          cancelTitle:(nullable NSString *)cancelTitle
                          cancelBlock:(nullable CHSAlertControllerBlock)cancelBlock
                         confirmTitle:(nullable NSString *)confirmTitle
                         confirmBlock:(nullable CHSAlertControllerBlock)confirmBlock;

/// destructiveTitle 在左, cancelTitle 在右
+ (instancetype)destructiveAlertWithTitle:(nullable NSString *)title
                                  message:(nullable NSString *)message
                              cancelTitle:(nullable NSString *)cancelTitle
                              cancelBlock:(nullable CHSAlertControllerBlock)cancelBlock
                         destructiveTitle:(nullable NSString *)destructiveTitle
                         destructiveBlock:(nullable CHSAlertControllerBlock)destructiveBlock;

/// 编辑框
+ (instancetype)editAlertWithTitle:(nullable NSString *)title
                           message:(nullable NSString *)message
                        labelTexts:(nullable NSArray<NSString *> *)labelTexts
                     defaultValues:(nullable NSArray<NSString *> *)defaultValues
                       cancelTitle:(nullable NSString *)cancelTitle
                       cancelBlock:(nullable CHSAlertControllerBlock)cancelBlock
                      confirmTitle:(nullable NSString *)confirmTitle
                      confirmBlock:(nullable CHSAlertControllerBlock)confirmBlock;
/// 翻转 Actions 顺序
- (void)reverseActions;
/// 添加 Action
- (void)addAction:(UIAlertAction *)action;
/// 删除 Action
- (void)removeAction:(UIAlertAction *)action;

@end

NS_ASSUME_NONNULL_END
