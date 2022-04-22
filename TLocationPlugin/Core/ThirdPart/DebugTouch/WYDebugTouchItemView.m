//
//  WYDebugTouchItemView.m
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/15.
//
//

#import "YYKit.h"
#import "Masonry.h"
#import "UIView+ViewUtils.h"
#import "UIImage+CHSLocationPlugin.h"
#import "WYDebugTouchItemView.h"
#import "WYDebugTouchModuleModel.h"

@interface WYDebugTouchItemView ()

@end

@implementation WYDebugTouchItemView

- (instancetype)init{
    if (self = [super init]) {
        [self setUI];
    }
    return self;
}

#pragma mark - setup UI
- (void)setUI{
    self.imageView = ({
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.image = [UIImage chs_imageNamed:@"debug_logo"];
        imageView;
    });
    self.titleLabel = ({
        UILabel *label = [[UILabel alloc] init];
        label.textColor = [UIColor whiteColor];
        label.text = @"模块名称";
        label.adjustsFontSizeToFitWidth = true;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        label;
    });

    
    // Frame
    CGFloat margin = 15;
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(self).mas_offset(margin);
        make.right.mas_equalTo(self).mas_offset(-margin);
        make.height.mas_equalTo((self.height - 3* margin)/5 * 4);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(margin);
        make.right.bottom.mas_equalTo(self).mas_offset(-margin);
        make.height.mas_equalTo((self.height - 2* margin)/5);
        make.top.mas_equalTo(self.imageView.bottom).mas_offset(-margin).priority(MASLayoutPriorityDefaultHigh);
    }];
}

#pragma mark - Deal

- (void)dealWithModuleSelected:(BOOL)isSeleted {
    if (isSeleted) {
        self.titleLabel.textColor = [UIColor colorWithHexString:@"1296db"];
    }else{
        self.titleLabel.textColor = [UIColor whiteColor];
    }
}

- (void)configWithModel:(WYDebugTouchModuleModel *)model{
    // title
    model.itemView = self;
    [self dealWithModuleSelected:model.isOn];
    if (model.isOn) {
        if (model.highLightImageName) {
            [self setImage:model.highLightImageName];
        }
        self.titleLabel.text = model.hightLightTitleName?:model.defaultTitleName;
    } else {
        if (model.imageName) {
            [self setImage:model.imageName];
        }else{
            self.imageView.image = [UIImage chs_imageNamed:@"debug_logo"];
        }
        self.titleLabel.text = model.defaultTitleName;
    }
}

- (void)setImage:(NSString *)aStr {
    if ([aStr.lowercaseString hasPrefix:@"http"]
        || [aStr.lowercaseString hasPrefix:@"https"]) {
        self.imageView.image = [UIImage chs_imageNamed:@"debug_logo"];
    }else {
        self.imageView.image = [UIImage chs_imageNamed:aStr];
    }
}

- (void)setFrame:(CGRect)frame {
    self.layer.frame = frame;
}

- (void)setCenter:(CGPoint)center {
    self.layer.center = center;
}

@end
