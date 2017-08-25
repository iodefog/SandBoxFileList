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

@interface LogsReadWebViewController : UIViewController

@property (nonatomic, strong) NSString *url;

- (instancetype)initWithUrl:(NSString *)url;

@end

@implementation LogsReadWebViewController

- (instancetype)initWithUrl:(NSString *)url{
    if (self = [super init]) {
        self.url = url;
    }
    return self;
}

#ifdef DEBUG
- (void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64)];
    UINavigationItem *navigationItem = [[UINavigationItem alloc] initWithTitle:@"查看日志"];
    navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(back)];
    [navigationBar pushNavigationItem:navigationItem animated:YES];
    [self.view addSubview:navigationBar];
    
    if (self.url) {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(navigationBar.bounds), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)- CGRectGetHeight(navigationBar.bounds))];
        [self.view addSubview:webView];
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:self.url]]];
    }
}

- (void)back{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#endif

@end

#pragma mark - LogsListTableViewController

@interface FileListTableViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) UIDocumentInteractionController *documentController;
@property (nonatomic, strong) NSMutableArray    *fileList;
@property (nonatomic, strong) UIView            *headerView;
@property (nonatomic, strong) UINavigationItem  *ttNavigationItem;


@end

@implementation FileListTableViewController

//遍历文件夹获得文件夹大小
+ (NSString *) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return [self humanReadableStringFromBytes:folderSize];
}

//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

//计算文件大小
+ (NSString *)humanReadableStringFromBytes:(unsigned long long)byteCount
{
    float numberOfBytes = byteCount;
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB",@"EB",@"ZB",@"YB",nil];
    
    while (numberOfBytes > 1024) {
        numberOfBytes /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",numberOfBytes, [tokens objectAtIndex:multiplyFactor]];
}

#pragma mark --

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    NSArray *fileList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.directoryStr?:NSHomeDirectory() error:nil];
    // 进行倒叙排列
    NSEnumerator *enumerator = [fileList reverseObjectEnumerator];
    self.fileList = [NSMutableArray arrayWithArray:(NSMutableArray*)[enumerator allObjects]];

    UINavigationItem *navigationItem = self.navigationItem;
    if (![self.navigationController isKindOfClass:[UINavigationController class]]) {
        UINavigationItem *customNavigationItem = [[UINavigationItem alloc] initWithTitle:@""];
        UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HLNavigationBarHeight)];
        [navigationBar pushNavigationItem:customNavigationItem animated:NO];
        
        navigationItem = customNavigationItem;
        self.headerView = navigationBar;
        [self.view addSubview:navigationBar];
    }
    navigationItem.title = self.title?:@"/";
    
    if (!self.navigationController) {
        UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(back)];
        navigationItem.leftBarButtonItem = backBarItem;
    }
    
    UIBarButtonItem *remveBarItem = [[UIBarButtonItem alloc] initWithTitle:@"Cleared" style:UIBarButtonItemStylePlain target:self action:@selector(removeAllFiles)];
    navigationItem.rightBarButtonItem = remveBarItem;
    
    [[UIBarButtonItem appearance]setBackButtonTitlePositionAdjustment:UIOffsetMake(NSIntegerMin, NSIntegerMin) forBarMetrics:UIBarMetricsDefault];

    self.ttNavigationItem = navigationItem;
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
    NSArray *toRecipients = nil;
    //    [NSArray arrayWithObject: @""];
    //NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
    [mailPicker setToRecipients: toRecipients];
    //    // 添加图片
    //    UIImage *addPic = [UIImage imageNamedForVideo: @"123.jpg"];
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)launchMailAppOnDevice:(NSString *)fileName{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.directoryStr, fileName];
    NSString *urlString = [NSString stringWithFormat:
                           @"mailto:"
                           ""
                           "?subject=%@"
                           "&body=%@"
                           ,
                           @"Sandbox目录文件",
                           [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil]];
                           
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}

/***
 * 显示AirDrop 发送文件
 */

- (void)showDocumentFileName:(NSString *)fileName{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.directoryStr, fileName];
    
    if (!self.documentController) {
        self.documentController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
    }
    //    self.documentController.delegate = self;
    [self.documentController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
    
}


/***
 * 直接读 文件
 */
- (void)readLogsFileName:(NSString *)fileName{
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.directoryStr, fileName];
    
    LogsReadWebViewController *webVC = [[LogsReadWebViewController alloc] init];
    webVC.url = path;
    if (self.presentingViewController) {
        [self presentViewController:webVC animated:YES completion:nil];
    }
    else {
        [self.navigationController pushViewController:webVC animated:YES];
    }
}


/**
 * 返回
 */
- (void)back{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
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
}

- (void)operationFileName:(NSString *)fileName{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"日志文件处理" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *mailAction = [UIAlertAction actionWithTitle:@"邮件发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self sendMail:fileName];
    }];
    
    UIAlertAction *airDropAction = [UIAlertAction actionWithTitle:@"AirDrop发送" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self showDocumentFileName:fileName];
    }];
    
    UIAlertAction *readAction = [UIAlertAction actionWithTitle:@"直接阅读" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self readLogsFileName:fileName];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertController addAction:mailAction];
    [alertController addAction:airDropAction];
    [alertController addAction:readAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
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
    if (self.fileList.count == 0) {
        self.ttNavigationItem.rightBarButtonItem = nil;
    }
    return self.fileList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return self.headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HLNavigationBarHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileTableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"FileTableViewCell"];
    }
    
    cell.textLabel.numberOfLines = 3;
    cell.textLabel.text = self.fileList[indexPath.row];
    BOOL isDirectory = NO;
    [[NSFileManager defaultManager] fileExistsAtPath:[self getSendBoxPath:cell.textLabel.text] isDirectory:&isDirectory];
    if (isDirectory) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *str = [[self class] folderSizeAtPath:[self getSendBoxPath:cell.textLabel.text]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.detailTextLabel.text = str;
            });
        });
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *str = [[self class] humanReadableStringFromBytes: [[self class] fileSizeAtPath:[self getSendBoxPath:cell.textLabel.text]]];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.detailTextLabel.text = str;
            });
        });
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *filePath = [self getSendBoxPath:self.fileList[indexPath.row]];
    BOOL isDirectory = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory]) {
        if (isDirectory) {
            FileListTableViewController *fileListVC = [[FileListTableViewController alloc] init];
            fileListVC.directoryStr = filePath;
            fileListVC.title = [NSString stringWithFormat:@"/%@",[filePath lastPathComponent]];
            if (self.navigationController) {
                [self.navigationController pushViewController:fileListVC animated:YES];
            }else {
                [self presentViewController:fileListVC animated:YES completion:nil];
            }
        }else {
            [self operationFileName:self.fileList[indexPath.row]];
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
