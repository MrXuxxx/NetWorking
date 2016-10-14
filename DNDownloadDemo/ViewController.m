//
//  ViewController.m
//  DNDownloadDemo
//
//  Created by Admin on 16/10/13.
//  Copyright © 2016年 Xudong. All rights reserved.
//

#import "ViewController.h"
#import "ZSBreakPointDownload.h"
@interface ViewController ()
{
    NSArray *_downloadUrls;
}
@property (weak, nonatomic) IBOutlet UISlider *firstSlider;
@property (weak, nonatomic) IBOutlet UISlider *secondSlider;
@end

@implementation ViewController

#pragma 接收下载通知,获取下载状态

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDownloadFileSize:)
                                                 name:zsDownloadFileSize
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDownloadDownloadSize:)
                                                 name:zsDownloadSize
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDownloadFinished:)
                                                 name:zsDownloadSuccess
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationDownloadFailure:)
                                                 name:zsDownloadFailure
                                               object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(notificationDownloadSuspend:)
                                                name:zsDownloadSuspend
                                              object:nil];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:zsDownloadFileSize
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:zsDownloadSize
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:zsDownloadSuccess
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:zsDownloadFailure
                                                  object:nil];
}
#pragma 创建监听方法
- (void)notificationDownloadSuspend:(NSNotification *)notification
{
    NSLog(@"suspendNotification = %@",notification);
}
- (void)notificationDownloadFileSize:(NSNotification *)notification
{
    NSLog(@"fileSizeNotification = %@",notification);
    
}
- (void)notificationDownloadDownloadSize:(NSNotification *)notification
{
    NSLog(@"downloadSizeNotification = %f",(([notification.userInfo[@"receivedSize"] floatValue]/(1024.00*1024))/([notification.userInfo[@"totalBytesExpectedToWrite"] floatValue]/(1024.00*1024))));
       NSString *tag = [ZSUserDefaultsStandar objectForKey:[NSString stringWithFormat:@"%ld",[notification.userInfo[@"dataTask"] taskIdentifier]]];
    
    if ([tag integerValue] == 101)
    {
       _firstSlider.value = (([notification.userInfo[@"receivedSize"] floatValue]/(1024.00*1024))/([notification.userInfo[@"totalBytesExpectedToWrite"] floatValue]/(1024.00*1024)));
        
    }
    else
    {
        _secondSlider.value = (([notification.userInfo[@"receivedSize"] floatValue]/(1024.00*1024))/([notification.userInfo[@"totalBytesExpectedToWrite"] floatValue]/(1024.00*1024)));
    }
}
- (void)notificationDownloadFinished:(NSNotification *)notification
{
    NSLog(@"finishedNotification = %@",notification);
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",ZSCachesDirectory,[notification.userInfo[@"downloadTask"] response].suggestedFilename];
    NSFileManager *mgr = [NSFileManager defaultManager];
    //回到主线程
    [mgr moveItemAtPath:notification.userInfo[@"downloadPath"]
                 toPath:fileName
                  error:nil];
    NSString *tag = [ZSUserDefaultsStandar objectForKey:[NSString stringWithFormat:@"%ld",[notification.userInfo[@"downloadTask"] taskIdentifier]]];
    UIButton *btn = [self.view viewWithTag:[tag integerValue]];
    [btn setTitle:@"完成" forState:UIControlStateNormal];
    btn.userInteractionEnabled = NO;

}
- (void)notificationDownloadFailure:(NSNotification *)notification
{
    NSLog(@"failureNotification = %@",notification);
    
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 赋值下载路径
    _downloadUrls = @[@"http://120.25.226.186:32812/resources/videos/minion_01.mp4",@"http://pic6.nipic.com/20100330/4592428_113348097000_2.jpg"];
}
- (IBAction)beginDownload:(id)sender
{
    UIButton *button = sender;
    if ([button.titleLabel.text isEqualToString:@"下载"])
    {
        /* 两个参数，第一个参数是url地址，
           第二个是给这个请求注册一个key值，
           方便之后选取做其他功能
         **/
        [[ZSBreakPointDownload sharedManager] beginDownloadTask:_downloadUrls[(button.tag - 101)]
                                                        keyname:[NSString stringWithFormat:@"%ld",(long)button.tag]];
        [button setTitle:@"暂停" forState:UIControlStateNormal];
    }
   else if([button.titleLabel.text isEqualToString:@"暂停"])
   {
       [[ZSBreakPointDownload sharedManager] resuspendOrBegin:[NSString stringWithFormat:@"%ld",(long)button.tag]];
        [button setTitle:@"继续下载" forState:UIControlStateNormal];
   }
   else if([button.titleLabel.text isEqualToString:@"继续下载"])
   {
       [[ZSBreakPointDownload sharedManager] resuspendOrBegin:[NSString stringWithFormat:@"%ld",(long)button.tag]];
       [button setTitle:@"暂停" forState:UIControlStateNormal];
   }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
