//
//  AnnotationQuadTree.h
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/20.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface AnnotationQuadTreeNode : NSObject

//该节点所包含的范围
@property (nonatomic, assign) CGRect rect;
//该节点的子叶数组
@property (nonatomic, strong) NSMutableArray *leafArray;
//子叶的最大数量
@property (nonatomic, assign) NSInteger numberOfLeaf;

@end
