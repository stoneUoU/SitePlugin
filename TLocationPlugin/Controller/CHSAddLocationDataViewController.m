//
//  CHSAddLocationDataViewController.m
//  CHSLocationPlugin
//
//  Created by stone on 2022/4/14.
//  Copyright © 2022 TBD. All rights reserved.
//

#import "CHSAddLocationDataViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CHSFetchLocationTableViewCell.h"
#import "CHSAlertController.h"
#import "UIImage+CHSLocationPlugin.h"
#import "UIWindow+CHSLocationPluginToast.h"
#import "UIColor+CHSLocationPlugin.h"
#import "CHSGradientNavigationView.h"
#import "Masonry.h"
#import "MediatorDefine.h"
#import "CHSLabelHelper.h"

typedef void (^GetPlaceInfoBlock)(NSArray<CHSLocationModel *> *_Nullable models);

typedef NS_ENUM(NSUInteger, TMapViewAnnotationType) {
    TMapViewAnnotationTypeFirst,
    TMapViewAnnotationTypeAll,
};

@interface CHSAddLocationDataViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate>

@property (nonatomic, assign) BOOL shouldRefreshUserLocation;

@property (nonatomic, strong) CHSGradientNavigationView *gradientNavigationView;

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UITextField *searchTextField;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *excuteButton;

@property (nonatomic, copy) NSArray<CHSLocationModel *> *tableViewData;
@property (nonatomic, strong) CHSLocationModel *selectedModel;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation CHSAddLocationDataViewController

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setUI];
    [self requestLocationAuthorization];
    self.shouldRefreshUserLocation = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:true];
    self.navigationController.navigationBarHidden = true;
}

- (void)setUI {
    
    [self.view addSubview:self.gradientNavigationView];
    [self.view addSubview:self.mapView];
    [self.view addSubview:self.excuteButton];
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.searchView];
    [self.searchView addSubview:self.searchButton];
    [self.searchView addSubview:self.searchTextField];

    [self setMas];
}

- (void)setMas {
    [self.excuteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(SCREENWIDTH - 32, 44)));
        make.bottom.equalTo(self.view.mas_bottom).offset(-BottomDangerAreaHeight);
    }];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(StatusBarHeight+NavBarHeight);
        make.left.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(SCREENWIDTH, 360)));
    }];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mapView.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.excuteButton.mas_top).offset(-16);
    }];
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mapView.mas_top).offset(16);
        make.centerX.equalTo(self.view);
        make.size.equalTo(@(CGSizeMake(SCREENWIDTH-36, 44)));
    }];
    [self.searchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.equalTo(self.searchView);
        make.size.equalTo(@(CGSizeMake(64, 44)));
    }];
    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self.searchView);
        make.left.equalTo(self.searchView.mas_left).offset(16);
        make.right.equalTo(self.searchButton.mas_left).offset(-16);
    }];
}

- (void)requestLocationAuthorization {
    if (![CLLocationManager locationServicesEnabled]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self refreshViewWithLocation:self.mapView.userLocation.location setMapViewCenter:YES animated:YES annotationType:TMapViewAnnotationTypeFirst];
        });
        return;
    }
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager location];
        return;
    }
    [self.locationManager requestWhenInUseAuthorization];
}

#pragma mark CoreLocation delegate

- (void)touchMapView:(UIGestureRecognizer *)gestureRecognizer {
    if (self.searchTextField.isEditing) {
        [self.searchTextField resignFirstResponder];
        return;
    }
    self.shouldRefreshUserLocation = NO;
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint
                                                      toCoordinateFromView:self.mapView];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude
                                                      longitude:touchMapCoordinate.longitude];
    [self refreshViewWithLocation:location
                 setMapViewCenter:NO
                         animated:YES
                   annotationType:TMapViewAnnotationTypeFirst];
}

- (void)freshUserLocation {
    self.shouldRefreshUserLocation = YES;
    [self refreshViewWithLocation:self.mapView.userLocation.location
                 setMapViewCenter:YES
                         animated:NO
                   annotationType:TMapViewAnnotationTypeFirst];
}

