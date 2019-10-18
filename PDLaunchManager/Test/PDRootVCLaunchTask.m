//
//  PDRootVCLaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/10/18.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDRootVCLaunchTask.h"
#import "AppDelegate.h"

@implementation PDRootVCLaunchTask

- (void)launchWithOptions:(NSDictionary *)options {
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor colorWithRed:100/255.f green:100/255.f blue:100/255.f alpha:1.f];
    vc.title = @"Home Page";

    UINavigationController *navigationController = [[UINavigationController alloc] init];
    [navigationController pushViewController:vc animated:NO];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    UIWindow *window = appDelegate.window;
    window.rootViewController = navigationController;
    
    NSLog(@"%@", [self class]);
}

@end
