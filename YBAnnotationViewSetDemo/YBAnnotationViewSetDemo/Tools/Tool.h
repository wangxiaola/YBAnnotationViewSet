//
//  Tool.h
//  YBAnnotationViewSetDemo
//
//  Created by 杨波 on 2017/11/21.
//  Copyright © 2017年 yangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

#if DEBUG
#define NSLog(FORMAT, ...) fprintf(stderr,"%s\n",[[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define NSLog(FORMAT, ...) nil
#endif

@interface Tool : NSObject

//打印执行代码时间
+ (void)countTimeWithCode:(NSString *(^)(void))code;

@end
