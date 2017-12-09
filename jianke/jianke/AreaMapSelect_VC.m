//
//  AreaMapSelect_VC.m
//  jianke
//
//  Created by fire on 16/8/15.
//  Copyright © 2016年 xianshijian. All rights reserved.
//

#import "AreaMapSelect_VC.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "LocateManager.h"
#import "AreaSelectView.h"

@interface AreaMapSelect_VC () <MAMapViewDelegate,AMapLocationManagerDelegate,AMapSearchDelegate,UITableViewDataSource,UITableViewDelegate,AreaSelectViewDelegate>

@property (nonatomic, weak) MAMapView *mapView;
//@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, weak) UITableView *resultTableView;
@property (nonatomic, weak) AreaSelectView *areaSearchView;

@property (nonatomic, strong) AMapLocationManager *locationManager;
@property (nonatomic, strong) AMapSearchAPI *searchAPI;
@property (nonatomic, strong) AMapPOIAroundSearchRequest *searchRequest;
@property (nonatomic, strong) AMapPOIKeywordsSearchRequest *keywordsRequest;
@property (nonatomic, strong) NSMutableArray *resultList;   //附近搜索列表
@property (nonatomic, strong) NSMutableArray *keywordsList; //关键字搜索列表
@property (nonatomic, strong) AMapPOI *poi;
@property (nonatomic, assign) BOOL isSearchBy;
@property (nonatomic, assign) BOOL isFromKeywords;
@property (nonatomic, assign) BOOL isBeginSearch;
@property (nonatomic, assign) BOOL isFirst;

@end

@implementation AreaMapSelect_VC

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.mapView.delegate = nil;
}

- (void)dealloc{
    self.mapView = nil;
    self.mapView.delegate = nil;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.title = @"选择集合地点";
    self.isSearchBy = YES;
    self.isFirst = YES;
    self.resultList = [NSMutableArray array];
    [self initUI];
    [self checkAuthStatus];
}

- (void)initUI{
    //rightItem
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(confirmAction:)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    //按钮
    UIButton *button = [UIButton buttonWithTitle:@"搜索" bgColor:[UIColor whiteColor] image:@"v250_icon_search" target:self sector:@selector(searchAction:)];
    [button setTitleColor:[UIColor XSJColor_tGray] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    [self.view addSubview:button];
    
    //地图
    MAMapView *mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    mapView.showsUserLocation = YES;
    mapView.userTrackingMode = MAUserTrackingModeFollowWithHeading;
    [mapView setZoomLevel:1 animated:YES];
    mapView.showsScale = YES;
    mapView.delegate = self;
    self.mapView = mapView;
    [self.view addSubview:mapView];
    
    //地图中心
    UIImageView *centerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_city_blue_local"]];
    [self.view addSubview:centerView];
    
    //搜索列表
    self.resultTableView = [UIHelper createTableViewWithStyle:UITableViewStylePlain delegate:self onView:self.view];
    self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.resultTableView.tag = 100;
    WEAKSELF
    self.resultTableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        weakSelf.isFooterefresh = YES;
        [weakSelf getMoreInfo];
    }];
    
    // 搜索API
    self.searchAPI = [[AMapSearchAPI alloc] init];
    self.searchAPI.delegate = self;
    
    //周边搜索参数
    self.searchRequest = [[AMapPOIAroundSearchRequest alloc] init];
    self.searchRequest.requireExtension = YES;
    self.searchRequest.offset = 30;
    
    //关键词搜索参数
    self.keywordsRequest = [[AMapPOIKeywordsSearchRequest alloc] init];
    self.keywordsRequest.requireExtension = YES;
    self.keywordsRequest.offset = 30;

    //定位
    self.locationManager = [[AMapLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    //约束
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.height.equalTo(@40);
    }];
    
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(button.mas_bottom);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.resultTableView.mas_top);
    }];
    
    [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@24);
        make.height.equalTo(@24);
        make.center.equalTo(self.mapView);
    }];
    
    [self.resultTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@1);
    }];
    [self.mapView addBorderInDirection:BorderDirectionTypeTop | BorderDirectionTypeBottom borderWidth:0.7 borderColor:[UIColor XSJColor_tGrayTinge] isConstraint:YES];
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
    if (updatingLocation) {
        self.isBeginSearch = YES;
        mapView.userTrackingMode = MAUserTrackingModeNone;
        mapView.showsUserLocation = NO;
        ELog(@"经度:%f----纬度:%f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
        MACoordinateSpan span = MACoordinateSpanMake(0.005, 0.005);
        [mapView setRegion:MACoordinateRegionMake(userLocation.location.coordinate, span) animated:YES];
    }
}

