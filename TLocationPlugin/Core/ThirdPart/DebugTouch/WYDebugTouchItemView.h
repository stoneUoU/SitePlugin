//
//  WYDebugTouchItemView.h
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/15.
//
//

#import <UIKit/UIKit.h>
#import "XFATItemView.h"

@class WYDebugTouchModuleModel;

@interface WYDebugTouchItemView : XFATItemView

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *titleLabel;

- (void)dealWithModuleSelected:(BOOL)isSeleted;

- (void)configWithModel:(WYDebugTouchModuleModel *)model;

@end
