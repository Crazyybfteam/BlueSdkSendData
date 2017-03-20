//
//  BlueTableViewController.m
//  BlueSdkSendData
//
//  Created by macro macro on 2016/12/26.
//  Copyright © 2016年 macro macro. All rights reserved.
//

#import "BlueTableViewController.h"
#import "ConnectBlueManager.h"
#import "ViewController.h"
#import "SVProgressHUD.h"
#define DECLARE_WEAK_SELF __typeof(&*self) __weak weakSelf = self
@interface BlueTableViewController ()
{
    ConnectBlueManager  *connectBlueManager ;
}
@property   (nonatomic,strong)NSMutableArray *bluearray;

@end

@implementation BlueTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    DECLARE_WEAK_SELF;
    connectBlueManager =   [ConnectBlueManager shareInstance];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [connectBlueManager scanBluooth];
    });
    _bluearray  =   [NSMutableArray array];
    [connectBlueManager setBluenameBlock:^(BlueObject *blueObject){
        
        [weakSelf.bluearray addObject:blueObject];
        [weakSelf.tableView reloadData];
    }];
    [connectBlueManager setBlueconnctBlock:^(BOOL connectstate){
        if (connectstate) {
            [SVProgressHUD dismiss];
            UIStoryboard *storyboard    =   [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            ViewController  *viewController =   [storyboard instantiateViewControllerWithIdentifier:@"viewController"];
            [weakSelf.navigationController pushViewController:viewController animated:YES];
        }{
            [SVProgressHUD showErrorWithStatus:@"连接蓝牙未成功"];
        }
    }];
}

- (IBAction)searchAction:(id)sender {
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (!connectBlueManager.manager.isScanning) {
              [connectBlueManager scanBluooth];
        }
    });
    
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return _bluearray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"bluecell"   forIndexPath:indexPath];
    
    // Configure the cell...
    BlueObject  *blueobject =   [_bluearray objectAtIndex:indexPath.row];
    cell.textLabel.text  =   blueobject.peripheralName;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
       BlueObject  *blueobject =   [_bluearray objectAtIndex:indexPath.row];
    [SVProgressHUD showWithStatus:@"连接蓝牙中"];
    [[ConnectBlueManager shareInstance] connectPeripheral:blueobject.peripheral];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
