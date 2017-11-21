//
//  AnnotationQuadTreeNode.m
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/20.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "AnnotationQuadTreeNode.h"

CoordinateBox CoordinateBoxMake(double minLatitude, double maxLatitude, double minLongitude, double maxLongitude) {
    CoordinateBox box;
    box.minLatitude = minLatitude;
    box.maxLatitude = maxLatitude;
    box.minLongitude = minLongitude;
    box.maxLongitude = maxLongitude;
    return box;
}
bool CoordinateBoxContainCoordinate(CoordinateBox box, CLLocationCoordinate2D coordinate) {
    bool containLatitude = coordinate.latitude <= box.maxLatitude && coordinate.latitude >= box.minLatitude;
    bool containLontitude = coordinate.longitude <= box.maxLongitude && coordinate.longitude >= box.minLongitude;
    return containLatitude && containLontitude;
}

bool CoordinateBoxIntersectCoordinateBox(CoordinateBox box0, CoordinateBox box1) {
    return (box0.minLatitude <= box1.maxLatitude && box0.maxLatitude >= box1.minLatitude && box0.minLongitude <= box1.maxLongitude && box0.maxLongitude >= box1.minLongitude);
}

CoordinateBox CoordinateBoxForMapRect(MAMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MACoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MACoordinateForMapPoint(MAMapPointMake(MAMapRectGetMaxX(mapRect), MAMapRectGetMaxY(mapRect)));
    
    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;
    
    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;
    
    return CoordinateBoxMake(minLat, maxLat, minLon, maxLon);
}


@implementation AnnotationQuadTreeNode

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSMutableArray<AnnotationQuadTreeNode *> *)leafArray {
    if (!_leafArray) {
        _leafArray = [NSMutableArray array];
    }
    return _leafArray;
}
- (NSInteger)maxNumberOfLeaf {
    if (!_maxNumberOfLeaf) {
        _maxNumberOfLeaf = 4;
    }
    return _maxNumberOfLeaf;
}

@end
