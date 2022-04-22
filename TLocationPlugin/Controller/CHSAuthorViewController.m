//
//  CHSAuthorViewController.m
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/15.
//  Copyright © 2022 TBD. All rights reserved.
//

#import "CHSAuthorViewController.h"
#import "CHSGradientNavigationView.h"
#import "UIColor+CHSLocationPlugin.h"
#import "UIImage+CHSLocationPlugin.h"
#import "HSALocalData+hsa.h"
#import "Masonry.h"
#import "MediatorDefine.h"

#import "CHSFetchLocationDataViewController.h"
#import "CHSLocationHelper.h"
#import "CHSAlertController.h"
#import "UIWindow+CHSLocationPluginToast.h"

@interface CHSAuthorViewController()

@property (nonatomic, strong) CHSGradientNavigationView *gradientNavigationView;

@property (nonatomic, strong) UIImageView *logoImgView;
@property (nonatomic, strong) UILabel *appNameLabel;
@property (nonatomic, strong) UILabel *versionLabel;

@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UIView *switchView;
@property (nonatomic, strong) UILabel *switchLabel;
@property (nonatomic, strong) UILabel *openVirtualLabel;
@property (nonatomic, strong) UISwitch *virtualSwitch;
@property (nonatomic, strong) UILabel *openShakeLabel;
@property (nonatomic, strong) UISwitch *shakeSwitch;

@end

@implementation CHSAuthorViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (BOOL)hsa_isNull:(NSString *)str {
    if (str == nil || str == NULL || [str isKindOfClass:[NSNull class]] || [str length] == 0 || [str isEqualToString: @"(null)"] || [str isEqualToString: @"null"]) {
        return YES;
    }
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
    
    BOOL isUsingHook = CHSLocationHelper.shared.usingHookLocation;
    BOOL isUsingShake = [HSALocalData appShake];
    self.virtualSwitch.on = isUsingHook;
    self.shakeSwitch.on = !isUsingShake;
}

- (void)setUI {
    [self.view addSubview:self.gradientNavigationView];
    [self.view addSubview:self.logoImgView];
    [self.view addSubview:self.appNameLabel];
    [self.view addSubview:self.versionLabel];
    
    [self.view addSubview:self.switchView];
    [self.switchView addSubview:self.switchLabel];
    [self.switchView addSubview:self.openVirtualLabel];
    [self.switchView addSubview:self.virtualSwitch];
    [self.switchView addSubview:self.openShakeLabel];
    [self.switchView addSubview:self.shakeSwitch];
    
    [self.view addSubview:self.authorLabel];
    [self setMas];
}

- (void)setMas {
    CGFloat logoImgViewTop = 56+StatusBarHeight+NavBarHeight;
    
    [self.logoImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(logoImgViewTop);
        make.width.height.mas_equalTo(62);
    }];
    
    [self.appNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.logoImgView.mas_bottom).offset(21);
    }];
    
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.appNameLabel.mas_bottom).offset(12);
    }];

    [self.authorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-(32+BottomDangerAreaHeight));
    }];
    
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(SCREENWIDTH - 32, 136)));
        make.bottom.equalTo(self.authorLabel.mas_top).offset(-32);
    }];
    
    [self.switchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.switchView);
        make.top.equalTo(self.switchView.mas_top).offset(16);
    }];
    
    [self.openVirtualLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchView.mas_left).offset(16);
        make.top.equalTo(self.switchLabel.mas_bottom).offset(16);
    }];
    
    [self.virtualSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.openVirtualLabel);
        make.right.equalTo(self.switchView.mas_right).offset(-16);
    }];
    
    [self.openShakeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.switchView.mas_left).offset(16);
        make.top.equalTo(self.openVirtualLabel.mas_bottom).offset(24);
    }];
    
    [self.shakeSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.openShakeLabel);
        make.right.equalTo(self.switchView.mas_right).offset(-16);
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true];
    self.navigationController.navigationBarHidden = true;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)toSwitch:(UISwitch *)sender {
    if (sender.tag == 0) {
        CHSLocationHelper.shared.usingHookLocation = sender.isOn;
        [UIWindow t_showTostForMessage:sender.isOn ? @"已开启位置拦截" : @"已关闭位置拦截"];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [HSALocalData saveAppShake:!sender.isOn];
            [UIWindow t_showTostForMessage:sender.isOn ? @"插件的打开方式为摇一摇" : @"插件的打开方式为点一点"];
        });
    }
}

