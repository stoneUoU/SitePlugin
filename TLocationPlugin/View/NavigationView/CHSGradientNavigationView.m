//
//  CHSGradientNavigationView.m
//  HSA-BaseUI-iOS
//
//  Created by stone on 2020/7/9.
//
#import "UIImage+CHSLocationPlugin.h"
#import "CHSGradientNavigationView.h"
#import "Masonry.h"
#import "MediatorDefine.h"

@interface CHSGradientNavigationView() {

}

@property (nonatomic, strong) UIView *statusView;

@property (nonatomic, strong) UIView *navigationView;

@property (nonatomic, strong) UIButton *backButton;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *operateButton;

@end

@implementation CHSGradientNavigationView

#pragma mark - LifeCycle
#pragma mark -

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame ];//当前对象self
    if (self !=nil) {
        [self setUI];
    }
    return self;//返回一个已经初始化完毕的对象；
}

#pragma mark - Public Method
#pragma mark -

- (void)setModel:(CHSGradientNavigationModel *)model {
    _model = model;
    
    CAGradientLayer *statusGradient = [CAGradientLayer layer];
    statusGradient.frame = self.statusView.bounds;
    statusGradient.colors = @[(id)model.startGradientColor.CGColor,(id)model.endGradientColor.CGColor];
    statusGradient.startPoint = CGPointMake(0, 1);
    statusGradient.endPoint = CGPointMake(1, 1);
    [self.statusView.layer addSublayer:statusGradient];
    
    CAGradientLayer *naviGradient = [CAGradientLayer layer];
    naviGradient.frame = self.navigationView.bounds;
    naviGradient.colors = @[(id)model.startGradientColor.CGColor,(id)model.endGradientColor.CGColor];
    naviGradient.startPoint = CGPointMake(0, 1);
    naviGradient.endPoint = CGPointMake(1, 1);
    [self.navigationView.layer addSublayer:naviGradient];
    
    self.titleLabel.textColor = model.titleColor;
    self.titleLabel.text = model.title;
    [self.backButton setImage:[UIImage t_imageNamed:model.leftImage]forState:UIControlStateNormal];
    if (model.rightImage.length != 0) {
        self.operateButton.hidden = NO;
        [self.operateButton setImage:[UIImage t_imageNamed:model.rightImage] forState:UIControlStateNormal];
    } else {
        if (model.rightTitle.length != 0) {
            self.operateButton.hidden = NO;
            [self.operateButton setTitleColor:model.rightTitleColor forState:UIControlStateNormal];
            [self.operateButton setTitle:model.rightTitle forState:UIControlStateNormal];
        }
    }
    [self.navigationView bringSubviewToFront:self.backButton];
    [self.navigationView bringSubviewToFront:self.titleLabel];
    [self.navigationView bringSubviewToFront:self.operateButton];
}

#pragma mark - Private Method
#pragma mark -

- (void)setUI {
    [self addSubview:self.statusView];
    [self addSubview:self.navigationView];
    [self.navigationView addSubview:self.backButton];
    [self.navigationView addSubview:self.titleLabel];
    [self.navigationView addSubview:self.operateButton];
    
    [self setMas];
}

- (void)setMas {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navigationView);
        make.left.equalTo(self.navigationView.mas_left).offset(0);
        make.height.mas_equalTo(NavBarHeight);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.navigationView);
    }];
    [self.operateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.navigationView);
        make.right.equalTo(self.navigationView.mas_right).offset(0);
        make.height.mas_equalTo(NavBarHeight);
    }];
}

#pragma mark - IB-Action
#pragma mark -

- (void)toOperate:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toGradientOperate:)]) {
        [self.delegate toGradientOperate:sender.tag];
    }
    !self.clickBlock ?: self.clickBlock(sender.tag);
}


#pragma mark - Notice
#pragma mark -


#pragma mark - Delegate
#pragma mark -


#pragma mark - lazy load
#pragma mark -

- (UIView *)statusView {
    if(_statusView == nil) {
        _statusView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, StatusBarHeight)];
    }
    return _statusView;
}

- (UIView *)navigationView {
    if(_navigationView == nil) {
        _navigationView = [[UIView alloc] initWithFrame:CGRectMake(0, StatusBarHeight, SCREENWIDTH, NavBarHeight)];
    }
    return _navigationView;
}

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    return _titleLabel;
}

- (UIButton *)backButton {
    if(_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton addTarget:self action:@selector(toOperate: )forControlEvents:UIControlEventTouchUpInside];
        _backButton.tag = 0;
        [self setButton:_backButton fitSize:CGSizeMake(30,0)];
    }
    return _backButton;
}

- (UIButton *)operateButton {
    if(_operateButton == nil) {
        _operateButton = [[UIButton alloc] init];
        [_operateButton addTarget:self action:@selector(toOperate: )forControlEvents:UIControlEventTouchUpInside];
        _operateButton.tag = 1;
        _operateButton.hidden = YES;
        [self setButton:_operateButton fitSize:CGSizeMake(30,0)];
    }
    return _operateButton;
}


- (void)setButton:(UIButton *)btn fitSize:(CGSize)size {
    CGRect previousFrame = btn.frame;
    CGRect newFrame = btn.frame;
    newFrame.size = size;
    CGFloat adjustX = (size.width - previousFrame.size.width)/2;
    CGFloat adjustY = (size.height - previousFrame.size.height)/2;
    newFrame.origin.x = previousFrame.origin.x - adjustX;
    newFrame.origin.y = previousFrame.origin.y - adjustY;
    btn.frame = newFrame;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(adjustY, adjustX, adjustY, adjustX);
    btn.contentEdgeInsets = edgeInsets;
}
  
@end
