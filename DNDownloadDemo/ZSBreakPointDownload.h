//
//  ZSBreakPointDownload.h
//  TestBreakPointDownload
//
//  Created by XD on 16/5/24.
//  Copyright © 2016年 Zhishang,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#define ZSCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"ZSCache"]


#define ZSUserDefaultsStandar  [NSUserDefaults standardUserDefaults]

extern NSString  *zsDownloadSuccess;
extern NSString  *zsDownloadFileSize;
extern NSString  *zsDownloadSize;
extern NSString  *zsDownloadFailure;
extern NSString  *zsDownloadWaiting;
extern NSString  *zsDownloadEnterDownload;
extern NSString  *zsDownloadSuspend;
@interface ZSBreakPointDownload : NSObject
+ (ZSBreakPointDownload *)sharedManager;
- (NSURLSession *)backgroundSession;
- (void)beginDownloadTask:(NSString *)urlString keyname:(NSString *)keyname;
- (void)resuspendOrBegin:(NSString *)keyname;
- (void)deleteDownload:(NSString *)name;
@end
