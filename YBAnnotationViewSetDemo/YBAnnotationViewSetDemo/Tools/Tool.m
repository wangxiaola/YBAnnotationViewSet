//
//  Tool.m
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/21.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import "Tool.h"

@implementation Tool

+ (void)countTimeWithCode:(NSString *(^)(void))code {
    
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    NSString *str = code();
    CFAbsoluteTime linkTime = (CFAbsoluteTimeGetCurrent() - startTime);
    NSLog(@"%@：%f ms", str, linkTime *1000.0);
}

@end
