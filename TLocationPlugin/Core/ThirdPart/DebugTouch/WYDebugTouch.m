//
//  WYDebugTouch.m
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/8.
//
//

#import <AudioToolbox/AudioToolbox.h>

#import "YYKit.h"
#import "Mediator.h"
#import "WYDebugTouch.h"
#import "CHSLocationHelper.h"
#import "XFAssistiveTouch.h"
#import "HSADebugTouchTemp.h"
#import "HSALocalData+hsa.h"
#import "WYDebugTouchItemView.h"
#import "XFATRootViewController.h"
#import "WYDebugTouchModuleModel.h"
#import "UIImage+CHSLocationPlugin.h"
#import "WYDebugTouchNavigationController.h"
#import "CHSFetchLocationDataViewController.h"
#import "CHSLocationNavigationController.h"
#import "UIWindow+CHSLocationPluginTouch.h"
#import "UIApplication+CHSLocationPlugin.h"

@interface UIApplication (WYDebugTouch)

+ (void)wydt_hookSendEvent;

@end

@interface WYDebugTouch ()<XFXFAssistiveTouchDelegate,XFATRootViewControllerDelegate> {
}

@property (nonatomic, strong) NSMutableArray *moduleArray;
@property (nonatomic) BOOL isEnable;
@property (nonatomic) BOOL isShakeWillShowAlert;

@end

@implementation WYDebugTouch

#pragma mark - Life Cycle

+ (instancetype)sharedInstance {
    static WYDebugTouch *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        [UIApplication wydt_hookSendEvent];
    });
    return instance;
}

- (instancetype)init{
    if (self = [super init]) {
        self.moduleArray = [[NSMutableArray alloc] init];
        self.isEnable = false;
        self.isShakeWillShowAlert = true;
    }
    return self;
}

+ (void)registerTopModule {
    void (^settingBlock)(NSString *moduleName, BOOL *isHightLight) = ^(NSString *moduleName, BOOL *isHightLight) {
        [PageManager.sharedInstance presentViewController:@"CHSFetchLocationDataViewController" withParam:nil inNavigationController:YES animated:YES];
    };    
    NSDictionary *settingParams = @{@"defaultTitleName":@"调整位置",@"defaultImageName":@"plugin",@"moduleType":@(99)};
    [self registerModuleWithName:@"调整位置" params:settingParams handleBlock:settingBlock];
}

+ (void)setup{
    [self setupWithAutoIndent:YES];
}

