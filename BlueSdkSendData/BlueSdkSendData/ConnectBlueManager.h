//
//  ConnectBlueManager.h
//  ONEDAYAPP
//
//  Created by macro macro on 16/8/12.
//  Copyright © 2016年 macro macro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BrainData.h"
#import "BlueObject.h"
typedef struct{
    unsigned int Signal;    //信号值
    unsigned int Attention; //专注度
    unsigned int Meditation;//放松度
    unsigned int battery;   //电池电量
}brain_data;

typedef struct{
    Byte isStop;    //是否停止
    Byte algo;    //算法几
    Byte  times;//录像时长
    Byte at;   //开启录像的专注度阀值
    Byte increseond;   //持续增加的秒数
    Byte mixvalue;  //首尾数据的差值
}Data_Set;

typedef void(^BlueDataBlock)(uint8_t *brainData);

typedef void(^BlueNameBlock)(BlueObject *blueObject);

typedef void(^BlueConnectSuccess)(BOOL ConnectState);
typedef NS_ENUM(NSUInteger, FRAME_FORMAT) {
    BL_FRAME_FIRST = 0,
    BL_DATA_LEN,
    BL_DATA_REC,
    BL_FRAME_END
};
@interface ConnectBlueManager : NSObject
@property BOOL cbReady;
@property BOOL isRefreshing;
@property(nonatomic) float batteryValue;
@property (nonatomic, strong) CBCentralManager *manager;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (strong ,nonatomic) CBCharacteristic *writeCharacteristic;
@property (strong,nonatomic) NSMutableArray *nDevices;
@property (strong,nonatomic) NSMutableArray *nServices;
@property (strong,nonatomic) NSMutableArray *nCharacteristics;
@property (readonly)FRAME_FORMAT    frame_format;
@property (nonatomic,copy)BlueDataBlock bluedataBlock;
@property  (nonatomic,copy)BlueNameBlock    bluenameBlock;
@property   (nonatomic,copy)BlueConnectSuccess  blueconnctBlock;
+ (instancetype)shareInstance;

- (void)scanBluooth;

-(void)writeValue:(NSData*)byte;

- (void)alogset:(Data_Set)dataset;

- (void)connectPeripheral:(CBPeripheral*)peripheral;


- (void)disconnectPeripheral;
@end

