//
//  WYDebugTouchSettingViewController.m
//  Pods
//
//  Created by Hongzhi Zhao on 2017/5/15.
//
//

#import "Masonry.h"
#import "WYDebugTouch.h"
#import "XFAssistiveTouch.h"
#import "HSADebugTouchTemp.h"
#import "WYDebugTouchModuleModel.h"
#import "WYDebugTouchNavigationController.h"
#import "WYDebugTouchSettingViewController.h"

typedef NS_ENUM(NSUInteger, WYDebugTouchSettingSection) {
    WYDebugTouchSettingSectionSetting,
    WYDebugTouchSettingSectionClean,
};

typedef NS_ENUM(NSUInteger, WYDebugTouchSwitchButtonTag) {
    WYDebugTouchSwitchButtonTagDebugTouchOnOff,
    WYDebugTouchSwitchButtonTagIsDefaultEnable,
};

typedef NS_ENUM(NSUInteger, WYDebugTouchFunction) {
    WYDebugTouchFunctionCleanUserDeafultsKeychain = 0,
    WYDebugTouchFunctionCleanDocumentCache,
    WYDebugTouchFunctionCleanALL,
    WYDebugTouchFunctionEvalJS,
    WYDebugTouchFunctionH5Jump,
    WYDebugTouchFunctionLast,
};


@interface WYDebugTouchSettingViewController ()<UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *modelArray;
@property (nonatomic, strong) NSArray *functionArray;

@property (nonatomic, copy) NSString *inputJS;

@end

@implementation WYDebugTouchSettingViewController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getDataSource];
    [self setupUI];
    // Do any additional setup after loading the view.
}

- (void)getDataSource {
    _modelArray = [WYDebugTouch registerModuleArray];
}

