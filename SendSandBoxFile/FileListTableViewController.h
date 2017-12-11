//
//  FileListTableViewController.h
//  Utility
//
//  Created by LHL on 16/12/26.
//
//

#import <UIKit/UIKit.h>

/**   遍历沙盒目录下文件，如果是非文件夹。则发送邮件
 *    使用方法 preset or push
 */

@interface FileListTableViewController : UITableViewController

/**
 *  文件目录起始路径，默认为root
 */
@property (nonatomic, strong) NSString *directoryStr;

/**
 *  默认邮箱地址，或者字符串。例如 xxx@mail.com, 多个请用"AAA@gmail.com,BBB@gmail.com,CCC@gmail.com"
 */
@property (nonatomic, strong) NSString *defaultMail;


@end
