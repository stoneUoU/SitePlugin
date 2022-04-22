//
//  CHSGradientNavigationView.h
//  HSA-BaseUI-iOS
//
//  Created by stone on 2020/7/9.
//

#import <UIKit/UIKit.h>
#import "CHSGradientNavigationModel.h"

typedef void (^CHSGradientNavigationViewClickBlock)(NSInteger index);

@protocol CHSGradientNavigationViewDelegate <NSObject>

@optional

//声明代理方法: 0： 返回按钮     1：右边按钮

- (void)toGradientOperate:(NSInteger )index;

@end

@interface CHSGradientNavigationView : UIView {
}

@property (nonatomic, weak)id<CHSGradientNavigationViewDelegate> delegate;

@property (nonatomic, copy) CHSGradientNavigationViewClickBlock clickBlock;

@property (nonatomic, strong) CHSGradientNavigationModel *model;

@end
