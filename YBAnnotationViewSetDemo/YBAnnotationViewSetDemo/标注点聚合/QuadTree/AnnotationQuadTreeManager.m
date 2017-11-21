//
//  AnnotationQuadTreeManager.m
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/20.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "AnnotationQuadTreeManager.h"

//测试用
static int tempInt = 0;


@interface AnnotationQuadTreeManager ()

//跟节点（树干）
@property (nonatomic, strong) AnnotationQuadTreeNode *rootNode;

@end

@implementation AnnotationQuadTreeManager

#pragma mark *** public ***
- (void)structureQuadTreeWith:(NSArray<MapAnnotationModel *> *)array {
    if (array.count <= 0) {
        return;
    }
    if (self.rootNode) {
        self.rootNode = nil;
    }
    
    NSArray<AnnotationQuadTreeNode *> *nodeArr = [self convertToNodeWithArr:array];
    [nodeArr enumerateObjectsUsingBlock:^(AnnotationQuadTreeNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self insertNodeLeafWithTrunk:self.rootNode leaf:obj];
    }];
}

- (NSArray *)getPointAnnotationsWithMapView:(MAMapView *)mapView {
    
    tempInt = 0;
    
    if (mapView.zoomLevel >= 19) {
        return [self getAnnotationWithOutFilter:mapView.visibleMapRect];
    }
    
    MAMapRect visibleMapRect = mapView.visibleMapRect;
    //屏幕每个单位对应实际距离
    CGFloat metreOfOnePoint = visibleMapRect.size.width / mapView.bounds.size.width;
    
    //把地图在屏幕上的映射区域分为若干个区域块
    //屏幕区域块size（pt）
    CGSize sizeOfArea = [self getSizeWithZoomLevel:mapView.zoomLevel];
    //实际区域块size（m）
    CGSize metreSizeOfArea = CGSizeMake(sizeOfArea.width*metreOfOnePoint, sizeOfArea.height*metreOfOnePoint);
    
    //计算区域块的数量（因为地图可以旋转，所以在屏幕上的映射不能以正常坐标系来计算，应该用有效区域的经纬度各自的差值来计算）
    CGFloat metreMinX = MAMapRectGetMinX(visibleMapRect);
    CGFloat metreMinY = MAMapRectGetMinY(visibleMapRect);
    CGFloat metreMaxX = MAMapRectGetMaxX(visibleMapRect);
    CGFloat metreMaxY = MAMapRectGetMaxY(visibleMapRect);
    NSInteger x_areaNumber = ceil((metreMaxX-metreMinX)/metreSizeOfArea.width);
    NSInteger y_areaNumber = ceil((metreMaxY-metreMinY)/metreSizeOfArea.height);
    
    NSMutableArray *annotaionsArr = [NSMutableArray array];
    for (NSInteger x = 0; x < x_areaNumber; x++) {
        for (NSInteger y = 0; y < y_areaNumber; y++) {
            
            //每个区块转换成实际的rect（m）
            MAMapRect rect = MAMapRectMake(metreMinX + x*metreSizeOfArea.width, metreMinY + y*metreSizeOfArea.height, metreSizeOfArea.width, metreSizeOfArea.height);
            //转为经纬度范围
            CoordinateBox box = CoordinateBoxForMapRect(rect);
            
            //开始查找
            __block double totalX = 0;
            __block double totalY = 0;
            NSMutableArray<MapAnnotationModel *> *tempNodeArr = [NSMutableArray array];
            [self filterAnnotationWithNode:self.rootNode box:box block:^BOOL(AnnotationQuadTreeNode *needNode) {
                
                totalX += needNode.model.coordinate.latitude;
                totalY += needNode.model.coordinate.longitude;
                [tempNodeArr addObject:needNode.model];
                
                //每个区块查找限制，以提高效率
                if (tempNodeArr.count > 4) {
                    return NO;
                } else {
                    return YES;
                }
                return YES;
            }];
            
            //如果只查出一个
            if (tempNodeArr.count == 1) {
                CustomPointAnnotation *annotation = [CustomPointAnnotation new];
                annotation.model = tempNodeArr[0];
                annotation.coordinate = tempNodeArr[0].coordinate;
                [annotaionsArr addObject:annotation];
            }
            
            //如果大于一个，合并处理（这里按照需求来整）
            if (tempNodeArr.count > 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / tempNodeArr.count, totalY / tempNodeArr.count);
                CustomPointAnnotation *annotation = [CustomPointAnnotation new];
                annotation.model = tempNodeArr[0];
                annotation.coordinate = coordinate;
                [annotaionsArr addObject:annotation];
            }
            
        }
    }
    
    NSLog(@"查找标注次数：%d", tempInt);
    return annotaionsArr;
}

#pragma mark *** private ***

//这里可根据标注的大小自己调整(单位是iOS计量单位)
- (CGSize)getSizeWithZoomLevel:(NSInteger)zoomLevel {
    if (zoomLevel < 13.0) {
        return CGSizeMake(50, 50);
    } else if (zoomLevel < 15.0) {
        return CGSizeMake(40, 40);
    } else if (zoomLevel < 18.0) {
        return CGSizeMake(30, 20);
    } else if (zoomLevel < 20.0) {
        return CGSizeMake(20, 20);
    }
    return CGSizeMake(20, 20);
}

