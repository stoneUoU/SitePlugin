//
//  CHSGradientNavigationModel.h
//  HSA-BaseUI-iOS
//
//  Created by stone on 2020/7/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CHSGradientNavigationModel : NSObject

//左边icon:
@property (nonatomic, assign) NSString *leftImage;

//中间的标题:
@property (nonatomic, copy) NSString *title;

//中间的标题颜色:
@property (nonatomic, strong) UIColor *titleColor;

//导航栏背景色:
@property (nonatomic, strong) UIColor *bgColor;

//右边的按钮的图片:
@property (nonatomic, strong) NSString *rightImage;

//右边的按钮:
@property (nonatomic, copy) NSString *rightTitle;

//右边靠左的按钮:
@property (nonatomic, strong) NSString *excuteImage;

//右边的按钮文字颜色:
@property (nonatomic, strong) UIColor *rightTitleColor;

//渐变开始颜色：
@property (nonatomic, strong) UIColor *startGradientColor;

//渐变结束颜色：
@property (nonatomic, strong) UIColor *endGradientColor;

@end

NS_ASSUME_NONNULL_END
