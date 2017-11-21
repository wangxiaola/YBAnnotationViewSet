//
//  CustomPointAnnotation.h
//  YONE
//
//  Created by 杨波 on 2017/10/31.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>
#import "MapAnnotationModel.h"

@interface CustomPointAnnotation : MAPointAnnotation

//业务数据model
@property (nonatomic, strong) MapAnnotationModel *model;

@end
