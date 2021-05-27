//
//  ZGTopicsTableViewController.m
//  ZegoExpressAudioExample-iOS-OC
//
//  Created by zego on 2020/5/25.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGTopicsTableViewController.h"

@interface ZGTopicsTableViewController ()

@end

@implementation ZGTopicsTableViewController{
    NSArray<NSArray<NSString*>*>* _topicList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    NSMutableArray *basicTopicList = [NSMutableArray array];
    NSMutableArray *advanceTopicList = [NSMutableArray array];
    NSArray *topicList = @[basicTopicList, advanceTopicList];
    
    [basicTopicList addObject:@"QuickStart"];
     
    [advanceTopicList addObject:@"SoundLevel"];
    
    _topicList = topicList;

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Tips" style:UIBarButtonItemStylePlain target:self action:@selector(showTips)];
}

- (void)jumpToWeb:(NSString *)url {
    NSURL *targetURL = [NSURL URLWithString:url];
    if(targetURL && [[UIApplication sharedApplication] canOpenURL:targetURL]){
        [[UIApplication sharedApplication] openURL:targetURL];
    }
}

- (IBAction)onOpenDocWeb:(UIButton *)sender {
    [self jumpToWeb:@"https://doc-en.zego.im/en/1111.html"];
}

- (IBAction)onOpenDownloadCode:(UIButton *)sender {
    [self jumpToWeb:@"https://github.com/zegoim/zego-express-example-topics-ios-oc"];
}

- (IBAction)onOpenFAQ:(UIButton *)sender {
    [self jumpToWeb:@"https://doc-zh.zego.im/zh/1996.html"];
}

- (void)showTips {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Tips" message:@"Since the Express Audio SDK is based on the Video SDK (just cuts the video function), all APIs of the two SDKs are basically the same. \n\nFor more SDK functional demonstrations, please refer to Video demo." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Jump" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpToWeb:@"https://github.com/zegoim/zego-express-example-topics-ios-oc/tree/master/video"];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _topicList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _topicList[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"ZGTopicCell"];
    NSString *topicName = _topicList[indexPath.section][indexPath.row];
    [cell.textLabel setText:topicName];
    return cell;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSString *title = @"";
    switch (section) {
        case 0:
            title = @"Basic Module";
            break;
        case 1:
            title = @"Advance Module";
        default:
            break;
    }
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section >= _topicList.count || indexPath.row >= _topicList[indexPath.section].count){
        return;
    }
    
    NSString *topicName = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    UIViewController* vc = nil;
    
    if([topicName isEqualToString:@"QuickStart"]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"QuickStart" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if([topicName isEqualToString:@"PublishStream"]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"PublishStream" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if([topicName isEqualToString:@"PlayStream"]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"PlayStream" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if([topicName isEqualToString:@"SoundLevel"]){
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"SoundLevel" bundle:nil];
        vc = [sb instantiateInitialViewController];
    }
    
    if(vc){
        [self.navigationController pushViewController:vc animated:YES];
    }
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
