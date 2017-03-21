//
//  ViewController.m
//  BlueSdkSendData
//
//  Created by macro macro on 2016/12/22.
//  Copyright © 2016年 macro macro. All rights reserved.
//

#import "ViewController.h"
#import "ConnectBlueManager.h"

#import "HZLBlueData.h"
@interface ViewController ()
{
    BOOL    isaccetable;
}

@property (weak, nonatomic) IBOutlet UILabel *logLabel;
@property (weak, nonatomic) IBOutlet UITextView *logTextView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    ConnectBlueManager  *connectBlueManager =   [ConnectBlueManager shareInstance];
    
    //连接蓝牙成功回调
    connectBlueManager.blueconnctBlock  =   ^(BOOL isconnet)
    {
        if (isconnet)
        {
            isaccetable =   YES;
            NSLog(@"连接蓝牙成功");
        }else
        {
            NSLog(@"没有连接到蓝牙");
        }
    };

    // Do any additional setup after loading the view, typically from a nib.
    
    connectBlueManager.hzlblueDataBlock =   ^(HZLBlueData   *hzlBlueData)
    {
        if (hzlBlueData.bledatataype==BLEMIND) {
            
        }
//        if (isaccetable) {
            _logTextView.text  =   [_logTextView.text stringByAppendingString:[NSString stringWithFormat:@"hzlBlueData:signal=%d:at=%d:me=%d:bli=%d:X=%d:Y=%d:Z=%d:bat=%d\n",hzlBlueData.signal,hzlBlueData.attention,hzlBlueData.meditation,hzlBlueData.blinkeye,hzlBlueData.xvlaue,hzlBlueData.yvlaue,hzlBlueData.zvlaue,hzlBlueData.batterycapacity]];
            [_logTextView scrollRangeToVisible:NSMakeRange(_logTextView.text.length, 1)];
            self.logTextView.layoutManager.allowsNonContiguousLayout = YES;
//        }

        NSLog(@"hzlBlueData:signal==%d:==%d:==%d:==%d:==%d:==%d:==%d:==%d",hzlBlueData.signal,hzlBlueData.attention,hzlBlueData.meditation,hzlBlueData.blinkeye,hzlBlueData.xvlaue,hzlBlueData.yvlaue,hzlBlueData.zvlaue,hzlBlueData.batterycapacity);
        
    };
//    [ConnectBlueManager shareInstance].bluedataBlock   =   ^(uint8_t  *dat){
//            printf("dec:%d %d %d %d %d %d %d %d\n", dat[0], dat[1],dat[2],dat[3],dat[4],dat[5],dat[6],dat[7]);
       //    };
}
- (IBAction)sendAction:(UITextField *)sender {
    [sender becomeFirstResponder];
//    NSString
    NSData* data = [sender.text dataUsingEncoding:NSUTF8StringEncoding];
    [[ConnectBlueManager shareInstance] writeValue:data];
}
- (IBAction)clearAction:(id)sender {
    
    _logTextView.text   =   @"";
    [_logTextView scrollRangeToVisible:NSMakeRange(_logTextView.text.length, 1)];
    self.logTextView.layoutManager.allowsNonContiguousLayout = YES;
}
- (IBAction)pauseActiopn:(UIButton *)sender {
    
    if (!sender.selected) {
        if (isaccetable ==YES) {
            sender.selected =   YES;
            [[ConnectBlueManager shareInstance] disconnectPeripheral];
            [sender setTitle:@"开始" forState:UIControlStateSelected];
        }
        else{
        
        
        
        }
       
    }else
    {
        sender.selected =   NO;
        [[ConnectBlueManager shareInstance] scanBluooth];
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
    }
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [_logTextView resignFirstResponder];
        [self.view endEditing:YES];  
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[ConnectBlueManager shareInstance] disconnectPeripheral];
}
@end