- (void)checkAuthStatus{
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ( status == kCLAuthorizationStatusDenied) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无法获取你的位置信息,请到手机系统的[位置]->[隐私]->[定位服务]中打开定位服务/或者使用[地址搜索]手动输入地址" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
        [alertView show];
    }
}

- (void)mapView:(MAMapView *)mapView didChangeUserTrackingMode:(MAUserTrackingMode)mode animated:(BOOL)animated{
    ELog(@"didChangeUserTrackingMode");
}

- (void)mapViewWillStartLocatingUser:(MAMapView *)mapView{
    ELog(@"mapViewWillStartLocatingUser");

}

//- (void)startLocation{
//    
//    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
//    if ( status == kCLAuthorizationStatusDenied) {
//        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"无法获取你的位置信息,请到手机系统的[位置]->[隐私]->[定位服务]中打开定位服务/或者使用[地址搜索]手动输入地址" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"我知道了", nil];
//        [alertView show];
//        return;
//    }
//    [UIHelper showLoading:YES withMessage:@"定位中"];
//    MACoordinateSpan span = MACoordinateSpanMake(0.005, 0.005);
//    WEAKSELF
//    [self.locationManager requestLocationWithReGeocode:NO completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
//        if (!error) {
//            [weakSelf.mapView setRegion:MACoordinateRegionMake(location.coordinate, span) animated:YES];
//            //        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
//            //        annotation.coordinate = location.coordinate;
//            //        [weakSelf.mapView addAnnotation:annotation];
//        }else{
//            [UIHelper toast:@"定位失败"];
//        }
//        [UIHelper showLoading:NO withMessage:nil];
//    }];
//}

#pragma mark - MAMapView delegate

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated{
    if (!self.isSearchBy) {
        self.isSearchBy = YES;
    }else if (self.isBeginSearch) {
        self.searchRequest.page = 1;
        [self searchNearby];
    }

}

//- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation{
//    if ([annotation isKindOfClass:[MAPointAnnotation class]]) {
//        static NSString *identifier = @"MAAnnotationViewForJob";
//        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
//        if (!annotationView) {
//            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
//            annotationView.image = [UIImage imageNamed:@"main_city_blue_local"];
//        }
//        annotationView.annotation = annotation;
//        self.annotationView = annotationView;
//        return annotationView;
//    }
//    return nil;
//}

#pragma mark - AMapSearch delegate

- (void)AMapSearchRequest:(id)request didFailWithError:(NSError *)error{
    ELog(@"**************%@",error.localizedDescription);
}

- (void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    ELog(@"请求页码%ld",(long)request.page);
    if (response.pois && response.pois.count) {
        if ([request isMemberOfClass:NSClassFromString(@"AMapPOIAroundSearchRequest")]) { //附近搜索
            
            if (self.isFromKeywords) {
                [self.resultList removeAllObjects];
                [self.resultList addObject:self.poi];
                [self.resultList addObjectsFromArray:response.pois];
                self.poi = [self.resultList objectAtIndex:0];
                self.isFromKeywords = NO;
            }else if (request.page > 1){
                [self.resultList addObjectsFromArray:response.pois];
                 [self.resultTableView.footer endRefreshing];
            }else{
                [self.resultList removeAllObjects];
                [self.resultList addObjectsFromArray:response.pois];
                self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
                [self.resultTableView setContentOffset:CGPointMake(0, 0) animated:NO];
                self.poi = [self.resultList objectAtIndex:0];
            }
            if (self.isFirst) {
                [self updateFrame];
                self.isFirst = NO;
            }
            self.navigationItem.rightBarButtonItem.enabled = YES;
            [self.resultTableView reloadData];
            
        }else if ([request isMemberOfClass:NSClassFromString(@"AMapPOIKeywordsSearchRequest")]){    //关键字搜索
            
            if (!self.keywordsRequest.keywords.length) {
                self.areaSearchView.tableView.hidden = YES;
                return;
            }
            if (request.page > 1) {
                [self.keywordsList addObjectsFromArray:response.pois];
                [self.areaSearchView.tableView.footer endRefreshing];
            }else{
                self.keywordsList = [response.pois mutableCopy];
            }
            self.areaSearchView.tableView.hidden = NO;
            [self.areaSearchView.tableView reloadData];
        }
        
    }else{
        if ([request isMemberOfClass:NSClassFromString(@"AMapPOIAroundSearchRequest")]) { //附近搜索
            if (request.page > 1) {
                [self.resultTableView.footer endRefreshing];
                return;
            }
            self.resultTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            self.navigationItem.rightBarButtonItem.enabled = NO;
            [self.resultList removeAllObjects];
            [self.resultTableView reloadData];
        }else if ([request isMemberOfClass:NSClassFromString(@"AMapPOIKeywordsSearchRequest")]){    //关键字搜索
            if (!self.keywordsRequest.keywords.length) {
                self.areaSearchView.tableView.hidden = YES;
                return;
            }
            [self.keywordsList removeAllObjects];
            self.areaSearchView.tableView.hidden = NO;
            [self.areaSearchView.tableView reloadData];
        }
    }
}

