//
//  WYDebugTouchModuleModel.h
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/8.
//
//

#import <Foundation/Foundation.h>

#import "XFATPosition.h"
#import "WYDebugTouchItemView.h"
#import "XFATRootViewController.h"

typedef void(^WYDebugTouchHandleBlock)(NSString *moduleName, BOOL *isHighlight);
typedef void(^WYDebugTouchIsOnBlock)(NSString *moduleName, BOOL *isOn);

typedef enum : NSUInteger {
    WYDebugTouchModuleTypeUndefine = 0,
    WYDebugTouchModuleTypeTrackInfo,
    WYDebugTouchModuleTypeNet,
    WYDebugTouchModuleTypeUI,
    WYDebugTouchModuleTypeHybrid,
    
    WYDebugTouchModuleTypeNoBox = 98,
    WYDebugTouchModuleTypeTop = 99,
} WYDebugTouchModuleType;

@interface WYDebugTouchModuleModel : NSObject

@property (nonatomic, strong) NSString *moduleName;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *highLightImageName;
@property (nonatomic, strong) NSString *defaultTitleName;
@property (nonatomic, strong) NSString *hightLightTitleName;
@property (nonatomic, copy) WYDebugTouchHandleBlock handleBlock;
@property (nonatomic, copy) WYDebugTouchIsOnBlock isOnBlock;
@property (nonatomic) BOOL isOn;
@property (nonatomic) NSInteger prioprity;
@property (nonatomic) WYDebugTouchModuleType moduleType;
@property (nonatomic) WYDebugTouchModuleType boxType;

@property (nonatomic, weak) WYDebugTouchItemView *itemView;
@property (nonatomic, strong) NSMutableArray<WYDebugTouchModuleModel *> *subModules;

- (NSMutableArray<WYDebugTouchModuleModel *> *)sortedSubModules;

@end
