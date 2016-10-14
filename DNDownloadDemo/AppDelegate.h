//
//  AppDelegate.h
//  DNDownloadDemo
//
//  Created by Admin on 16/10/13.
//  Copyright © 2016年 Xudong. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void (^completionHandler)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, copy)completionHandler backgroundSessionCompletionHandler;


@end