+ (void)setupWithAutoIndent:(BOOL)autoIndent {
    [[self sharedInstance] setIsShakeWillShowAlert:false];
    // 更换对象
    XFAssistiveTouch *assistiveTouch = [XFAssistiveTouch sharedInstance];
    XFATRootViewController *rootViewController = [XFATRootViewController new];
    WYDebugTouchNavigationController *nav = [[WYDebugTouchNavigationController alloc] initWithRootViewController:rootViewController];
    nav.autoIndent = autoIndent;
    [rootViewController wy_performSelectorWithArgs:@selector(setDelegate:),[XFAssistiveTouch sharedInstance]];
    [nav wy_performSelectorWithArgs:@selector(setDelegate:),[XFAssistiveTouch sharedInstance]];
    [[XFAssistiveTouch sharedInstance] setNavigationController:nav];
    assistiveTouch.delegate = [self sharedInstance];
    [assistiveTouch showAssistiveTouch];
    [nav indent];
    
    XFATItemView *contentView = [[[XFAssistiveTouch sharedInstance] navigationController] valueForKey:@"contentItem"];
    [contentView.layer removeAllSublayers];
    
    CGFloat margin = 10;
    CGRect imageRect = CGRectMake(margin, margin, contentView.width - 2 * margin, contentView.height - 2 * margin);
    UIImage *image = [UIImage chs_imageNamed:@"debug_logo"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = imageRect;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    contentView.layer.zPosition = 0;
    [contentView addSubview:imageView];
}

+ (BOOL)isEnable {
    return [[WYDebugTouch sharedInstance] isEnable];
}

+ (void)setIsEnable:(BOOL)isEnable {
    [[WYDebugTouch sharedInstance] setIsEnable:isEnable];
    if (isEnable) {
        [self setup];
    }else{
        [[WYDebugTouch sharedInstance] setIsShakeWillShowAlert:false];
        [self dismissTouch];
    }
}

+ (void)showTouch {
    WYDebugTouchNavigationController *nav = (WYDebugTouchNavigationController *)[[XFAssistiveTouch sharedInstance] navigationController];
    [nav showWithAnimation:true];
}

+ (void)dismissTouch {
    WYDebugTouchNavigationController *nav = (WYDebugTouchNavigationController *)[[XFAssistiveTouch sharedInstance] navigationController];
    [nav dismissWithAnimation:true];
}

+ (BOOL)isShakeWillShowAlert {
    return [[WYDebugTouch sharedInstance] isShakeWillShowAlert];
}

+ (NSArray<WYDebugTouchModuleModel *> *)registerModuleArray {
    return [[self sharedInstance] moduleArray];
}

#pragma mark - 
+ (void)registerModuleWithName:(NSString *)moduleName
                    imageName:(NSString *)imageName
                  handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock {
    
    WYDebugTouchModuleModel *model = [[WYDebugTouchModuleModel alloc] init];
    model.moduleName = moduleName;
    model.imageName = imageName;
    model.handleBlock = handleBlock;
    [[self sharedInstance] addToModuleArray:model];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WYDebugTouchRefreshItemNotify" object:nil];
}

+ (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
            highLightImageName:(NSString *)highLightImageName
                   handleBlock:(void (^)(NSString *moduleName, BOOL *isHighLight))handleBlock {
    WYDebugTouchModuleModel *model = [[WYDebugTouchModuleModel alloc] init];
    model.moduleName = moduleName;
    model.imageName = imageName;
    model.highLightImageName = highLightImageName;
    model.handleBlock = handleBlock;
    [[self sharedInstance] addToModuleArray:model];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WYDebugTouchRefreshItemNotify" object:nil];
}

+ (void)registerModuleWithName:(NSString *)moduleName
                     imageName:(NSString *)imageName
            highLightImageName:(NSString *)highLightImageName
                     isOnBlock:(void (^)(NSString *moduleName, BOOL *isOn))isOnBlock
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock {
    WYDebugTouchModuleModel *model = [[WYDebugTouchModuleModel alloc] init];
    model.moduleName = moduleName;
    model.imageName = imageName;
    model.highLightImageName = highLightImageName;
    model.handleBlock = handleBlock;
    model.isOnBlock = isOnBlock;
    [[self sharedInstance] addToModuleArray:model];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WYDebugTouchRefreshItemNotify" object:nil];
}

+ (void)refreshAllModuleState {
    [[[self sharedInstance] moduleArray] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        WYDebugTouchModuleModel *model = (WYDebugTouchModuleModel *)obj;
        if (model.itemView) {
            [model.itemView configWithModel:model];
        }
    }];
}

+ (void)registerModuleWithName:(NSString *)moduleName
                        params:(NSDictionary *)params
                   handleBlock:(void (^)(NSString *moduleName,BOOL *isHighLight))handleBlock {
    WYDebugTouchModuleModel *model = [WYDebugTouchModuleModel modelWithJSON:params];
    model.moduleName = moduleName;
    model.imageName = [params valueForKey:@"defaultImageName"];
    model.defaultTitleName = [params valueForKey:@"defaultTitleName"]?:moduleName;
    model.hightLightTitleName = [params valueForKey:@"hightLightTitleName"];
    model.highLightImageName = [params valueForKey:@"highLightImageName"];
    model.isOn = [[params valueForKey:@"defaultIsOn"] boolValue];
    model.prioprity = [[params valueForKey:@"prioprity"] integerValue]?:100;
    model.handleBlock = handleBlock;
    [[self sharedInstance] addToModuleArray:model];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"WYDebugTouchRefreshItemNotify" object:nil];
}

#pragma mark - XFXFAssistiveTouchDelegate

- (NSInteger)numberOfItemsInViewController:(XFATRootViewController *)viewController {
    if ([self checkViewControllerIsTop:viewController]) {
        return self.moduleArray.count;
    }else {
        return viewController.model.subModules.count;
    }
}

