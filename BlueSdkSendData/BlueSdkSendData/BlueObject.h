//
//  BlueObject.h
//  BlueSdkSendData
//
//  Created by macro macro on 2016/12/26.
//  Copyright © 2016年 macro macro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface BlueObject : NSObject
@property (nonatomic, strong) CBPeripheral *peripheral;
@property  (nonatomic,strong)  NSString *peripheralName;
@end
