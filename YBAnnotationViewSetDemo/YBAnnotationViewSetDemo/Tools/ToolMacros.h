//
//  ToolMacros.h
//  CSJF
//
//  Created by 杨波 on 2017/4/15.
//  Copyright © 2017年 dingwei. All rights reserved.
//

#ifndef ToolMacros_h
#define ToolMacros_h



//系统版本
#define is_iOS11_above @available(iOS 11.0, *)
#define is_iPhoneX ([UIScreen mainScreen].bounds.size.height==812)
#define kHeightOfStatusBar (is_iPhoneX?44:20)

//尺寸
#define SCREEN_HEIGHT ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.height : [[UIScreen mainScreen] bounds].size.width)
#define SCREEN_WIDTH ((([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) || ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)
#define ALERT_WIDTH 270


//颜色
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)

#define kColor_black     [UIColor blackColor]
#define kColor_blue      [UIColor blueColor]
#define kColor_brown     [UIColor brownColor]
#define kColor_clear     [UIColor clearColor]
#define kColor_darkGray  [UIColor darkGrayColor]
#define kColor_darkText  [UIColor darkTextColor]
#define kColor_white     [UIColor whiteColor]
#define kColor_yellow    [UIColor yellowColor]
#define kColor_red       [UIColor redColor]
#define kColor_orange    [UIColor orangeColor]
#define kColor_purple    [UIColor purpleColor]
#define kColor_lightText [UIColor lightTextColor]
#define kColor_lightGray [UIColor lightGrayColor]
#define kColor_green     [UIColor greenColor]
#define kColor_gray      [UIColor grayColor]
#define kColor_magenta   [UIColor magentaColor]
#define kColor_groupTableViewBackground [UIColor groupTableViewBackgroundColor]


//字体
#define FONT(x) [UIFont systemFontOfSize:x]


//图片
#define IMAGE(x) [UIImage imageNamed:x]


//NSURL
#define URL(x) [NSURL URLWithString:x]


//获取类名
#define GET_CLASS_NAME(x) [NSString stringWithUTF8String:object_getClassName([x class])]


//强弱引用
#define WEAK_SELF __weak __typeof(self) weakSelf = self;
#define STRONG_SELF __strong __typeof(weakSelf) strongSelf = weakSelf;


//主window跟rootvc
#define KEYWINDOW [UIApplication sharedApplication].keyWindow
#define ROOTVC [UIApplication sharedApplication].keyWindow.rootViewController


//获取app名字
#define APPNAME [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"]


//String
#define kStringObject(object) [NSString stringWithFormat:@"%@",object]
#define kStringFormat(format,...) [NSString stringWithFormat:format, ##__VA_ARGS__]
#define kStringNum(num) [NSString stringWithFormat:@"%ld",num]
#define kStringInteger(integer) [NSString stringWithFormat:@"%zi",integer]
#define kStringFloat(float) [NSString stringWithFormat:@"%.2lf",float]


//线程
#define kMainThread_sync(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define kMainThread_async(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


//通知单利
#define kNotificationCenter [NSNotificationCenter defaultCenter]
#define kUserDefaults [NSUserDefaults standardUserDefaults]



#endif /* ToolMacros_h */
