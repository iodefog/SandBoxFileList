//
//  FileListTableViewController.m
//  Utility
//
//  Created by LHL on 16/12/26.
//
//

#import "FileListTableViewController.h"
#import <MessageUI/MessageUI.h>

#define HLNavigationBarHeight (self.navigationController ? 0 :64)

@interface FileListTableViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) NSMutableArray    *fileList;
@property (nonatomic, strong) UIView            *headerView;
/**
 *  文件目录路径
 */
@property (nonatomic, strong) NSString *directoryStr;

@end

@implementation FileListTableViewController

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"FileTableViewCell"];
    
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryStr?:NSHomeDirectory() error:nil];
    // 进行倒叙排列
    NSEnumerator *enumerator = [fileList reverseObjectEnumerator];
    self.fileList = [NSMutableArray arrayWithArray:(NSMutableArray*)[enumerator allObjects]];

    UINavigationItem *navigationItem = self.navigationItem;
    if (![self.navigationController isKindOfClass:[UINavigationController class]]) {
        UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@""];
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HLNavigationBarHeight)];
        [navigationBar pushNavigationItem:navigationItem animated:NO];
        
        UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithTitle:@"🔙返回" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        navigationItem.leftBarButtonItem = backBarItem;
        
        self.headerView = navigationBar;
        [self.view addSubview:navigationBar];
    }
    navigationItem.title = [self.directoryStr lastPathComponent] ?:@"文件目录";
    UIBarButtonItem *remveBarItem = [[UIBarButtonItem alloc] initWithTitle:@"删除所有" style:UIBarButtonItemStylePlain target:self action:@selector(removeAllFiles)];
    navigationItem.rightBarButtonItem = remveBarItem;
}

- (NSString *)getSendBoxPath:(NSString *)path{
    NSString *directoryStr = nil;
    if (!self.directoryStr) {
      directoryStr = self.directoryStr = NSHomeDirectory();
    }
    if (path) {
        directoryStr = [NSString stringWithFormat:@"%@/%@",self.directoryStr, path];
    }
    return directoryStr;
}

- (void)sendMail:(NSString *)fileName{
    if (![MFMailComposeViewController canSendMail]) {
        [self launchMailAppOnDevice:fileName];
        return;
    }
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    //设置主题
    [mailPicker setSubject: @"Sandbox目录文件"];
    // 添加发送者
    NSArray *toRecipients = [NSArray arrayWithObject: @"test@mail.com"];
    //NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    [mailPicker setToRecipients: toRecipients];
//    // 添加图片
//    UIImage *addPic = [UIImage imageNamed: @"123.jpg"];
//    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
//    // NSData *imageData = UIImageJPEGRepresentation(addPic, 1);    // jpeg
//    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"123.jpg"];
    
//    NSString *emailBody = @"eMail 正文";
//    [mailPicker setMessageBody:emailBody isHTML:YES];
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.directoryStr, fileName];
    NSData *data = [NSData dataWithContentsOfFile:path];
    [mailPicker addAttachmentData:data mimeType:@"text/plain" fileName:fileName];
    [self presentViewController:mailPicker animated:YES completion:nil];
}

/**
 *  发送成功与失败回调
 *
 *  @param controller <#controller description#>
 *  @param result     <#result description#>
 *  @param error      <#error description#>
 */
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    [self back];
}

- (void)launchMailAppOnDevice:(NSString *)fileName{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.directoryStr, fileName];
    NSString *urlString = [NSString stringWithFormat:
                           @"mailto:"
                           "test@mail.com,"
                           "?subject=%@"
                           "&body=%@"
                           ,
                           @"Sandbox目录文件",
                           [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]];
                           
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}

/**
 * 返回
 */
- (void)back{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/**
 * 移除某一个File
 **/
- (BOOL)removeOneFileForFileName:(NSString *)fileName{
    BOOL success = YES;
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.directoryStr, fileName];
    NSError *error = nil;
    if (![[NSFileManager defaultManager] removeItemAtPath:filePath error:&error]){
        NSLog(@"删除本地文件不成功");
       UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"删除文件失败 %@", error] message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alerView show];
        success = NO;
    }
    return success;
}

/**
 * 移除所有文件
 **/
- (void)removeAllFiles{
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryStr?:NSHomeDirectory() error:nil];

    for (NSString *fileName in fileList) {
        [self removeOneFileForFileName:fileName];
    }
    [self.fileList removeAllObjects];
    [self.tableView reloadData];
    
//    NSError *error = nil;
//    if (![[NSFileManager defaultManager] removeItemAtPath:self.directoryStr error:&error]){
//        NSLog(@"删除所有文件不成功");
//        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"删除文件失败 %@", error] message:nil delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
//        [alerView show];
//    }else{
//        [self.fileList removeAllObjects];
//        [self.tableView reloadData];
//    }
}

- (BOOL)recognizeSimultaneouslyWithGestureRecognizer{
    return NO;
}

- (BOOL)panGestureEnable{
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HLNavigationBarHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileTableViewCell" forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.text = self.fileList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *filePath = [self getSendBoxPath:self.fileList[indexPath.row]];
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        if (isDirectory) {
            FileListTableViewController *fileListVC = [[FileListTableViewController alloc] init];
            fileListVC.directoryStr = filePath;
            if (self.navigationController) {
                [self.navigationController pushViewController:fileListVC animated:YES];
            }else {
                [self presentViewController:fileListVC animated:YES completion:nil];
            }
        }else {
            [self sendMail:self.fileList[indexPath.row]];
        }
    }
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if ([self removeOneFileForFileName:self.fileList[indexPath.row]]) {
            [self.fileList removeObjectAtIndex:(indexPath.row)];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

@end
