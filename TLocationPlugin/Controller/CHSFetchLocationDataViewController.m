//
//  CHSFetchLocationDataViewController.m
//  CHSLocationPlugin
//
//  Created by stone on 2019/9/4.
//  
//

#import "CHSFetchLocationDataViewController.h"
#import "CHSAddLocationDataViewController.h"
#import "CHSLocationNavigationController.h"
#import "CHSFetchLocationTableViewCell.h"
#import "UIWindow+CHSLocationPluginToast.h"
#import "UITableView+CHSLocationPlugin.h"
#import "CHSGradientNavigationView.h"
#import "UIImage+CHSLocationPlugin.h"
#import "UIColor+CHSLocationPlugin.h"
#import "CHSAuthorViewController.h"
#import "CHSNavigationView.h"
#import "CHSBlankView.h"
#import "CHSLocationHelper.h"
#import "CHSAlertController.h"
#import "CHSLabelHelper.h"
#import "Masonry.h"
#import "MediatorDefine.h"

@interface CHSFetchLocationDataViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CHSNavigationView *gradientNavigationView;

@property (nonatomic, strong) CHSGradientNavigationView *editNavigationView;

@property (nonatomic, strong) CHSBlankView *blankView;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIButton *excuteButton;

@property (nonatomic, assign) BOOL hasChangedLocationData;

@property (nonatomic, copy) NSArray<CHSLocationModel *> *tableViewData;

@property (nonatomic, assign) NSUInteger  lastSavedCacheDataArrayHash;

@property (nonatomic, readonly, nullable) NSIndexPath *currentSelectIndex;

@property (nonatomic, strong) CHSLocationModel *selectedModel;

@end

@implementation CHSFetchLocationDataViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
    self.lastSavedCacheDataArrayHash = CHSLocationHelper.shared.cacheDataArrayHash;
}

- (void)setUI {
    [self.view addSubview:self.gradientNavigationView];
    [self.view addSubview:self.editNavigationView];
    [self.view addSubview:self.blankView];
    [self.view addSubview:self.excuteButton];
    [self.view addSubview:self.tableView];
    [self setMas];
}

- (void)setMas {
    [self.excuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(SCREENWIDTH - 32, 44)));
        make.bottom.equalTo(self.view.mas_bottom).offset(-BottomDangerAreaHeight);
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(StatusBarHeight+NavBarHeight);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.excuteButton.mas_top).offset(-16);
    }];
    [self.blankView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.equalTo(@(SCREENWIDTH));
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true];
    self.navigationController.navigationBarHidden = true;
    [self refreshTableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self storageCacheDataArray];
}

- (NSArray<CHSLocationModel *> *)tableViewData {
    return CHSLocationHelper.shared.cacheDataArray;
}

- (void)setTableViewData:(NSArray<CHSLocationModel *> *)tableViewData {
    CHSLocationHelper.shared.cacheDataArray = tableViewData;
}

