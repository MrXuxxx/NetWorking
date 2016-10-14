//
//  ZSBreakPointDownload.m
//  TestBreakPointDownload
//
//  Created by XD on 16/5/24.
//  Copyright © 2016年 Zhishang,Inc. All rights reserved.
//

#import "ZSBreakPointDownload.h"
#import "AppDelegate.h"
// 缓存主目录
// 文件的存放路径（caches）
#define ZSFileFullpath(name) [ZSCachesDirectory stringByAppendingPathComponent:name]
#define TaskCacheSet   @"taskCacheSet"

NSString  *zsDownloadSuccess       = @"zsDownloadSuccess";
NSString  *zsDownloadFileSize      = @"zsDownloadFileSize";
NSString  *zsDownloadSize          = @"zsDownloadSize";
NSString  *zsDownloadFailure       = @"zsDownloadFailure";
NSString  *zsDownloadWaiting       = @"zsDownloadWaiting";
NSString  *zsDownloadEnterDownload = @"zsDownloadEnterDownload";
NSString  *zsDownloadSuspend       = @"zsDownloadSuspend";
@interface ZSBreakPointDownload()<NSURLSessionDelegate>
@property (nonatomic, strong)NSURLSession           *zsSession;
@property (nonatomic, strong)NSMutableDictionary    *taskDic;
@property (nonatomic, strong)NSMutableSet           *taskSet;
@end

@implementation ZSBreakPointDownload
+ (ZSBreakPointDownload *)sharedManager
{
    static ZSBreakPointDownload *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        
    });
    return sharedAccountManagerInstance;
}
- (NSURLSession *)backgroundSession {
    static NSURLSession *backgroundSess = nil;
    static dispatch_once_t onceToken;
    NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];

    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        config.HTTPMaximumConnectionsPerHost = 3;
        backgroundSess = [NSURLSession sessionWithConfiguration:config
                                                       delegate:self
                                                  delegateQueue:[NSOperationQueue mainQueue]];
        backgroundSess.sessionDescription = identifier;
    });
    
    return backgroundSess;
}
- (NSMutableDictionary *)taskDic
{
    if (!_taskDic)
    {
        _taskDic = [[NSMutableDictionary alloc]init];
    }
    return _taskDic;
}
- (NSURLSession *)zsSession
{
    if (!_zsSession)
    {
        NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        config.sharedContainerIdentifier = identifier;
        config.sessionSendsLaunchEvents = YES;
        config.discretionary = YES;
        _zsSession =  [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        _zsSession.sessionDescription = identifier;
    }
    return _zsSession;
}
- (NSMutableSet *)taskSet
{
    if (!_taskSet)
    {
        _taskSet = [NSMutableSet setWithArray:[ZSUserDefaultsStandar objectForKey:TaskCacheSet]];
        if (!_taskSet)
        {
            _taskSet = [[NSMutableSet alloc]init];
        }
    }
    return _taskSet;
}
- (void)beginDownloadTask:(NSString *)urlString keyname:(NSString *)keyname
{
    //创建下载图片的url
    NSURL *url = [NSURL URLWithString:urlString];

    [self createCacheDirectory];
    
    //创建请求并设置缓存策略以及超时时长
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.f];
    //*也可通过configuration.requestCachePolicy 设置缓存策略
    
    //创建一个下载任务
    NSURLSessionDownloadTask *task = [[self backgroundSession] downloadTaskWithRequest:imgRequest];
    [ZSUserDefaultsStandar setObject:keyname forKey:[NSString stringWithFormat:@"%ld",(unsigned long)task.taskIdentifier]];
    [ZSUserDefaultsStandar synchronize];
    //启动下载任务
    [task resume];
    [self.taskDic setObject:task forKey:keyname];
}
- (void)resuspendOrBegin:(NSString *)keyname
{
    NSURLSessionDownloadTask *downTask = [self.taskDic objectForKey:keyname];
    if (downTask)
    {
        if (downTask.state == NSURLSessionTaskStateRunning)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:zsDownloadSuspend object:self userInfo:@{@"task":downTask}];
            [downTask suspend];
            
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:zsDownloadEnterDownload object:self userInfo:@{@"task":downTask}];
            [downTask resume];
            
        } 
    }
    else
    {
        
    }

}
- (void)deleteDownload:(NSString *)name
{
    NSURLSessionDownloadTask *downTask = [self.taskDic objectForKey:name];

    if ([self.taskDic objectForKey:name])
    {
        [downTask cancel];
        downTask = nil;
        [self.taskDic removeObjectForKey:name];

    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *fileName = [NSString stringWithFormat:@"%@/%@",ZSCachesDirectory,name];
    BOOL res = [fileManager removeItemAtPath:fileName
                                       error:nil];
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler
{
    //  发送通知
    [[NSNotificationCenter defaultCenter] postNotificationName:zsDownloadFileSize object:self userInfo:@{@"task":task,@"response":response}];
}
- (void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.backgroundSessionCompletionHandler) {
        
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        
        appDelegate.backgroundSessionCompletionHandler = nil;
        
        completionHandler();
        
    }
    if (error)
    {
        NSString *path = [NSString stringWithFormat:@"%ld",(unsigned long)task.taskIdentifier];

        [[NSNotificationCenter defaultCenter] postNotificationName:zsDownloadFailure
                                                            object:self userInfo:@{@"downloadTask":task,@"error":error}];
        [self.taskDic setObject:task forKey:path];

    }
    else
    {
       
    }
}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:zsDownloadSize object:self userInfo:@{@"receivedSize":[NSString stringWithFormat:@"%lld",totalBytesWritten],@"totalBytesExpectedToWrite":[NSString stringWithFormat:@"%lld",totalBytesExpectedToWrite],@"dataTask":downloadTask}];
}
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{

      [[NSNotificationCenter defaultCenter] postNotificationName:zsDownloadSuccess object:self userInfo:@{@"downloadTask":downloadTask,@"downloadPath":location.path}];
}
/**
 *  创建缓存目录文件
 */
- (NSString *)createCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:ZSCachesDirectory])
    {
        [fileManager createDirectoryAtPath:ZSCachesDirectory
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }
    
    return ZSCachesDirectory;
}
@end
