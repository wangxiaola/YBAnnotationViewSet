//
//  MapVC.m
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/20.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "MapVC.h"
#import <MAMapKit/MAMapKit.h>
#import "MapAnnotationModel.h"
#import "CustomPointAnnotation.h"
#import "AnnotationQuadTreeManager.h"
#import "Tool.h"

@interface MapVC () <MAMapViewDelegate>
{
    BOOL isFirstLoad;
}
@property (nonatomic, strong) MAMapView *mapView;

@property (nonatomic, strong) AnnotationQuadTreeManager *quadTreeManager;

@end

@implementation MapVC
- (void)dealloc {
    NSLog(@"%s", __func__);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstLoad = YES;
    self.view = self.mapView;
    
}

#pragma mark *** private ***
//模拟从服务器请求下来的数据
- (void)randomCoorsWithCoor:(CLLocationCoordinate2D)coor block:(void(^)(NSArray<MapAnnotationModel *> *))arrblock {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int i = 0; i < 50000; i++) {
            
            CLLocationDegrees latitude = random()%100*0.001f + coor.latitude;
            CLLocationDegrees longitude = random()%100*0.001f + coor.longitude;
            
            MapAnnotationModel *model = [MapAnnotationModel new];
            model.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
            model.extraStr = [NSString stringWithFormat:@"第%d个点", i];
            
            [tempArr addObject:model];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            arrblock(tempArr);
        });
        
    });
    
}

#pragma mark *** MAMapViewDelegate ***
- (void)mapView:(MAMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    if (isFirstLoad) {
        isFirstLoad = NO;
        
        [self randomCoorsWithCoor:mapView.centerCoordinate block:^(NSArray<MapAnnotationModel *> *arr) {
            //构建树
            [self quadNode_structureTree:arr];
        }];
        
    } else {
        
        [Tool countTimeWithCode:^NSString *{
            //更新标注
            [self quadNode_addAnnotations];
            
            return @"更新标注耗时";
        }];
        
    }
}


#pragma mark *** getter ***
- (MAMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, 44+kHeightOfStatusBar, SCREEN_WIDTH, SCREEN_HEIGHT-44-kHeightOfStatusBar)];
        _mapView.delegate = self;
        _mapView.zoomLevel = 12;
    }
    return _mapView;
}
- (AnnotationQuadTreeManager *)quadTreeManager {
    if (!_quadTreeManager) {
        _quadTreeManager = [AnnotationQuadTreeManager new];
    }
    return _quadTreeManager;
}


#pragma mark *** 核心方法 ***
- (void)quadNode_structureTree:(NSArray<MapAnnotationModel *> *)arr {
    
    @synchronized(self)
    {
        //移除之前的标注
        NSMutableArray *removeAnnotation = [NSMutableArray arrayWithArray:self.mapView.annotations];
        [removeAnnotation removeObject:self.mapView.userLocation];
        [self.mapView removeAnnotations:removeAnnotation];
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [weakSelf.quadTreeManager structureQuadTreeWith:arr];
            [weakSelf quadNode_addAnnotations];
        });
    }
    
}
- (void)quadNode_addAnnotations {
    
    @synchronized(self)
    {
        if (!self.quadTreeManager.rootNode) {
            return;
        }
        
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSArray *annotations = [weakSelf.quadTreeManager getPointAnnotationsWithMapView:weakSelf.mapView];
            [weakSelf quadNode_updateMapViewAnnotations:annotations];
        });
    }
}

- (void)quadNode_updateMapViewAnnotations:(NSArray *)annotations
{
    //当前屏幕上的标注
    NSMutableSet *before = [NSMutableSet setWithArray:self.mapView.annotations];
    [before removeObject:[self.mapView userLocation]];
    
    //需要添加的标注
    NSSet *after = [NSSet setWithArray:annotations];
    
    //取交集
    NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
    [toKeep intersectSet:after];
    
    //去掉它们的交集，剩下就是需要添加的标注
    NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
    [toAdd minusSet:toKeep];
    
    //去掉屏幕之外的标注
    NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
    [toRemove minusSet:after];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.mapView addAnnotations:[toAdd allObjects]];
        [self.mapView removeAnnotations:[toRemove allObjects]];
    });
}


@end