- (XFATItemView *)viewController:(XFATRootViewController *)viewController itemViewAtPosition:(XFATPosition *)position {
    NSArray *displayArray = [self sortArray];
    WYDebugTouchItemView *view = [[WYDebugTouchItemView alloc] init];
    WYDebugTouchModuleModel *model;
    if ([self checkViewControllerIsTop:viewController]) {
        NSInteger index = position.index;
        model  = [displayArray objectAtIndex:index];
    }else {
        model = [[[viewController model] sortedSubModules] objectAtIndex:position.index];
    }
    if (model.isOnBlock) {
        BOOL isOn = false;
        model.isOnBlock(model.moduleName, &isOn);
        model.isOn = isOn;
    }
    [view configWithModel:model];
    return view;
}

- (void)viewController:(XFATRootViewController *)viewController didSelectedAtPosition:(XFATPosition *)position {
    WYDebugTouchModuleModel *model;
    if ([self checkViewControllerIsTop:viewController]) {
        NSArray *displayArray = [self sortArray];
        NSInteger index = position.index;
        model  = [displayArray objectAtIndex:index];
    }else {
        model = [[[viewController model] sortedSubModules] objectAtIndex:position.index];
    }
    
    if (model.moduleType == WYDebugTouchModuleTypeTop
        && model.subModules.count) {
        XFATRootViewController *viewController = [[XFATRootViewController alloc] initWithItems:nil];
        viewController.delegate = self;
        viewController.model = model;
        [[XFAssistiveTouch sharedInstance].navigationController pushViewController:viewController atPisition:position];
        return;
    } else if (model.moduleType == WYDebugTouchModuleTypeTop
              && !model.handleBlock) {
        return;
    }
    [[[XFAssistiveTouch sharedInstance] navigationController] shrink];
    if (model.handleBlock) {
        BOOL isHightLight = model.isOn;
        model.handleBlock(model.moduleName, &isHightLight);
        model.isOn = isHightLight;
        [self wy_touchFeedBack];
        [model.itemView configWithModel:model];
    }
}

- (void)addToModuleArray:(WYDebugTouchModuleModel *)model {
    if (model.moduleType == WYDebugTouchModuleTypeTop) {
        [self.moduleArray addObject:model];
    }else {
        [self.moduleArray enumerateObjectsUsingBlock:^(WYDebugTouchModuleModel  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (model.moduleType == obj.boxType) {
                [obj.subModules addObject:model];
            }
        }];
    }
}

- (BOOL)checkViewControllerIsTop:(XFATViewController *)viewController {
    if (viewController == [[[[XFAssistiveTouch sharedInstance] navigationController] viewControllers] firstObject]) {
        return true;
    }else {
        return false;
    }
}

- (NSArray *)sortArray {
    NSMutableArray *sortArray = [self.moduleArray mutableCopy];
    [sortArray sortUsingComparator:^NSComparisonResult(WYDebugTouchModuleModel * _Nonnull obj1, WYDebugTouchModuleModel *  _Nonnull obj2) {
        if (obj1.prioprity > obj2.prioprity) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
    return sortArray;
}

@end

@implementation UIApplication (WYDebugTouch)

+ (void)wydt_hookSendEvent{
    BOOL appShake = [HSALocalData appShake];
    if (appShake) {
        return;
    }
    [self wy_swizzleInstanceMethod:@selector(sendEvent:) with:@selector(wydt_sendEvent:)];
}

- (void)wydt_sendEvent:(UIEvent *)event{
    // 判断是否为摇一摇事件
    // && 是否摇一摇结束
    if (event.type == UIEventTypeMotion
        && event.subtype == UIEventSubtypeMotionShake
        && [[event valueForKey:@"_shakeState"] integerValue] == 1
        && ![WYDebugTouch isEnable]) {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"请问是否开启调整位置服务？" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [WYDebugTouch setIsEnable:true];
            [WYDebugTouch registerTopModule];
        }]];
        [controller addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}]];
        [[Mediator topmostViewController] presentViewController:controller animated:YES completion:nil];
    }
    [self wydt_sendEvent:event];
}

@end
