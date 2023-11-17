//
//  CHSBlankView.m
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/15.
//  Copyright © 2022 TBD. All rights reserved.
//
#import "UIColor+CHSLocationPlugin.h"
#import "UIImage+CHSLocationPlugin.h"
#import "CHSBlankView.h"
#import "Masonry.h"
#import "MediatorDefine.h"

@interface CHSBlankView()

@property (nonatomic, strong) UIImageView *netImageView;

@property (nonatomic, strong) UILabel *failureLabel;

@property (nonatomic, strong) UIButton *excuteButton;

@end

@implementation CHSBlankView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self setUI];
    }
    return self;
}

- (void)setUI {
    
    [self addSubview:self.netImageView];
    [self addSubview:self.failureLabel];
    [self addSubview:self.excuteButton];
    
    [self setMas];
}

- (void)setMas {
    
    [self.netImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_top).offset(16);
        make.size.equalTo(@(CGSizeMake(200, 132)));
    }];
    [self.failureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.netImageView.mas_bottom);
        make.left.equalTo(self.mas_left).offset(16);
        make.right.equalTo(self.mas_right).offset(-16);
        make.centerX.equalTo(self);
    }];
    [self.excuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.failureLabel.mas_bottom).offset(64);
        make.centerX.equalTo(self);
        make.size.equalTo(@(CGSizeMake(SCREENWIDTH - 32, 44)));
        make.bottom.equalTo(self.mas_bottom).offset(-16);
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)toExcute:(UIButton *)sender {
    !self.handle ?: self.handle();
}

- (UIImageView *)netImageView {
    if(_netImageView == nil) {
        _netImageView = [[UIImageView alloc] init];
        _netImageView.image = [UIImage t_imageNamed:@"blank"];
    }
    return _netImageView;
}

- (UILabel *)failureLabel {
    if(_failureLabel == nil) {
        _failureLabel = [[UILabel alloc] init];
        _failureLabel.font = [UIFont systemFontOfSize:16];
        _failureLabel.textColor = [UIColor color_OCHexStr:@"#303133"];
        _failureLabel.textAlignment = NSTextAlignmentCenter;
        _failureLabel.numberOfLines = 0;
        _failureLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _failureLabel;
}

- (UIButton *)excuteButton {
    if(_excuteButton == nil) {
        _excuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_excuteButton setTitle:@"添加位置" forState:UIControlStateNormal];
        _excuteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _excuteButton.tag = 1;
        _excuteButton.layer.cornerRadius = 22.0;
        _excuteButton.layer.masksToBounds = YES;
        _excuteButton.backgroundColor = [UIColor color_OCHexStr:@"#3B71E8"];
        [_excuteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_excuteButton addTarget:self action:@selector(toExcute:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _excuteButton;
}

@end
