//
//  WYDebugTouchModuleModel.m
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/8.
//
//

#import "WYDebugTouchModuleModel.h"

@implementation WYDebugTouchModuleModel

- (instancetype)init {
    if (self = [super init]) {
        self.boxType = WYDebugTouchModuleTypeNoBox;
        self.subModules = [[NSMutableArray alloc] init];
    }
    return self;
}

- (NSString *)defaultTitleName {
    if (!_defaultTitleName) {
        return _moduleName;
    }else {
        return _defaultTitleName;
    }
}

- (NSMutableArray<WYDebugTouchModuleModel *> *)sortedSubModules {
    NSMutableArray *sortArray = [self.subModules mutableCopy];
    [sortArray sortUsingComparator:^NSComparisonResult(WYDebugTouchModuleModel * _Nonnull obj1, WYDebugTouchModuleModel *  _Nonnull obj2) {
        if (obj1.prioprity > obj2.prioprity) {
            return NSOrderedAscending;
        }else{
            return NSOrderedDescending;
        }
    }];
    return sortArray;
}

- (WYDebugTouchModuleType)moduleType {
    if (_moduleType == 0) {
        __block NSUInteger idx = 0;
        NSArray *array = @[@[],//undefine
                           @[@"页面埋点",@"点击埋点",@"删除plist"],//TrackInfo
                           @[@"网络监控",@"环境切换",@"域名映射"],//Net
                           @[],//UI
                           @[@"打开Vconsole",@"WKWebView",@"Weex日志",@"打开H5检查器",@"手动调用JS",@"RN调试菜单",@"JS Bundle配置",@"UIWebView",@"扫一扫"]];//Hybrid
        [array enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx1, BOOL * _Nonnull stop1) {
            if ([obj containsObject:self.defaultTitleName]) {
                idx = idx1;
                *stop1 = true;
            }
        }];
        return idx;
    }else {
        return _moduleType;
    }
}

@end
