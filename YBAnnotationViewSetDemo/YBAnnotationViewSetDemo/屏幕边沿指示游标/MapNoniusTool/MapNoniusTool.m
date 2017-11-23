//
//  MapNoniusTool.m
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/23.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "MapNoniusTool.h"

@implementation MapNoniusTool

#pragma mark *** 核心计算 ***
- (CGPoint)countIntersectionWithMap:(MAMapView *)mapView countView:(UIView *)countView otherCoor:(CLLocationCoordinate2D)otherCoor {
    
    //获取计算view的宽高
    CGFloat width = countView.bounds.size.width;
    CGFloat height = countView.bounds.size.height;
    
    //屏幕四个点经纬度
    CLLocationCoordinate2D coor0 = [mapView convertPoint:CGPointMake(0, 0) toCoordinateFromView:countView];
    CLLocationCoordinate2D coor1 = [mapView convertPoint:CGPointMake(width, 0) toCoordinateFromView:countView];
    CLLocationCoordinate2D coor2 = [mapView convertPoint:CGPointMake(width, height) toCoordinateFromView:countView];
    CLLocationCoordinate2D coor3 = [mapView convertPoint:CGPointMake(0, height) toCoordinateFromView:countView];
    
    //都转换成CGpoint结构体
    CGPoint startPoint = CGPointMake(mapView.centerCoordinate.longitude, mapView.centerCoordinate.latitude);
    CGPoint endPoint = CGPointMake(otherCoor.longitude, otherCoor.latitude);
    CGPoint point0 = CGPointMake(coor0.longitude, coor0.latitude);
    CGPoint point1 = CGPointMake(coor1.longitude, coor1.latitude);
    CGPoint point2 = CGPointMake(coor2.longitude, coor2.latitude);
    CGPoint point3 = CGPointMake(coor3.longitude, coor3.latitude);
    
    
    //计算有效交点
    CGPoint resultCoor = CGPointMake(MAXFLOAT, MAXFLOAT);
    [self getIntersection:startPoint :endPoint :point0 :point1 :&resultCoor];
    [self getIntersection:startPoint :endPoint :point1 :point2 :&resultCoor];
    [self getIntersection:startPoint :endPoint :point2 :point3 :&resultCoor];
    [self getIntersection:startPoint :endPoint :point3 :point0 :&resultCoor];
    if (CGPointEqualToPoint(resultCoor, CGPointMake(MAXFLOAT, MAXFLOAT))) {
        //容错
        return CGPointMake(MAXFLOAT, MAXFLOAT);
    }
    
    //转换成实际屏幕上的点
    CGPoint resultPoint = [mapView convertCoordinate:CLLocationCoordinate2DMake(resultCoor.y, resultCoor.x) toPointToView:countView];
    //误差修复
    if (resultPoint.x < 0) {
        resultPoint.x = 0;
    }
    if (resultPoint.x > width) {
        resultPoint.x = width;
    }
    if (resultPoint.y < 0) {
        resultPoint.y = 0;
    }
    if (resultPoint.y > height) {
        resultPoint.y = height;
    }
    
    //NSLog(@" p0:%lf,%lf; p1:%lf,%lf; p2:%lf,%lf; p3:%lf,%lf\n resultPoint: %lf, %lf \n", p0.x, p0.y, p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, resultPoint.x, resultPoint.y);
    
    return resultPoint;
    
}



//获取p1、p2组成的线段和p3、p4组成的线段的交点
- (BOOL)getIntersection:(CGPoint)p1 :(CGPoint)p2 :(CGPoint)p3 :(CGPoint)p4 :(CGPoint *)intersectionPoint {
    
    //先判断是否有交点，判断方法是判断每个线段的端点都在另一条线段的两侧，用向量叉积
    double s123 = (p1.x - p3.x) * (p2.y - p3.y) - (p1.y - p3.y) * (p2.x - p3.x);
    double s124 = (p1.x - p4.x) * (p2.y - p4.y) - (p1.y - p4.y) * (p2.x - p4.x);
    
    //共线或不在两端
    if (s123 * s124 >= 0) {
        return NO;
    }
    
    double s134 = (p3.x - p1.x) * (p4.y - p1.y) - (p3.y - p1.y) * (p4.x - p1.x);
    double s234 = (p3.x - p2.x) * (p4.y - p2.y) - (p3.y - p2.y) * (p4.x - p2.x);
    
    //共线或不在两端
    if (s134 * s234 >= 0) {
        return NO;
    }
    
    double t = s134 / ( s124 - s123);
    double dx= t*(p2.x - p1.x),
    dy = t*(p2.y - p1.y);
    
    intersectionPoint->x = p1.x + dx;
    intersectionPoint->y = p1.y + dy;
    
    return YES;
}


@end
