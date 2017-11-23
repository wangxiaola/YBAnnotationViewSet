//
//  MapNoniusVC.m
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/23.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "MapNoniusVC.h"
#import <MAMapKit/MAMapKit.h>
#import "MapNoniusTool.h"

@interface MapNoniusVC () <MAMapViewDelegate>
{
    BOOL isFirstLoad;
    CLLocationCoordinate2D otherCoor;   //目标点的坐标（可以想象成打游戏你队友的坐标）
}
@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) UIImageView *testNonius;

@end

@implementation MapNoniusVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kColor_white;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    isFirstLoad = YES;
    
    _testNonius = [UIImageView new];
    _testNonius.backgroundColor = [UIColor clearColor];
    _testNonius.contentMode = UIViewContentModeScaleAspectFit;
    _testNonius.bounds = CGRectMake(0, 0, 60, 60);
    _testNonius.image = [UIImage imageNamed:@"header.jpg"];
    
    [self.view addSubview:self.mapView];
}

#pragma mark *** MAMapViewDelegate ***
- (void)mapViewRegionChanged:(MAMapView *)mapView {
    if (!isFirstLoad) {
        if (!_testNonius.superview) {
            [self.view addSubview:_testNonius];
        }
        CGPoint point = [[MapNoniusTool new] countIntersectionWithMap:mapView countView:self.view otherCoor:otherCoor];
        if (CGPointEqualToPoint(point, CGPointMake(MAXFLOAT, MAXFLOAT))) {
            //说明未找到交点，移除
            [_testNonius removeFromSuperview];
        } else {
            //找到了就赋值center
            _testNonius.center = point;
        }
    }
}

- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (isFirstLoad) {
        isFirstLoad = NO;
        //生成一个坐标
        otherCoor = CLLocationCoordinate2DMake(mapView.centerCoordinate.latitude+0.0001, mapView.centerCoordinate.longitude+0.0001);
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            //添加到地图上
            MAPointAnnotation *anno = [MAPointAnnotation new];
            anno.coordinate = otherCoor;
            anno.title = @"你的队友";
            [mapView addAnnotation:anno];
        });
    }
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        MAPinAnnotationView *annotationView = (MAPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pointReuseIndentifier"];
        if (!annotationView)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pointReuseIndentifier"];
        }
        annotationView.canShowCallout = YES;
        annotationView.selected = YES;

        return annotationView;
    }

    return nil;
}


#pragma mark *** getter ***
- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        _mapView.delegate = self;
        _mapView.zoomLevel = 14;
        //需要去掉天空模式，如果不想去掉，就在找到交点的时候，做下判断，算好位置
        _mapView.skyModelEnable = NO;
    }
    return _mapView;
}




@end
