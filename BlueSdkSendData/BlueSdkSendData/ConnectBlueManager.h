//
//  ConnectBlueManager.h
//  ONEDAYAPP
//
//  Created by macro macro on 16/8/12.
//  Copyright © 2016年 macro macro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//
//#import "BlueObject.h"
#import "HZLBlueData.h"



//// 5.上面所有数据
typedef void(^HZLBLUEDataBlock)(HZLBlueData *hzlblueData);

typedef void(^BlueConnectSuccess)(BOOL ConnectState);

@interface ConnectBlueManager : NSObject

//蓝牙接收数据成功的回调
@property   (nonatomic,copy)HZLBLUEDataBlock    hzlblueDataBlock;
//蓝牙连接是否成功的回调
@property   (nonatomic,copy)BlueConnectSuccess  blueconnctBlock;

//扫描一次60s,60s后没扫到是否需要一直扫描,默认为YES代表一直扫描
@property   (nonatomic,assign)BOOL      alwaysScan;

//初始化
+ (instancetype)shareInstance;
//扫描周边蓝牙
- (void)scanBluooth;
//向蓝牙写数据
- (void)writeValue:(NSData*)byte;
//断开蓝牙外设的连接
- (void)disconnectPeripheral;

@end

