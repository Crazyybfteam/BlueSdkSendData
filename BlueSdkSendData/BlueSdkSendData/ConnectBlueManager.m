//
//  ConnectBlueManager.m
//  ONEDAYAPP
//
//  Created by macro macro on 16/8/12.
//  Copyright © 2016年 macro macro. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ConnectBlueManager.h"

#define UUIDSTRING  @"6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
#define UUIDWRITESTRING @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
@interface ConnectBlueManager()<CBCentralManagerDelegate,CBPeripheralDelegate,CBPeripheralManagerDelegate >{
    BOOL    BL_DATA_Data_End_Mark;
    int           count;
     NSMutableArray *mutableArray;
    
}
@property(nonatomic,strong)    NSMutableArray *mutableString;
@property(nonatomic,strong)     BrainData   *brainData;
@end
@implementation ConnectBlueManager
@synthesize brainData;
+ (instancetype)shareInstance{
    static ConnectBlueManager   *connectBlueManager = NULL;
    static dispatch_once_t   onceToken;
    dispatch_once(&onceToken, ^{
        connectBlueManager  =   [[ConnectBlueManager alloc]init];
    });
    return connectBlueManager;
}

- (instancetype)init{
    self    =   [super init];
    if (self) {
        _manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        _cbReady = false;
        count   =   -1;
        mutableArray    =     [NSMutableArray array];
        _nDevices = [[NSMutableArray alloc]init];
        _nServices = [[NSMutableArray alloc]init];
        _nCharacteristics = [[NSMutableArray alloc]init];
        _mutableString  =   [NSMutableArray array];
        brainData   =   [[BrainData alloc]init];
    }
    return self;
}
- (void)scanBluooth{
    if (_manager.state==4) {
        [self init];
        return;
    }
        [_manager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
    double delayInSeconds = 60.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"扫描结束,没有扫描到设备");
    });
}


//开始查看服务，蓝牙开启
-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"正在扫描外设...");
            break;
        default:
            break;
    }
}

//查到外设后，停止扫描，连接设备
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    _peripheral = peripheral;
    NSLog(@"_peripheral.name=======%@",_peripheral.name);
    if (_peripheral.name!=nil)
    {
      
        if (![mutableArray containsObject:_peripheral.name])
        {
               [mutableArray addObject:_peripheral.name];
            BlueObject  *blueObject =   [[BlueObject alloc]init];
            blueObject.peripheralName   =   _peripheral.name;
            blueObject.peripheral   =   _peripheral;
            _bluenameBlock(blueObject);
        }
    }
}

- (void)connectPeripheral:(CBPeripheral*)peripheral
{
        _peripheral = peripheral;
        [self.manager stopScan];
        [_manager connectPeripheral:_peripheral options:nil];
}

//连接外设成功，开始发现服务
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    _blueconnctBlock(YES);
    [self.peripheral setDelegate:self];
    [self.peripheral discoverServices:nil];
}
//连接外设失败
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%@",error);
    _blueconnctBlock(NO);
}


-(void)peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"%s,%@",__PRETTY_FUNCTION__,peripheral);
    int rssi = abs([peripheral.RSSI intValue]);
    CGFloat ci = (rssi - 49) / (10 * 4.);
    NSString *length = [NSString stringWithFormat:@"发现BLT4.0热点:%@,距离:%.1fm",_peripheral,pow(10,ci)];
    NSLog(@"距离：%@",length);
}
//已发现服务
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    //    [self updateLog:@"发现服务."];
    int i=0;
    for (CBService *s in peripheral.services) {
        [self.nServices addObject:s];
    }
    for (CBService *s in peripheral.services) {
        i++;
        [peripheral discoverCharacteristics:nil forService:s];
    }
}

