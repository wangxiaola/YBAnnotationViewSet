//
//  AnnotationQuadTreeManager.h
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/20.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnnotationQuadTreeNode.h"
#import "MapAnnotationModel.h"
#import <MAMapKit/MAMapKit.h>
#import "CustomPointAnnotation.h"

@interface AnnotationQuadTreeManager : NSObject

@property (nonatomic, strong, readonly) AnnotationQuadTreeNode *rootNode;

/**
 构建四叉树数据结构

 @param array 网络请求的数组
 */
- (void)structureQuadTreeWith:(NSArray<MapAnnotationModel *> *)array;


/**
 获取需要展示的annotation

 @param mapView 地图指针
 */
- (NSArray *)getPointAnnotationsWithMapView:(MAMapView *)mapView;

@end
