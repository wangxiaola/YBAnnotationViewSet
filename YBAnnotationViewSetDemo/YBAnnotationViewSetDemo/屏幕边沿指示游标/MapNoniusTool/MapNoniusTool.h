//
//  MapNoniusTool.h
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/23.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@interface MapNoniusTool : NSObject

- (CGPoint)countIntersectionWithMap:(MAMapView *)mapView countView:(UIView *)countView otherCoor:(CLLocationCoordinate2D)otherCoor;

@end