//已搜索到Characteristics
-(void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    for (CBCharacteristic *c in service.characteristics) {
        NSLog(@"c.UUID=======%@",c.UUID);
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]||[c.UUID isEqual:[CBUUID UUIDWithString:@"A5A9"]]||[c.UUID isEqual:[CBUUID UUIDWithString:UUIDSTRING]]) {
            [_peripheral setNotifyValue:YES forCharacteristic:c];
        }
        if ([c.UUID isEqual:[CBUUID UUIDWithString:@"FFF4"]]||[c.UUID isEqual:[CBUUID UUIDWithString:UUIDWRITESTRING]]) {
                 _writeCharacteristic = c;
        }
        [_nCharacteristics addObject:c];
    }
}


//获取外设发来的数据，不论是read和notify,获取数据都是从这个方法中读取。
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"2A19"]]) {
        NSString *value = [[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
        _batteryValue = [value floatValue];
        NSLog(@"电量%f",_batteryValue);
    }

    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:@"FFF2"]]||[characteristic.UUID isEqual:[CBUUID UUIDWithString:@"A5A9"]]||[characteristic.UUID isEqual:[CBUUID UUIDWithString:UUIDSTRING]]) {
        [self decodeBluthData:characteristic.value];
        
    }
    else
        NSLog(@"didUpdateValueForCharacteristic%@",[[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
}



//中心读取外设实时数据
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    // Notification has started
    if (characteristic.isNotifying)
    {
        [peripheral readValueForCharacteristic:characteristic];
        
    } else
    {
        // Notification has stopped
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        [self.manager cancelPeripheralConnection:self.peripheral];
    }
}
//用于检测中心向外设写数据是否成功
-(void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"=======%@",error.userInfo);
    }else{
        NSLog(@"发送数据成功");
    }
}

- (void)peripheralManagerDidUpdateState:(CBPeripheralManager *)peripheral{
    
    NSLog(@"periphera=========%ld",(long)peripheral.state);
}

- (void)peripheralDidUpdateName:(CBPeripheral *)peripheral{
     NSLog(@"CBperiphera=========%ld",(long)peripheral.state);
}

