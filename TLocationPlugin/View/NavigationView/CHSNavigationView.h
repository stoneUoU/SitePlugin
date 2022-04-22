//
//  CHSNavigationView.h
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/14.
//  Copyright © 2022 TBD. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHSGradientNavigationModel.h"

typedef void (^CHSNavigationViewClickBlock)(NSInteger index);

@protocol CHSNavigationViewDelegate <NSObject>

@optional

//声明代理方法: 0： 返回按钮     1：右边按钮

- (void)toGradientOperate:(NSInteger )index;

@end

@interface CHSNavigationView : UIView {
}

@property (nonatomic, weak)id<CHSNavigationViewDelegate> delegate;

@property (nonatomic, copy) CHSNavigationViewClickBlock clickBlock;

@property (nonatomic, strong) CHSGradientNavigationModel *model;

@end