- (void)toExcute:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.view endEditing:YES];
        [self searchMapForText:self.searchTextField.text];
    } else {
        if (self.selectedModel == nil) {
            CHSAlertController *alert = [CHSAlertController singleActionAlertWithTitle:@"请选择一个位置" message:nil actionTitle:@"确定" actionBlock:nil];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
        CHSAlertController *alert = [CHSAlertController editAlertWithTitle:@"请输入标记名称" message:nil labelTexts:nil defaultValues:@[self.selectedModel.name ?: @""] cancelTitle:@"取消" cancelBlock:nil confirmTitle:@"确定" confirmBlock:^(CHSAlertController * _Nonnull alert, UIAlertAction * _Nonnull action) {
            NSString *name = alert.textFields.firstObject.text;
            [self saveSelectedModelWithNewName:name];
        }];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)saveSelectedModelWithNewName:(NSString *)name {
    if (name.length <= 0) {
        CHSAlertController *alertError = [CHSAlertController singleActionAlertWithTitle:@"请输入标记名称" message:nil actionTitle:@"确定" actionBlock:nil];
        [self presentViewController:alertError animated:YES completion:nil];
        return;
    }
    /// 使用 copy 防止添加多次同一个对象出现问题
    CHSLocationModel *model = [self.selectedModel copy];
    model.name = name;
    /// 默认不选择
    model.isSelect = NO;
    if (self.addLocationBlock) {
        self.addLocationBlock(model);
        NSString *toastText = [NSString stringWithFormat:@"添加成功: %@\n%@", model.name, model.locationText];
        [UIWindow t_showTostForMessage:toastText];
    }
}

- (void)setMapViewCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    self.mapView.centerCoordinate = coordinate;
    MKCoordinateSpan span = MKCoordinateSpanMake(0.0015, 0.0015);
    MKCoordinateRegion region = MKCoordinateRegionMake(coordinate, span);
    MKCoordinateRegion fitRegion = [self.mapView regionThatFits:region];
    if (CLLocationCoordinate2DIsValid(fitRegion.center)) {
        [self.mapView setRegion:fitRegion animated:animated];
    } else {
        [self.mapView setRegion:region animated:animated];
    }
}

- (void)updateTableViewForArray:(NSArray<CHSLocationModel *> *)array {
    /// 刷新清空
    self.selectedModel = nil;
    self.tableViewData = array;
    if (self.tableViewData.count > 0) {
        /// 默认选择第一个
        self.selectedModel = self.tableViewData.firstObject;
        self.selectedModel.isSelect = YES;
    }
    [self.tableView reloadData];
}

- (void)refreshAnnotationsForModelArray:(NSArray<CHSLocationModel *> *)modelArray {
    [self.mapView removeAnnotations:self.mapView.annotations];
    for (CHSLocationModel *model in modelArray) {
        CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(model.latitude, model.longitude);
        MKPointAnnotation *annoation = [[MKPointAnnotation alloc] init];
        annoation.coordinate = coordinate;
        annoation.title = model.name;
        [self.mapView addAnnotation:annoation];
    }
}

/// 刷新标记
- (void)refreshViewWithLocation:(CLLocation *)location
               setMapViewCenter:(BOOL)setMapViewCenter
                       animated:(BOOL)animated
                 annotationType:(TMapViewAnnotationType)annotationType {
    if (location == nil) {
        self.tableViewData = nil;
        [self.mapView removeAnnotations:self.mapView.annotations];
        [self.tableView reloadData];
        return;
    }
    if (setMapViewCenter) {
        [self setMapViewCenter:location.coordinate animated:animated];
    }
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks == nil) {
            self.tableViewData = nil;
            [self.mapView removeAnnotations:self.mapView.annotations];
            [self.tableView reloadData];
            return;
        }
        NSMutableArray<CHSLocationModel *> *locationModelArray = [NSMutableArray<CHSLocationModel *> array];
        for (CLPlacemark *placemark in placemarks) {
            CHSLocationModel *model =[CHSLocationModel modelWithSubLocality:placemark.subLocality name:placemark.name latitude:placemark.location.coordinate.latitude longitude:placemark.location.coordinate.longitude];
            [locationModelArray addObject:model];
        }
        if (annotationType == TMapViewAnnotationTypeFirst && locationModelArray.count >= 1) {
            [self refreshAnnotationsForModelArray:@[locationModelArray.firstObject]];
        } else {
            [self refreshAnnotationsForModelArray:locationModelArray];
        }
        [self updateTableViewForArray:locationModelArray];
    }];
}

