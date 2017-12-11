//
//  ViewController.m
//  SendSandBoxFileDemo
//
//  Created by LHL on 17/2/18.
//  Copyright © 2017年 lihongli. All rights reserved.
//

#import "ViewController.h"
#import "FileListTableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)pushLogsVC:(id)sender {
    FileListTableViewController *fileListVC = [[FileListTableViewController alloc] init];
    
    [self.navigationController pushViewController:fileListVC animated:YES];
}

- (IBAction)presentVC:(id)sender {
    FileListTableViewController *fileListVC = [[FileListTableViewController alloc] init];

//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *documentPath = [paths firstObject];
//    fileListVC.directoryStr = documentPath;
//    fileListVC.defaultMail = @"aaa@gmail.com,bbb@gmail.com,ccc@gmail.com";

    [self presentViewController:fileListVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