#pragma mark - uitableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 100) {
        return self.resultList ? self.resultList.count : 0;
    }else if(tableView.tag == 101){
        return self.keywordsList ? self.keywordsList.count : 0;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"AreaSelectCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    AMapPOI *poi = nil;
    if (tableView.tag == 100) {
        poi = self.resultList[indexPath.row];
        cell.accessoryType = (self.poi == poi) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }else if (tableView.tag == 101){
        poi = self.keywordsList[indexPath.row];
    }
    cell.textLabel.text = poi.name;
    cell.detailTextLabel.text = poi.address;
    cell.detailTextLabel.textColor = [UIColor XSJColor_tGray];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    ELog(@"选中地址更新状态");
    if (tableView.tag == 100) {
        AMapPOI *poi = self.resultList[indexPath.row];
        self.poi = poi;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.isSearchBy = NO;
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude) animated:YES];
        [tableView reloadData];
    }else if (tableView.tag == 101){
        self.poi = self.keywordsList[indexPath.row];
        [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.poi.location.latitude, self.poi.location.longitude) animated:NO];
        self.isFromKeywords = YES;
        [self searchNearby];
        [self areaSelectView:self.areaSearchView];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 49;
}

#pragma mark - AreaSelectView delegate

- (void)areaSelectView:(AreaSelectView *)searchView searchAction:(UITextField *)sender{
    self.keywordsRequest.keywords = sender.text;
    self.keywordsRequest.page = 1;
    [self searchKeywords];
}

- (void)areaSelectView:(AreaSelectView *)searchView{
    self.navigationController.navigationBarHidden = NO;
    [self.keywordsList removeAllObjects];
    [searchView removeFromSuperview];
}

#pragma mark - 其他

- (void)getMoreInfo{
    self.searchRequest.page++;
    [self searchNearby];
}

- (void)getMoreInfoWithKeywords{
    self.keywordsRequest.page++;
    [self searchKeywords];
}

//更新frame
- (void)updateFrame{
    [self.resultTableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@220);
    }];
}

//搜索附近
- (void)searchNearby{
    self.searchRequest.location = [self setMapViewCenter:self.mapView.centerCoordinate];
    ELog(@"搜索:%f--%f",self.searchRequest.location.latitude, self.searchRequest.location.longitude);
    [self.searchAPI AMapPOIAroundSearch:self.searchRequest];
}

////标注位置
//- (void)setAnnotationPosition{
//    [self.annotationView.annotation setCoordinate:self.mapView.centerCoordinate];
//}

//搜索关键词
- (void)searchKeywords{
    [self.searchAPI AMapPOIKeywordsSearch:self.keywordsRequest];
}

//button事件
- (void)searchAction:(UIButton *)sender{
    self.navigationController.navigationBarHidden = YES;
    AreaSelectView *searchView = [AreaSelectView showOnView:self.view];
    self.areaSearchView = searchView;
    searchView.delegate = self;
    searchView.tableView.dataSource = self;
    searchView.tableView.delegate = self;
    WEAKSELF
    searchView.tableView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf getMoreInfoWithKeywords];
    }];
}

//rightBarButton事件
- (void)confirmAction:(UIBarButtonItem *)sender{
    [self confirmArea];
}

- (void)confirmArea{
    if (self.navigationController.navigationBarHidden) {
        self.navigationController.navigationBarHidden = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
    MKBlockExec(self.block, self.poi);
}

- (AMapGeoPoint *)setMapViewCenter:(CLLocationCoordinate2D)coord{
    return [AMapGeoPoint locationWithLatitude:coord.latitude longitude:coord.longitude];
}

@end