//写一个值
-(void)writeValue:(NSData*)byte{
//    NSData *data = [NSData dataWithBytes:&byte length:sizeof(byte)];
    if (_writeCharacteristic!=nil) {
        [_peripheral writeValue:byte forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    
}

- (void)disconnectPeripheral
{
    [_manager cancelPeripheralConnection:_peripheral];
}


 unsigned int data_num=0;
typedef struct{
    unsigned int Data_Len;
    unsigned int Data_buffer[50];
    unsigned int CRC16_H;
    unsigned int CRC16_L;
    unsigned int Data_End_Mark;
}bl_data;
bl_data BL_DATA;


#pragma mark ----蓝牙数据保存
- (void)bluoothDataHandler:(int)hexByte
{

    if (BL_DATA.Data_End_Mark==0) {
        switch (_frame_format) {
            case BL_FRAME_FIRST:
                if(hexByte==170)
                {
//                    BL_DATA.Data_buffer[data_num++] = hexByte;
//                    [_mutableString appendString:hexByte];
                    
                    count   ++;
                    if (count>=1) {
                        _frame_format = BL_DATA_LEN;
                        count   =   -1;
                    }
                    
                }
                break;
                
            case BL_DATA_LEN:

                data_num    =   hexByte;
                
                _frame_format = BL_DATA_REC;
                break;
                
            case BL_DATA_REC:
                 count++;
//                for ( int i =0 ; i<data_num; i++) {
                    if (count==data_num) {
//                        if ([self dataCheck:_mutableString]) {
                        
                            _frame_format = BL_FRAME_END;
                            [self decrypt:_mutableString];
                            [_mutableString removeAllObjects];
//                        }else
//                        {
//                            _frame_format = BL_FRAME_END;
//                            [_mutableString removeAllObjects];
//                        }
                        break;
                    }else{
                        [_mutableString addObject:[NSString stringWithFormat:@"%d",hexByte]];
                        break;
                    }
//                }

            break;
            case BL_FRAME_END:
                _frame_format = BL_FRAME_FIRST;
                BL_DATA.Data_End_Mark = 0;

                break;
            default:
                break;
        }
    }
 }

- (BOOL)dataCheck:(NSMutableArray*)array
{
    
    int sum =   0;
    for (int i= 0; i<array.count-1; i++) {
        sum +=   [array[i] intValue];
    }
    if ((sum^0xff)==[[array lastObject] intValue]) {
        return  YES;
    }else
    {
        return  NO;
    }
    
}

- (void)dealChange:(NSString*)string
{
    NSArray *stringArray    =   [string componentsSeparatedByString:@","];

    
}


/*************************************************************************
 * 描  述: 蓝牙串口处理函数
 * 输  入: 无
 * 输  出：无
 **************************************************************************/
#define SIGNAL     0XF1
#define ATTENTION  0XF2
#define MEDITATION 0XF3
#define BATTERY    0XF4



brain_data Brain_Data;
Data_Set    data_set;

unsigned int BL_SEND = 0;

#pragma mark ----校验处理
- (void)BL_Data_Handle
{
    unsigned int i=0;
    unsigned int len = 0;
    unsigned int data_len = 0;
    
    unsigned short int crc_16 = 0;
    unsigned short int Hi_crc16 = 0;
    unsigned short int Lo_crc16 = 0;
    
    if(BL_DATA.Data_End_Mark == 1)//数据接收完成
    {
        /********************CRC16校验**************************/
        crc_16 = GetCRC16(BL_DATA.Data_buffer, BL_DATA.Data_Len-2);
        Hi_crc16 = BL_DATA.Data_buffer[BL_DATA.Data_Len-2];
        Lo_crc16 = BL_DATA.Data_buffer[BL_DATA.Data_Len-1];
        
        if(BL_SEND==1)//算法设置发送完成
        {
            if(crc_16 == ((Hi_crc16 << 8) | Lo_crc16))//校验正确
            {
                if(BL_DATA.Data_buffer[4] == 1)//
                {
                    BL_SEND = 0;//下次直接接收脑波值
                    BL_DATA.Data_End_Mark = 0;//复位变量
               }
                else
                {
                    [self alogset:data_set];//再次发送算法设置
                }
            }
            else
            {
                [self alogset:data_set];//再次发送算法设置
            }
        }
        /********************数据接收回复************************/
        else
        {
            if(crc_16 == ((Hi_crc16 << 8) | Lo_crc16))
            {
                /********************处理数据****************************/
                data_len = BL_DATA.Data_Len-2;//减去校验长度后的数据总长
                i = 2;//从数据选项开始
                while(i < data_len)
                {
                    switch(BL_DATA.Data_buffer[i])
                    {
                        case SIGNAL:
                            len = BL_DATA.Data_buffer[i+1];
                            Brain_Data.Signal = BL_DATA.Data_buffer[i+2];
                            i+=len+2;
                            break;
                            
                        case ATTENTION:
                            len = BL_DATA.Data_buffer[i+1];
                            Brain_Data.Attention = BL_DATA.Data_buffer[i+2];
                            i+=len+2;
                            break;
                            
                        case MEDITATION:
                            len = BL_DATA.Data_buffer[i+1];
                            Brain_Data.Meditation = BL_DATA.Data_buffer[i+2];
                            i+=len+2;
                            break;
                            
                        case BATTERY:
                            len = BL_DATA.Data_buffer[i+1];
                            Brain_Data.battery = BL_DATA.Data_buffer[i+2];
                            i+=len+2;
                            break;
                            
                        default:
                            len = BL_DATA.Data_buffer[i+1];
                            i+=len+2;
                            break;
                    }
                }
            }
            else
            {
                memset(&BL_DATA, 0, sizeof(BL_DATA));
                BL_DATA.Data_End_Mark = 0;
                return;
            }
        }
        NSLog(@"Brain_Data=======%d_%d_%d_%d",Brain_Data.Attention,Brain_Data.battery,Brain_Data.Meditation,Brain_Data.Signal);
        if(_bluedataBlock){
//            _bluedataBlock(brainData);
        }
            
      //        [self saveData:Brain_Data];
        BL_DATA.Data_End_Mark = 0;           //串口继续接收
    }		
}










#pragma mark 解析蓝牙数据
- (void)decodeBluthData:(NSData*)bluethData{
    NSLog(@"%@",bluethData);
    Byte *testByte = (Byte *)[bluethData bytes];
    for(int i=0;i<[bluethData length];i++)
    {
        printf("testByte = %d\n",testByte[i]);
        NSString    *string =   [NSString stringWithFormat:@"%d",testByte[i]];
//        const char byte       =   testByte[i];
//        NSString    *byteString =   [NSString stringWithCString:&byte encoding:NSUnicodeStringEncoding];
//        NSLog(@"byteString========%@",byteString);
        [self bluoothDataHandler:testByte[i]];
    }
}

/*
	密钥！
 */
uint8_t keys[16]={
    0xaa,0xbb,0xcc,0xdd,0x1a,0x2b,0x3c,0x4d,
    0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88};


/*
	解密8字节（64位）数据，使用16字节的密钥（128位）。
 
 */
//void decrypt (uint32_t v[],ConnectBlueManager *selfclass) {
//    uint32_t v0=v[0], v1=v[1], sum=0xC6EF3720, i;  /* set up */
//    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
//    uint32_t *k=(uint32_t*)(keys);
//    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
//    for (i=0; i<32; i++) {                         /* basic cycle start */
//        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
//        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
//        sum -= delta;
//    }                                              /* end cycle */
//    v[0]=v0; v[1]=v1;
//    printf("v:%d %d %d %d %d %d %d %d\n", v[0], v[1],v[2],v[3],v[4],v[5],v[6],v[7]);
//    [selfclass blocktransData:v];
//}




- (void)decrypt:(NSArray *)darray
{
    uint8_t v[]        =  {[[darray objectAtIndex:0] intValue],[[darray objectAtIndex:1] intValue],[[darray objectAtIndex:2] intValue],[[darray objectAtIndex:3] intValue],[[darray objectAtIndex:4] intValue],[[darray objectAtIndex:5] intValue],[[darray objectAtIndex:6] intValue],[[darray objectAtIndex:7] intValue]};
         printf("v:%d %d %d %d %d %d %d %d\n", v[0], v[1],v[2],v[3],v[4],v[5],v[6],v[7]);
        decrypt((uint32_t *)v);
         NSLog(@"xx：%d,%d,%d,%d,%d,%d,%d,%d",v[0],v[1],v[2],v[3],v[4],v[5],v[6],v[7]);

//    decrypt(v, self);
//    for (int  i = 0;i<darray.count; i++)
//    {
//        int  a    =   [[darray objectAtIndex:i] intValue];
//         v[i]    =   a;
//        NSLog(@"a========%d",a);
//     }
//    uint32_t v0=    v[0],
//    
//    v1= v[1] ,
//    
//    sum=0xC6EF3720, i;  /* set up */
//    
//    uint32_t delta=0x9e3779b9;
//    /* a key schedule constant */
//    uint32_t *k=(uint32_t*)(keys);
//    
//    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
//    
//    for (i=0; i<32; i++) {                         /* basic cycle start */
//        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
//        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
//        sum -= delta;
//    }                                              /* end cycle */
//      v[0]=v0; v[1]=v1;
//
        _bluedataBlock(v);
}

/*
解密8字节（64位）数据，使用16字节的密钥（128位）。

*/
void decrypt (uint32_t v[]) {
    uint32_t v0=v[0], v1=v[1], sum=0xC6EF3720, i;  /* set up */
    uint32_t delta=0x9e3779b9;                     /* a key schedule constant */
    uint32_t *k=(uint32_t*)(keys);
    uint32_t k0=k[0], k1=k[1], k2=k[2], k3=k[3];   /* cache key */
    for (i=0; i<32; i++) {                         /* basic cycle start */
        v1 -= ((v0<<4) + k2) ^ (v0 + sum) ^ ((v0>>5) + k3);
        v0 -= ((v1<<4) + k0) ^ (v1 + sum) ^ ((v1>>5) + k1);
        sum -= delta;
    }                                              /* end cycle */
    v[0]=v0; v[1]=v1;
    
   
}


- (void)blocktransData:(uint32_t *)v
{
//    _bluedataBlock(v);
}


- (void)saveData:(brain_data)Brain_Data{
    NSDate *nowDate =[NSDate date];
//    NSString    *dateString =   [nowDate getFormateString];
//    [DBManager insertModel:<#(id)#> forTable:<#(DBManagerTable)#>]
}

#pragma mark -----算法设置
- (void)alogset:(Data_Set)dataset{
//    unsigned int crc16 = 0;
//    unsigned int crc16_Hi=0, crc16_Lo=0;
//    unsigned int reg[20]={0XAA, 0X00, 0XF0, 0x01, 0X00, 0XF1, 0x01, 0X00,
//                                             0XF2, 0x01, 0X00, 0XF3, 0x01, 0X00, 0XF4, 0x01, 0X00,
//                                              0XF5, 0x01, 0X00};
////    NSMutableString *endString  =   [NSMutableString string];
//    data_set    =   dataset;
//    [self writeValue:0xaa];//起始位
//    [self writeValue:0x14];//有效数据长度
//    reg[1] = 0x14;
//    
//    [self writeValue:0xf0];
//    [self writeValue:0x01];
//    [self writeValue:data_set.isStop];//1为接收数据，0为不接收数据
//    reg[4] = data_set.isStop;
//    
//    [self writeValue:0xf1];
//    [self writeValue:0x01];
//    [self writeValue:data_set.algo];//算法几
//    reg[7] = data_set.algo;
//    
//    [self writeValue:0xf2];
//    [self writeValue:0x01];
//    [self writeValue:data_set.times];//录像时长，单位秒
//    reg[10] = data_set.times;
//
//    
//    [self writeValue:0xf3];
//    [self writeValue:0x01];
//    [self writeValue:data_set.at];//开启录像的专注度阀值
//    reg[13] = data_set.at;
//    
//    [self writeValue:0xf4];
//    [self writeValue:0x01];
//    [self writeValue:data_set.increseond];//持续增加的秒数
//    reg[16] = data_set.increseond;
//    
//    [self writeValue:0xf5];
//    [self writeValue:0x01];
//    [self writeValue:data_set.mixvalue];//首尾数据的差值
//    reg[19] = data_set.mixvalue;
//
//    crc16 = GetCRC16(reg, 20);
//    crc16_Hi = (crc16>>8)&0xFF;
//    [self writeValue:crc16_Hi];
//    crc16_Lo = crc16&0xFF;
//    [self writeValue:crc16_Lo];
//    
//    [self writeValue:0x0d];
//    
//    BL_SEND = 1;
}
    
    
unsigned char const chCRCHTalbe[]={
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x00, 0xC1, 0x81, 0x40,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40, 0x01, 0xC0, 0x80, 0x41, 0x01, 0xC0, 0x80, 0x41,
    0x00, 0xC1, 0x81, 0x40};

unsigned char const chCRCLTalbe[] = {
    0x00, 0xC0, 0xC1, 0x01, 0xC3, 0x03, 0x02, 0xC2, 0xC6, 0x06, 0x07, 0xC7,
    0x05, 0xC5, 0xC4, 0x04, 0xCC, 0x0C, 0x0D, 0xCD, 0x0F, 0xCF, 0xCE, 0x0E,
    0x0A, 0xCA, 0xCB, 0x0B, 0xC9, 0x09, 0x08, 0xC8, 0xD8, 0x18, 0x19, 0xD9,
    0x1B, 0xDB, 0xDA, 0x1A, 0x1E, 0xDE, 0xDF, 0x1F, 0xDD, 0x1D, 0x1C, 0xDC,
    0x14, 0xD4, 0xD5, 0x15, 0xD7, 0x17, 0x16, 0xD6, 0xD2, 0x12, 0x13, 0xD3,
    0x11, 0xD1, 0xD0, 0x10, 0xF0, 0x30, 0x31, 0xF1, 0x33, 0xF3, 0xF2, 0x32,
    0x36, 0xF6, 0xF7, 0x37, 0xF5, 0x35, 0x34, 0xF4, 0x3C, 0xFC, 0xFD, 0x3D,
    0xFF, 0x3F, 0x3E, 0xFE, 0xFA, 0x3A, 0x3B, 0xFB, 0x39, 0xF9, 0xF8, 0x38,
    0x28, 0xE8, 0xE9, 0x29, 0xEB, 0x2B, 0x2A, 0xEA, 0xEE, 0x2E, 0x2F, 0xEF,
    0x2D, 0xED, 0xEC, 0x2C, 0xE4, 0x24, 0x25, 0xE5, 0x27, 0xE7, 0xE6, 0x26,
    0x22, 0xE2, 0xE3, 0x23, 0xE1, 0x21, 0x20, 0xE0, 0xA0, 0x60, 0x61, 0xA1,
    0x63, 0xA3, 0xA2, 0x62, 0x66, 0xA6, 0xA7, 0x67, 0xA5, 0x65, 0x64, 0xA4,
    0x6C, 0xAC, 0xAD, 0x6D, 0xAF, 0x6F, 0x6E, 0xAE, 0xAA, 0x6A, 0x6B, 0xAB,
    0x69, 0xA9, 0xA8, 0x68, 0x78, 0xB8, 0xB9, 0x79, 0xBB, 0x7B, 0x7A, 0xBA,
    0xBE, 0x7E, 0x7F, 0xBF, 0x7D, 0xBD, 0xBC, 0x7C, 0xB4, 0x74, 0x75, 0xB5,
    0x77, 0xB7, 0xB6, 0x76, 0x72, 0xB2, 0xB3, 0x73, 0xB1, 0x71, 0x70, 0xB0,
    0x50, 0x90, 0x91, 0x51, 0x93, 0x53, 0x52, 0x92, 0x96, 0x56, 0x57, 0x97,
    0x55, 0x95, 0x94, 0x54, 0x9C, 0x5C, 0x5D, 0x9D, 0x5F, 0x9F, 0x9E, 0x5E,
    0x5A, 0x9A, 0x9B, 0x5B, 0x99, 0x59, 0x58, 0x98, 0x88, 0x48, 0x49, 0x89,
    0x4B, 0x8B, 0x8A, 0x4A, 0x4E, 0x8E, 0x8F, 0x4F, 0x8D, 0x4D, 0x4C, 0x8C,
    0x44, 0x84, 0x85, 0x45, 0x87, 0x47, 0x46, 0x86, 0x82, 0x42, 0x43, 0x83,
    0x41, 0x81, 0x80, 0x40};
unsigned short int GetCRC16(unsigned int* pchMsg, unsigned int wDataLen)
{
    unsigned char chCRCHi = 0xFF; // 高CRC字节初始化
    unsigned char chCRCLo = 0xFF; // 低CRC字节初始化
    unsigned int wIndex;          // CRC循环中的索引
    
    while (wDataLen--)
    {
        // 计算CRC
        wIndex = chCRCLo ^ *pchMsg++;
        
        chCRCLo = chCRCHi ^ chCRCHTalbe[wIndex];
        chCRCHi = chCRCLTalbe[wIndex];
    }
    return ((chCRCHi << 8) | chCRCLo);
}


@end