- (NSIndexPath *)currentSelectIndex {
    __block NSIndexPath *index = nil;
    [self.tableViewData enumerateObjectsUsingBlock:^(CHSLocationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.isSelect) {
            index = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    return index;
}

- (void)refreshTableView {
    [self.tableView reloadData];
    if (CHSLocationHelper.shared.cacheDataArray.count == 0) {
        self.excuteButton.hidden = YES;
        self.tableView.hidden = YES;
        self.blankView.hidden = NO;
    } else {
        self.excuteButton.hidden = NO;
        self.tableView.hidden = NO;
        self.blankView.hidden = YES;
        if (self.currentSelectIndex) {
            [self.tableView selectRowAtIndexPath:self.currentSelectIndex
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionNone];
        }
    }
}

- (void)excuteCloseLogic {
    [self.view endEditing:YES];
    [self storageCacheDataArray];
    
    /// 修改了数据但是没有启用
    if (self.hasChangedLocationData && !CHSLocationHelper.shared.usingHookLocation) {
        CHSAlertController *alert = [CHSAlertController confirmAlertWithTitle:@"是否启用位置拦截?" message:nil cancelTitle:@"否" cancelBlock:^(CHSAlertController * _Nonnull alert, UIAlertAction * _Nonnull action) {
            [self dismissSelf];
        } confirmTitle:@"是" confirmBlock:^(CHSAlertController * _Nonnull alert, UIAlertAction * _Nonnull action) {
            CHSLocationHelper.shared.usingHookLocation = YES;
            [self dismissSelf];
        }];
        [alert reverseActions];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }

    [self dismissSelf];
}

- (void)editTableView {
    if (self.tableView.isEditing || self.tableView.isEditBegining) {
        return;
    }
    [self.tableView setEditing:YES animated:YES];
    self.gradientNavigationView.hidden = YES;
    self.editNavigationView.hidden = NO;
}

- (void)removeTableViewCell {
    if (self.tableView.indexPathsForSelectedRows.count == 0) {
        return;
    }
    NSMutableArray<CHSLocationModel *> *tableViewDataArray = [self.tableViewData mutableCopy];
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [indexSet addIndex:obj.row];
    }];
    [tableViewDataArray removeObjectsAtIndexes:indexSet];
    self.tableViewData = tableViewDataArray;
    [self storageCacheDataArray];
    [self.tableView deleteRowsAtIndexPaths:self.tableView.indexPathsForSelectedRows
                          withRowAnimation:UITableViewRowAnimationLeft];
    if (tableViewDataArray.count == 0) {
        self.excuteButton.hidden = YES;
        self.tableView.hidden = YES;
        self.blankView.hidden = NO;
    } else {
        self.excuteButton.hidden = NO;
        self.tableView.hidden = NO;
        self.blankView.hidden = YES;
    }
}

- (void)doneEditTableView {
    if (!self.tableView.isEditing || self.tableView.isEditEnding) {
        return;
    }
    [self.tableView setEditing:NO animated:YES];
    self.gradientNavigationView.hidden = NO;
    self.editNavigationView.hidden = YES;
}

- (void)storageCacheDataArray {
    if (self.lastSavedCacheDataArrayHash == CHSLocationHelper.shared.cacheDataArrayHash) {
        return;
    }
    [CHSLocationHelper.shared saveCacheDataArray];
    self.lastSavedCacheDataArrayHash = CHSLocationHelper.shared.cacheDataArrayHash;
}

- (void)storageLocation:(CHSLocationModel * _Nonnull)model {
    if (model == nil) {
        return;
    }
    self.hasChangedLocationData = YES;
    CHSLocationHelper.shared.locationName = model.name;
    CHSLocationHelper.shared.latitude = model.latitude;
    CHSLocationHelper.shared.longitude = model.longitude;
}

- (void)dismissSelf {
    [self dismissViewControllerAnimated:YES completion:^{
        CHSLocationNavigationController.isShowing = NO;
    }];
}

- (void)toExcute:(UIButton *)sender {
    [self doneEditTableView];
    CHSAddLocationDataViewController *vc = [[CHSAddLocationDataViewController alloc] init];
    vc.addLocationBlock = ^(CHSLocationModel * _Nonnull model) {
        NSMutableArray<CHSLocationModel *> *newDataArray = [self.tableViewData mutableCopy];
        if (newDataArray == nil) {
            newDataArray = [NSMutableArray<CHSLocationModel *> array];
        }
        [newDataArray insertObject:model atIndex:0];
        self.tableViewData = newDataArray;
        [self storageCacheDataArray];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHSLocationModel *model = self.tableViewData[indexPath.row];
    CGFloat titleHeight = [CHSLabelHelper hsa_caluHeightOfString:model.name withWidth:SCREENWIDTH-80 withFont:[UIFont systemFontOfSize:16]];
    return titleHeight+48+36;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CHSFetchLocationTableViewCell *viewCell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CHSFetchLocationTableViewCell class]) forIndexPath:indexPath];
    viewCell.tableView = tableView;
    CHSLocationModel *model = self.tableViewData[indexPath.row];
    if (model.isSelect) {
        self.selectedModel = self.tableViewData[indexPath.row];
    }
    model.hidden = (indexPath.row == self.tableViewData.count - 1);
    viewCell.model = model;
    return viewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing) {
        return;
    }
    NSMutableArray<NSIndexPath *> *reloadIndexPaths = [NSMutableArray<NSIndexPath *> array];
    [reloadIndexPaths addObject:indexPath];
    NSUInteger oldIndex = [self.tableViewData indexOfObject:self.selectedModel];
    if (oldIndex != NSNotFound) {
        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:oldIndex inSection:0];
        [reloadIndexPaths addObject:oldIndexPath];
    }
    self.selectedModel.isSelect = NO;
    self.selectedModel = self.tableViewData[indexPath.row];
    self.selectedModel.isSelect = YES;
    [self.tableView reloadRowsAtIndexPaths:reloadIndexPaths
                          withRowAnimation:UITableViewRowAnimationNone];
    [self storageLocation:self.selectedModel];
    [self storageCacheDataArray];
    
    NSString *toastText = [NSString stringWithFormat:@"已保存为: %@\n%@", self.selectedModel.name, self.selectedModel.locationText];
    [UIWindow t_showTostForMessage:toastText];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    if (sourceIndexPath.row == destinationIndexPath.row) {
        return;
    }
    NSMutableArray<CHSLocationModel *> *tableViewDataArray = [self.tableViewData mutableCopy];
    CHSLocationModel *model = [tableViewDataArray objectAtIndex:sourceIndexPath.row];
    [tableViewDataArray removeObjectAtIndex:sourceIndexPath.row];
    [tableViewDataArray insertObject:model atIndex:destinationIndexPath.row];
    self.tableViewData = tableViewDataArray;
    [self storageCacheDataArray];
}


- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleleteBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self removeTableViewDataInIndexPath:indexPath];
    }];

    UITableViewRowAction *editBtn = [UITableViewRowAction  rowActionWithStyle:UITableViewRowActionStyleNormal title:@"编辑" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self editTableViewDataInIndexPath:indexPath];
    }];

    UITableViewRowAction *topBtn = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"置顶" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self topTableViewDataInIndexPath:indexPath];
    }];
    deleleteBtn.backgroundColor = UIColor.redColor;
    editBtn.backgroundColor = [UIColor color_OCHexStr:@"#cecece"];
    topBtn.backgroundColor = [UIColor color_OCHexStr:@"3B71E8"];
    return @[deleleteBtn, editBtn, topBtn];
}


#pragma mark - 辅助函数
- (void)topTableViewDataInIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *firstIndexPath = [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
    [self.tableView moveRowAtIndexPath:indexPath toIndexPath:firstIndexPath];
    NSMutableArray<CHSLocationModel *> *tableViewDataArray = [self.tableViewData mutableCopy];
    CHSLocationModel *model = [tableViewDataArray objectAtIndex:indexPath.row];
    [tableViewDataArray removeObjectAtIndex:indexPath.row];
    [tableViewDataArray insertObject:model atIndex:0];
    self.tableViewData = tableViewDataArray;
    [self storageCacheDataArray];
}

