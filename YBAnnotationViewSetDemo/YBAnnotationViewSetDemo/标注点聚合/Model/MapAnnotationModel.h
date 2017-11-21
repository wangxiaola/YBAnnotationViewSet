//
//  MapAnnotationModel.h
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/20.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MapAnnotationModel : NSObject

//经纬度
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

//额外数据（需要和经纬度绑定的数据）
@property (nonatomic, copy) NSString *extraStr;

@end
