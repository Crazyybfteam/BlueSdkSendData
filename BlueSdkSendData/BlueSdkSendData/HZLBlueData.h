//
//  HZLBlueData.h
//  BlueSdkTest
//
//  Created by macro macro on 2017/3/9.
//  Copyright © 2017年 macro macro. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger,BLEDATATAYPE)
{
    BLEMIND     =   0,      //脑波数据类型
    BLEBLINKEYE,            //眨眼数据类型
    BLEGRAVITY,             //重力数据类型
    BLEBATTERY              //电池数据类型
};
@interface HZLBlueData : NSObject
@property   (nonatomic,readwrite)    int signal;//信号值  
@property   (nonatomic,readwrite)    int attention;//专注度
@property   (nonatomic,readwrite)    int meditation;//放松度
@property   (nonatomic,readwrite)    int blinkeye;//眨眼值
@property   (nonatomic,readwrite)    int xvlaue;//重力传感器X轴值
@property   (nonatomic,readwrite)    int yvlaue;//重力传感器Y轴值
@property   (nonatomic,readwrite)    int zvlaue;//重力传感器Z轴值
@property   (nonatomic,readwrite)    int batterycapacity;//电池电量百分比
@property   (nonatomic,assign)      BLEDATATAYPE  bledatataype;//蓝牙数据类型
@end
