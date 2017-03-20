//
//  ViewController.m
//  BlueSdkSendData
//
//  Created by macro macro on 2016/12/22.
//  Copyright © 2016年 macro macro. All rights reserved.
//

#import "ViewController.h"
#import "ConnectBlueManager.h"
#import "BrainData.h"
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
    isaccetable =   YES;
    // Do any additional setup after loading the view, typically from a nib.
    [ConnectBlueManager shareInstance].bluedataBlock   =   ^(uint8_t  *dat){
            printf("dec:%d %d %d %d %d %d %d %d\n", dat[0], dat[1],dat[2],dat[3],dat[4],dat[5],dat[6],dat[7]);
        if (isaccetable) {
            _logTextView.text  =   [_logTextView.text stringByAppendingString:[NSString stringWithFormat:@"%d %d %d %d %d %d %d %d\n", dat[0], dat[1],dat[2],dat[3],dat[4],dat[5],dat[6],dat[7]]];
            [_logTextView scrollRangeToVisible:NSMakeRange(_logTextView.text.length, 1)];
            self.logTextView.layoutManager.allowsNonContiguousLayout = YES;
        }
    };
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
        sender.selected =   YES;
        isaccetable =   NO;
        [sender setTitle:@"开始" forState:UIControlStateSelected];
    }else
    {
        sender.selected =   NO;
        isaccetable =   YES;
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