- (void)toExcute:(UIButton *)sender {
    CHSAlertController *alert = [CHSAlertController destructiveAlertWithTitle:@"确定清空保存的位置列表数据?" message:nil cancelTitle:@"取消" cancelBlock:nil destructiveTitle:@"确定" destructiveBlock:^(CHSAlertController * _Nonnull alert, UIAlertAction * _Nonnull action) {
        CHSLocationHelper.shared.cacheDataArray = nil;
        [CHSLocationHelper.shared saveCacheDataArray];
        [UIWindow t_showTostForMessage:@"已清空保存的位置列表数据"];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (CHSGradientNavigationView *)gradientNavigationView
{
    if (!_gradientNavigationView) {
        CHSGradientNavigationModel *model = [[CHSGradientNavigationModel alloc] init];
        model.title = @"关于我们";
        model.titleColor = [UIColor color_OCHexStr:@"#303133"];
        model.leftImage = @"back";
        model.rightImage = @"";
        model.startGradientColor = [UIColor whiteColor];
        model.endGradientColor = [UIColor whiteColor];
        _gradientNavigationView = [[CHSGradientNavigationView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, StatusBarHeight+NavBarHeight)];
        _gradientNavigationView.model = model;
        __weak __typeof(self) weakSelf = self;
        _gradientNavigationView.clickBlock = ^(NSInteger index) {
            if (index == 0) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            }
        };
    }
    return _gradientNavigationView;
}

- (UIImageView *)logoImgView {
    if (!_logoImgView) {
        _logoImgView = [UIImageView new];
        _logoImgView.image = [UIImage t_imageNamed:@"logo"];
        _logoImgView.layer.cornerRadius = 6.0;
        _logoImgView.layer.masksToBounds = YES;
    }
    return _logoImgView;
}

- (UILabel *)appNameLabel {
    if (!_appNameLabel) {
        _appNameLabel = [UILabel new];
        _appNameLabel.font = [UIFont boldSystemFontOfSize:20];
        _appNameLabel.textColor = [UIColor color_OCHexStr:@"#303133"];;
        _appNameLabel.textAlignment = NSTextAlignmentCenter;
        _appNameLabel.text = @"微信_随意调整位置版";
    }
    return _appNameLabel;
}

- (UILabel *)versionLabel {
    if (!_versionLabel) {
        _versionLabel = [[UILabel alloc] init];
        _versionLabel.font = [UIFont systemFontOfSize:16];
        _versionLabel.textColor = [UIColor color_OCHexStr:@"#606266"];
        _versionLabel.textAlignment = NSTextAlignmentLeft;
        _versionLabel.numberOfLines = 1;
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        _versionLabel.text = [NSString stringWithFormat:@"版本号：%@",version];
    }
    return _versionLabel;
}

- (UIView *)switchView {
    if (!_switchView) {
        _switchView = [UIView new];
        _switchView.layer.cornerRadius = 6.0;
        _switchView.layer.masksToBounds = YES;
        _switchView.layer.borderColor = [[UIColor color_OCHexStr:@"303133"] CGColor];
        _switchView.layer.borderWidth = 0.5;
    }
    return _switchView;
}

- (UILabel *)switchLabel {
    if (!_switchLabel) {
        _switchLabel = [UILabel new];
        _switchLabel.font = [UIFont boldSystemFontOfSize:18];
        _switchLabel.textColor = [UIColor color_OCHexStr:@"#303133"];;
        _switchLabel.textAlignment = NSTextAlignmentCenter;
        _switchLabel.text = @"开关设置";
    }
    return _switchLabel;
}

- (UILabel *)openVirtualLabel {
    if (!_openVirtualLabel) {
        _openVirtualLabel = [UILabel new];
        _openVirtualLabel.font = [UIFont boldSystemFontOfSize:16];
        _openVirtualLabel.textColor = [UIColor color_OCHexStr:@"#303133"];;
        _openVirtualLabel.textAlignment = NSTextAlignmentCenter;
        _openVirtualLabel.text = @"启用位置拦截";
    }
    return _openVirtualLabel;
}

- (UISwitch *)virtualSwitch {
    if (!_virtualSwitch) {
        _virtualSwitch = [UISwitch new];
        _virtualSwitch.onTintColor = [UIColor color_OCHexStr:@"3B71E8"];
        _virtualSwitch.tag = 0;
        [_virtualSwitch addTarget:self action:@selector(toSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return _virtualSwitch;
}

- (UILabel *)openShakeLabel {
    if (!_openShakeLabel) {
        _openShakeLabel = [UILabel new];
        _openShakeLabel.font = [UIFont boldSystemFontOfSize:16];
        _openShakeLabel.textColor = [UIColor color_OCHexStr:@"#303133"];;
        _openShakeLabel.textAlignment = NSTextAlignmentCenter;
        NSString *str = @"插件打开方式（点一点 Or 摇一摇【默认】）";
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2.0;
        NSDictionary *dic = @{NSParagraphStyleAttributeName:paragraphStyle, NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str attributes:dic];
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor color_OCHexStr:@"#606266"]};
        [attributeStr addAttributes:attributes range:NSMakeRange(6,str.length-6)];
        _openShakeLabel.attributedText = attributeStr;
    }
    return _openShakeLabel;
}

- (UISwitch *)shakeSwitch {
    if (!_shakeSwitch) {
        _shakeSwitch = [UISwitch new];
        _shakeSwitch.onTintColor = [UIColor color_OCHexStr:@"3B71E8"];
        _shakeSwitch.tag = 2;
        [_shakeSwitch addTarget:self action:@selector(toSwitch:) forControlEvents:UIControlEventValueChanged];
    }
    return _shakeSwitch;
}

- (UILabel *)authorLabel {
    if (!_authorLabel) {
        _authorLabel = [[UILabel alloc] init];
        _authorLabel.font = [UIFont systemFontOfSize:16];
        _authorLabel.textColor = [UIColor color_OCHexStr:@"#303133"];
        _authorLabel.textAlignment = NSTextAlignmentLeft;
        _authorLabel.numberOfLines = 1;
        NSString *str = @"Power by 许久_";
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 2.0;
        NSDictionary *dic = @{NSParagraphStyleAttributeName:paragraphStyle, NSUnderlineStyleAttributeName: @(NSUnderlineStyleNone)};
        NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:str attributes:dic];
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:24], NSForegroundColorAttributeName: [UIColor color_OCHexStr:@"#3B71E8"]};
        [attributeStr addAttributes:attributes range:NSMakeRange(str.length-3,3)];
        _authorLabel.attributedText = attributeStr;
    }
    return _authorLabel;
}

@end