- (void)removeTableViewDataInIndexPath:(NSIndexPath *)indexPath {
    CHSLocationModel *model = self.tableViewData[indexPath.row];
    CHSAlertController *alert = [CHSAlertController destructiveAlertWithTitle:@"确定删除数据?" message:model.name cancelTitle:@"取消" cancelBlock:nil destructiveTitle:@"确定" destructiveBlock:^(CHSAlertController * _Nonnull alert, UIAlertAction * _Nonnull action) {
        
        NSMutableArray<CHSLocationModel *> *tableViewDataArray = [self.tableViewData mutableCopy];
        [tableViewDataArray removeObjectAtIndex:indexPath.row];
        self.tableViewData = tableViewDataArray;
        if (tableViewDataArray.count == 0) {
            self.excuteButton.hidden = YES;
            self.tableView.hidden = YES;
            self.blankView.hidden = NO;
        } else {
            self.excuteButton.hidden = NO;
            self.tableView.hidden = NO;
            self.blankView.hidden = YES;
        }
        [self storageCacheDataArray];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationLeft];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)editTableViewDataInIndexPath:(NSIndexPath *)indexPath {
    if (indexPath == nil) {
        return;
    }
    CHSLocationModel *model = self.tableViewData[indexPath.row];
    CHSAlertController *alert = [CHSAlertController editAlertWithTitle:@"修改数据" message:model.name labelTexts:@[@"名称", @"纬度", @"经度"] defaultValues:@[ model.name ?: @"", @(model.latitude).stringValue, @(model.longitude).stringValue] cancelTitle:@"取消" cancelBlock:nil confirmTitle:@"确定" confirmBlock:^(CHSAlertController * _Nonnull alert, UIAlertAction * _Nonnull action) {
        
        model.name = alert.textFields[0].text;
        model.latitude = alert.textFields[1].text.doubleValue;
        model.longitude = alert.textFields[2].text.doubleValue;
        if (model.isSelect) {
            [self storageLocation:model];
        }
        [self storageCacheDataArray];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.hidden = YES;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.allowsMultipleSelectionDuringEditing = YES;
        [_tableView registerClass:[CHSFetchLocationTableViewCell class] forCellReuseIdentifier:NSStringFromClass([CHSFetchLocationTableViewCell class])];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
    }
    return _tableView;
}

- (UIButton *)excuteButton {
    if(_excuteButton == nil) {
        _excuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_excuteButton setTitle:@"添加位置" forState:UIControlStateNormal];
        _excuteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _excuteButton.tag = 1;
        _excuteButton.hidden = YES;
        _excuteButton.layer.cornerRadius = 22.0;
        _excuteButton.layer.masksToBounds = YES;
        _excuteButton.backgroundColor = [UIColor color_OCHexStr:@"#3B71E8"];
        [_excuteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_excuteButton addTarget:self action:@selector(toExcute:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _excuteButton;
}

- (CHSNavigationView *)gradientNavigationView
{
    if (!_gradientNavigationView) {
        CHSGradientNavigationModel *model = [[CHSGradientNavigationModel alloc] init];
        model.title = @"选择位置";
        model.titleColor = [UIColor color_OCHexStr:@"#303133"];
        model.leftImage = @"close";
        model.excuteImage = @"info";
        model.rightImage = @"edit";
        model.startGradientColor = [UIColor whiteColor];
        model.endGradientColor = [UIColor whiteColor];
        _gradientNavigationView = [[CHSNavigationView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, StatusBarHeight+NavBarHeight)];
        _gradientNavigationView.model = model;
        __weak __typeof(self) weakSelf = self;
        _gradientNavigationView.clickBlock = ^(NSInteger index) {
            if (index == 0) {
                [weakSelf excuteCloseLogic];
            } else if (index == 1) {
                [weakSelf editTableView];
            } else {
                CHSAuthorViewController *vc = [[CHSAuthorViewController alloc] init];
                [weakSelf.navigationController pushViewController:vc animated:YES];
            }
        };
    }
    return _gradientNavigationView;
}

- (CHSGradientNavigationView *)editNavigationView
{
    if (!_editNavigationView) {
        CHSGradientNavigationModel *model = [[CHSGradientNavigationModel alloc] init];
        model.title = @"选择位置";
        model.titleColor = [UIColor color_OCHexStr:@"#303133"];
        model.leftImage = @"delete";
        model.rightImage = @"done";
        model.startGradientColor = [UIColor whiteColor];
        model.endGradientColor = [UIColor whiteColor];
        _editNavigationView = [[CHSGradientNavigationView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, StatusBarHeight+NavBarHeight)];
        _editNavigationView.model = model;
        _editNavigationView.hidden = YES;
        __weak __typeof(self) weakSelf = self;
        _editNavigationView.clickBlock = ^(NSInteger index) {
            if (index == 0) {
                [weakSelf removeTableViewCell];
            } else {
                [weakSelf doneEditTableView];
            }
        };
    }
    return _editNavigationView;
}

- (CHSBlankView *)blankView
{
    if (!_blankView) {
        _blankView = [[CHSBlankView alloc] init];
        _blankView.hidden = YES;
        __weak __typeof(self) weakSelf = self;
        [_blankView setHandle:^{
            [weakSelf doneEditTableView];
            CHSAddLocationDataViewController *vc = [[CHSAddLocationDataViewController alloc] init];
            vc.addLocationBlock = ^(CHSLocationModel * _Nonnull model) {
                NSMutableArray<CHSLocationModel *> *newDataArray = [weakSelf.tableViewData mutableCopy];
                if (newDataArray == nil) {
                    newDataArray = [NSMutableArray<CHSLocationModel *> array];
                }
                [newDataArray insertObject:model atIndex:0];
                weakSelf.tableViewData = newDataArray;
                [weakSelf storageCacheDataArray];
            };
            [weakSelf.navigationController pushViewController:vc animated:YES];
        }];
    }
    return _blankView;
}

@end