/// 输入文字结束搜索, 其他情况不搜索
- (void)searchMapForText:(NSString *)text {
    if (text.length <= 0) {
        // 恢复用户当前位置
        self.shouldRefreshUserLocation = YES;
        [self refreshViewWithLocation:self.mapView.userLocation.location
                     setMapViewCenter:YES
                             animated:YES
                       annotationType:TMapViewAnnotationTypeFirst];
        return;
    }
    // 搜索则拦截用户位置更新, 不进行显示
    self.shouldRefreshUserLocation = NO;
    MKLocalSearchRequest *searchRequest = [[MKLocalSearchRequest alloc] init];
    [searchRequest setNaturalLanguageQuery:text];
    [searchRequest setRegion:self.mapView.region];
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:searchRequest];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse * _Nullable response, NSError * _Nullable error) {
        // [self.mapView setRegion:response.boundingRegion];
        NSMutableArray<CHSLocationModel *> *locationModelArray = [NSMutableArray<CHSLocationModel *> array];
        for (MKMapItem *item in response.mapItems) {
            CHSLocationModel *model =[CHSLocationModel modelWithSubLocality:item.placemark.subLocality
                                                                   name:item.placemark.name
                                                               latitude:item.placemark.location.coordinate.latitude
                                                              longitude:item.placemark.location.coordinate.longitude];
            [locationModelArray addObject:model];
        }
        
        [self setMapViewCenter:response.mapItems.firstObject.placemark.location.coordinate
                      animated:YES];
        [self refreshAnnotationsForModelArray:locationModelArray];
        [self updateTableViewForArray:locationModelArray];
    }];
}

- (void)locationHandlerWithAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
        case kCLAuthorizationStatusAuthorizedAlways:
            [self.locationManager startUpdatingLocation];
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
            // 权限受限，可引导用户开启
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self refreshViewWithLocation:self.mapView.userLocation.location setMapViewCenter:YES animated:YES annotationType:TMapViewAnnotationTypeFirst];
                });
            }
            break;
        case kCLAuthorizationStatusNotDetermined:
            // 未选择，一般是首次启动，根据需要发起申请
            [self.locationManager requestAlwaysAuthorization];
            [self.locationManager requestWhenInUseAuthorization];
            break;
        default:
            break;
    }
}

#pragma mark - UITableViewDelegate, UITableViewDataSource

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self locationHandlerWithAuthorizationStatus:status];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [self.locationManager stopUpdatingLocation];
//    CLLocation *currentLocation = [locations lastObject];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self refreshViewWithLocation:self.mapView.userLocation.location setMapViewCenter:YES animated:YES annotationType:TMapViewAnnotationTypeFirst];
    });
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.tableViewData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.000001;
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
    model.hidden = (indexPath.row == self.tableViewData.count - 1);
    viewCell.model = model;
    return viewCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    self.shouldRefreshUserLocation = NO;
    
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
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.selectedModel.latitude
                                                      longitude:self.selectedModel.longitude];
    [self setMapViewCenter:location.coordinate animated:NO];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    [self searchMapForText:textField.text];
    return YES;
}


#pragma mark - MKMapViewDelegate
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(nonnull MKUserLocation *)userLocation {
    if (self.shouldRefreshUserLocation) {
        [self refreshViewWithLocation:userLocation.location
                     setMapViewCenter:YES
                             animated:YES
                       annotationType:TMapViewAnnotationTypeFirst];
    }
}

- (CLLocationManager *)locationManager
{
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }
    return _locationManager;
}

