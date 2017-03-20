//
//  BrainData.h
//  ONEDAYAPP
//
//  Created by macro macro on 16/9/30.
//  Copyright © 2016年 macro macro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BrainData : NSObject
//unsigned int Signal;    //信号值
//unsigned int Attention; //专注度
//unsigned int Meditation;//放松度
//unsigned int battery;   //电池电量
@property(nonatomic,copy)NSString   *Signal;
@property(nonatomic,copy)NSString   *Attention;
@property(nonatomic,copy)NSString   *Meditation;
@property(nonatomic,copy)NSString   *battery;
@property(nonatomic,copy)NSString   *recordState;
@property(nonatomic,copy)NSString   *recordModel;
@property(nonatomic,copy)NSString   *recordTimes;
@property(nonatomic,copy)NSString   *recordOnOff;
@property(nonatomic,copy)NSString   *recordFrame;

@end
