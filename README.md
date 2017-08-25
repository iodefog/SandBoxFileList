# SendSandBoxFileDemo

遍历沙盒目录下文件，如果是非文件夹。
可以直接查看文本，可以使用airDrop发送到其他App，或者发送邮件

由于iOS 10 不能使用itools等工具导出沙盒里的文件，所以做了一个页面，利用邮件发送沙盒里的文件。对于程序的调试及文件的处理情况进行更好的了解。

# pod 
```
   pod 'SandBoxFileList', '~> 1.0.0'
   pod install
```

使用方法 
```objc
    FileListTableViewController *fileListVC = [[FileListTableViewController alloc] init];
    [self.navigationController pushViewController:fileListVC animated:YES];
```
或者
```objc
    FileListTableViewController *fileListVC = [[FileListTableViewController alloc] init];
    [self presentViewController:fileListVC animated:YES completion:nil];
```

效果图

![image](./SnapImage/IMG_2389.PNG)