- (UIView *)searchView {
    if(_searchView == nil) {
        _searchView = [[UIView alloc] init];
        _searchView.layer.shadowColor = UIColor.blackColor.CGColor;
        _searchView.layer.shadowOpacity = 0.5;
        _searchView.layer.shadowOffset = CGSizeMake(0, 5);
        _searchView.layer.shadowRadius = 10;
        _searchView.backgroundColor = [UIColor whiteColor];
    }
    return _searchView;
}

- (UITextField *)searchTextField {
    if(_searchTextField == nil) {
        _searchTextField = [[UITextField alloc] init];
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14.0], NSForegroundColorAttributeName:[UIColor color_OCHexStr:@"#909399"]};
        _searchTextField.font = [UIFont systemFontOfSize:14.0];
        _searchTextField.textColor = [UIColor color_OCHexStr:@"#303133"];
        _searchTextField.attributedPlaceholder = [[NSMutableAttributedString alloc] initWithString:@"亲，请输入位置鸭" attributes:attributes];
        _searchTextField.delegate = self;
        _searchTextField.tag = 0;
        _searchTextField.returnKeyType = UIReturnKeyDone;
        _searchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    }
    return _searchTextField;
}

- (MKMapView *)mapView {
    if(_mapView == nil) {
        _mapView = [[MKMapView alloc] init];
        _mapView.mapType = MKMapTypeStandard;
        _mapView.showsUserLocation = YES;
        _mapView.zoomEnabled = YES;
        _mapView.scrollEnabled = YES;
        _mapView.showsBuildings = YES;
        _mapView.userInteractionEnabled = YES;
        _mapView.rotateEnabled = YES;
        _mapView.showsCompass = YES;
        _mapView.showsPointsOfInterest = YES;
        _mapView.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *mapViewTouch = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchMapView:)];
        [_mapView addGestureRecognizer:mapViewTouch];
    }
    return _mapView;
}

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        [_tableView registerClass:[CHSFetchLocationTableViewCell class] forCellReuseIdentifier:NSStringFromClass([CHSFetchLocationTableViewCell class])];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if (@available(iOS 15.0, *)) {
            _tableView.sectionHeaderTopPadding = 0;
        }
        _tableView.allowsMultipleSelectionDuringEditing = YES;
    }
    return _tableView;
}

- (UIButton *)searchButton {
    if(_searchButton == nil) {
        _searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_searchButton setTitle:@"搜索" forState:UIControlStateNormal];
        _searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _searchButton.tag = 0;
        _searchButton.backgroundColor = [UIColor color_OCHexStr:@"3B71E8"];
        [_searchButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_searchButton addTarget:self action:@selector(toExcute:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchButton;
}

- (UIButton *)excuteButton {
    if(_excuteButton == nil) {
        _excuteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_excuteButton setTitle:@"添加位置" forState:UIControlStateNormal];
        _excuteButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _excuteButton.tag = 1;
        _excuteButton.layer.cornerRadius = 22.0;
        _excuteButton.layer.masksToBounds = YES;
        _excuteButton.layer.borderColor = [[UIColor color_OCHexStr:@"303133"] CGColor];
        _excuteButton.layer.borderWidth = 0.5;
        [_excuteButton setTitleColor:[UIColor color_OCHexStr:@"303133"] forState:UIControlStateNormal];
        [_excuteButton addTarget:self action:@selector(toExcute:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _excuteButton;
}

- (CHSGradientNavigationView *)gradientNavigationView
{
    if (!_gradientNavigationView) {
        CHSGradientNavigationModel *model = [[CHSGradientNavigationModel alloc] init];
        model.title = @"添加位置";
        model.titleColor = [UIColor color_OCHexStr:@"#303133"];
        model.leftImage = @"back";
        model.rightImage = @"user_location";
        model.startGradientColor = [UIColor whiteColor];
        model.endGradientColor = [UIColor whiteColor];
        _gradientNavigationView = [[CHSGradientNavigationView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, StatusBarHeight+NavBarHeight)];
        _gradientNavigationView.model = model;
        __weak __typeof(self)weakSelf = self;
        _gradientNavigationView.clickBlock = ^(NSInteger index) {
            if (index == 0) {
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
                [weakSelf freshUserLocation];
            }
        };
    }
    return _gradientNavigationView;
}


@end