- (void)filterAnnotationWithNode:(AnnotationQuadTreeNode *)node box:(CoordinateBox)box block:(BOOL(^)(AnnotationQuadTreeNode *))nodeBlock {
    
    //范围无交集
    if (!CoordinateBoxIntersectCoordinateBox(node.box, box)) {
        return;
    }
    
    //无子叶
    if (node.leafArray.count <= 0) {
        return;
    }
    
    //遍历查找子叶是否在范围内
    [node.leafArray enumerateObjectsUsingBlock:^(AnnotationQuadTreeNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        tempInt++;
        if (CoordinateBoxContainCoordinate(box, obj.model.coordinate)) {
            if (!nodeBlock(obj)) {
                return;
            }
        }
        //向下查找
        [self filterAnnotationWithNode:obj box:box block:nodeBlock];
    }];
    
}

- (NSArray *)getAnnotationWithOutFilter:(MAMapRect)rect {
    NSMutableArray *tempArr = [NSMutableArray array];
    [self filterAnnotationWithNode:self.rootNode box:CoordinateBoxForMapRect(rect) block:^BOOL(AnnotationQuadTreeNode *node) {
        CustomPointAnnotation *annotation = [CustomPointAnnotation new];
        annotation.model = node.model;
        annotation.coordinate = node.model.coordinate;
        [tempArr addObject:annotation];
        return YES;
    }];
    return tempArr;
}

//依次插入数据
- (BOOL)insertNodeLeafWithTrunk:(AnnotationQuadTreeNode *)trunk leaf:(AnnotationQuadTreeNode *)leaf {
    
    //不在范围内
    if (!CoordinateBoxContainCoordinate(trunk.box, leaf.model.coordinate)) {
        return NO;
    }
    
    //若节点容量未满
    double mid_latitude = (trunk.box.maxLatitude+trunk.box.minLatitude)/2.0f;
    double mid_lontitude = (trunk.box.maxLongitude+trunk.box.maxLongitude)/2.0f;
    CoordinateBox trunkBox = trunk.box;
    if (trunk.leafArray.count < trunk.maxNumberOfLeaf) {
        //计算子叶的范围
        switch (trunk.leafArray.count) {
            case 0: {
                leaf.box = CoordinateBoxMake(trunkBox.minLatitude, mid_latitude, trunkBox.minLongitude, mid_lontitude);
            }
                break;
            case 1: {
                leaf.box = CoordinateBoxMake(mid_latitude, trunkBox.maxLatitude, trunkBox.minLongitude, mid_lontitude);
            }
                break;
            case 2: {
                leaf.box = CoordinateBoxMake(trunkBox.minLatitude, mid_latitude, mid_lontitude, trunkBox.maxLongitude);
            }
                break;
            case 3: {
                leaf.box = CoordinateBoxMake(mid_latitude, trunkBox.maxLatitude, mid_lontitude, trunkBox.maxLongitude);
            }
                break;
            default:
                break;
        }
        [trunk.leafArray addObject:leaf];
        return YES;
    }
    
    //若节点容量已满
    //向下延展
    if ([self insertNodeLeafWithTrunk:trunk.leafArray[0] leaf:leaf]) return YES;
    if ([self insertNodeLeafWithTrunk:trunk.leafArray[1] leaf:leaf]) return YES;
    if ([self insertNodeLeafWithTrunk:trunk.leafArray[2] leaf:leaf]) return YES;
    if ([self insertNodeLeafWithTrunk:trunk.leafArray[3] leaf:leaf]) return YES;
    
    return NO;
}

//把网络请求获取的数据转换成节点数据
- (NSArray<AnnotationQuadTreeNode *> *)convertToNodeWithArr:(NSArray<MapAnnotationModel *> *)array {
    
    __block double minLatitude = array[0].coordinate.latitude;
    __block double maxLatitude = array[0].coordinate.latitude;
    __block double minLongitude = array[0].coordinate.longitude;
    __block double maxLongitude = array[0].coordinate.longitude;
    
    NSMutableArray *nodeArr = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(MapAnnotationModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //转换为node
        AnnotationQuadTreeNode *node = [AnnotationQuadTreeNode new];
        node.model = obj;
        [nodeArr addObject:node];
        
        //找到经纬度极值
        CLLocationCoordinate2D currentCoor = obj.coordinate;
        if (currentCoor.latitude < minLatitude) {
            minLatitude = currentCoor.latitude;
        }
        if (currentCoor.latitude > maxLatitude) {
            maxLatitude = currentCoor.latitude;
        }
        if (currentCoor.longitude < minLongitude) {
            minLongitude = currentCoor.longitude;
        }
        if (currentCoor.longitude > maxLongitude) {
            maxLongitude = currentCoor.longitude;
        }
    }];
    
    //给跟节点一个范围，但是不给业务数据
    self.rootNode = [AnnotationQuadTreeNode new];
    self.rootNode.box = CoordinateBoxMake(minLatitude, maxLatitude, minLongitude, maxLongitude);
    
    return nodeArr;
}


@end
