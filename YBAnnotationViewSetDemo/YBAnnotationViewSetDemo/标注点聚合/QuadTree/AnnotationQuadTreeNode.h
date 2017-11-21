//
//  AnnotationQuadTreeNode.h
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/20.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapAnnotationModel.h"
#import <MAMapKit/MAMapKit.h>

//经纬度最大最小值范围结构体
struct CoordinateBox {
    double minLatitude;
    double maxLatitude;
    double minLongitude;
    double maxLongitude;
};
typedef struct CoordinateBox CoordinateBox;

//构造结构体方法
CoordinateBox CoordinateBoxMake(double minLatitude, double maxLatitude, double minLongitude, double maxLongitude);
//判断经纬度box是否包含经纬度
bool CoordinateBoxContainCoordinate(CoordinateBox box, CLLocationCoordinate2D coordinate);
//判断经纬度box是否相交
bool CoordinateBoxIntersectCoordinateBox(CoordinateBox box0, CoordinateBox box1);
//MAMapRect转经纬度范围
CoordinateBox CoordinateBoxForMapRect(MAMapRect mapRect);


@interface AnnotationQuadTreeNode : NSObject

//节点范围
@property (nonatomic, assign) CoordinateBox box;
//节点业务数据源
@property (nonatomic, strong) MapAnnotationModel *model;

//四个方向的子叶
@property (nonatomic, strong) NSMutableArray<AnnotationQuadTreeNode *> *leafArray;
//最大子叶数量
@property (nonatomic, assign) NSInteger maxNumberOfLeaf;

@end