#pragma mark - UITableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger sectionNumber = 0;
    switch (section) {
        case WYDebugTouchSettingSectionSetting:{
            sectionNumber = 2;
            break;
        }
        case WYDebugTouchSettingSectionClean:{
            sectionNumber =  WYDebugTouchFunctionLast;
            break;
        }
        default:
            break;
    }
    return sectionNumber;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] init];
    switch (section) {
        case WYDebugTouchSettingSectionSetting:
            label.text = @"  WYDebugTouch选项";
            break;
        case WYDebugTouchSettingSectionClean:
            label.text = @"  清除缓存";
            break;
        default:
            break;
    }
    
    return label;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"CellIdentifier"];
    }    switch (indexPath.section) {
        case WYDebugTouchSettingSectionSetting: {
            switch (indexPath.row) {
                case WYDebugTouchSwitchButtonTagDebugTouchOnOff: {
                    UISwitch *switchBtn = [[UISwitch alloc] init];
                    [switchBtn addTarget:self action:@selector(switchBtnClick:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = @"Touch开关设置";
                    cell.accessoryView = switchBtn;
                    switchBtn.tag = WYDebugTouchSwitchButtonTagDebugTouchOnOff;
                    [switchBtn setOn:![(WYDebugTouchNavigationController *)[[XFAssistiveTouch sharedInstance] navigationController] windowIsHidden] animated:false];
                }
                    break;
                case WYDebugTouchSwitchButtonTagIsDefaultEnable:{
                    UISwitch *switchBtn = [[UISwitch alloc] init];
                    [switchBtn addTarget:self action:@selector(debugTouchSwitchChange:) forControlEvents:UIControlEventTouchUpInside];
                    cell.textLabel.text = @"Debug Touch 自动启动";
                    cell.accessoryView = switchBtn;
                    switchBtn.tag = WYDebugTouchSwitchButtonTagIsDefaultEnable;
                    NSString *result = [[WYKeychain keychain] stringForKey:kWYDebugTouchIsDefaultEnableFlag];
                    [switchBtn setOn: [result isEqualToString:@"是"] animated:false];
                }
                    
                    break;
                default:
                    break;
            }
            break;
        }
        case WYDebugTouchSettingSectionClean: {
            switch (indexPath.row) {
                case WYDebugTouchFunctionCleanUserDeafultsKeychain:
                    cell.textLabel.text = @"清除标识类缓存（UserDefaults&Keychians）";
                    break;
                case WYDebugTouchFunctionCleanDocumentCache:
                    cell.textLabel.text = @"清除文件缓存（Localh5/Caches）";
                    break;
                case WYDebugTouchFunctionCleanALL:
                    cell.textLabel.text = @"清除全部内容";
                    break;
                case WYDebugTouchFunctionEvalJS:
                    cell.textLabel.text = @"调用JS函数";
                    break;
                case WYDebugTouchFunctionH5Jump:
                    cell.textLabel.text = @"H5跳转";
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.section == WYDebugTouchSettingSectionClean) {
        switch (indexPath.row) {
            case WYDebugTouchFunctionCleanUserDeafultsKeychain:
                [self clearUserDeafultsAndKeychian];
                break;
            case WYDebugTouchFunctionCleanDocumentCache:
                [self clearDisk:true];
                break;
            case WYDebugTouchFunctionCleanALL:
                [self clearUserDeafultsAndKeychian];
                [self clearDisk:false];
                break;
            case WYDebugTouchFunctionEvalJS: {
            }
                break;
            case WYDebugTouchFunctionH5Jump: {
                UIAlertView *al = [[UIAlertView alloc] initWithTitle:@"H5跳转" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
                al.alertViewStyle = UIAlertViewStylePlainTextInput;
                [[al textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeDefault];
                [al show];
                break;
            }
                break;
            default:
                break;
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
//    if (buttonIndex == 1) {
//        [Mediator routeURL:URL([alertView textFieldAtIndex:0].text)];
//    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.inputJS = textField.text;
}

#pragma mark - Switch Btn selector
- (void)switchBtnClick:(UISwitch *)switchBtn {
    if (switchBtn.tag == WYDebugTouchSwitchButtonTagDebugTouchOnOff) {
        [WYDebugTouch setIsEnable:switchBtn.isOn];
    }
}

- (void)debugTouchSwitchChange:(UISwitch *)switchBtn {
    if (switchBtn.tag == WYDebugTouchSwitchButtonTagIsDefaultEnable) {
        NSString *result = switchBtn.isOn?@"是":@"否";
        [[WYKeychain keychain] saveString:result forKey:kWYDebugTouchIsDefaultEnableFlag];
    }
}

#pragma mark - UI

- (void)setupUI {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"DebugTouch设置界面";
    self.tableView = ({
        UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH , SCREENHEIGHT) style:UITableViewStyleGrouped];
        tableView.tableHeaderView = nil;
        tableView.tableFooterView = nil;
        tableView.delegate = self;
        tableView.dataSource = self;
        [self.view addSubview:tableView];
        tableView;
    });
}

#pragma mark - Clear
- (void)clearDisk:(BOOL)animated {
//    [WYProgressHUD showWithStatus:@"清除中……"];
//    NSArray *dirArray = [self clearDirArray];
//    [WYProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        NSMutableArray *errorArray = [[NSMutableArray alloc] init];
//        for (NSString *path in dirArray) {
//            if ([WYFileManager isDirectoryItemAtPath:path]) {
//                NSError *error = nil;
//                [WYFileManager removeItemsInDirectoryAtPath:path error:&error];
//                if (error) {
//                    BOOL isCocoaErrorDomain = [error.domain isEqualToString:@"NSCocoaErrorDomain"];
//                    BOOL isFileWriteErrorCode = (error.code == NSFileWriteNoPermissionError
//                                                 || error.code == NSFileWriteUnknownError);
//                    if (!(isCocoaErrorDomain && isFileWriteErrorCode)) {
//                        [errorArray addObject:error];
//                    }
//                }
//            }
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([errorArray count] > 0) {
//                [self.view wy_makeToast:@"清除过程中遇到错误,请稍后再试!" duration:1 position:WYToastPositionCenter];
//            }else {
//                if (animated) {
//                    [self.view wy_makeToast:@"清除成功，可能会影响某些功能的正常运行，最好重新启动下App" duration:1 position:WYToastPositionCenter];
//                }
//            }
//            [WYProgressHUD dismiss];
//            [WYProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
//            [[NSUserDefaults standardUserDefaults] setValue:WYAPPSHORTVERSION forKeyPath:@"kWYUserCleanLocalCacheTag"];
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"kWYUserClearLocalCacheSuccessNotification" object:nil];
//        });
//    });
}

- (NSArray *)clearDirArray {
//    NSString *cacheDir = [NSFileManager wy_cachesPath];
//    NSString *tmpDir = NSTemporaryDirectory();
//    if (DEBUG) {
//        NSString *localH5 = [[NSFileManager wy_documentsPath] stringByAppendingPathComponent:@"local_h5"];
//        return @[tmpDir,cacheDir,localH5];
//    }
//    return @[tmpDir,cacheDir];
    return nil;
}

- (void)clearUserDeafultsAndKeychian {
    NSString*appDomain = [[NSBundle mainBundle]bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
    [[WYKeychain keychain] clearAll];
    [[WYKeychain sharedKeychain] clearAll];
}

@end
