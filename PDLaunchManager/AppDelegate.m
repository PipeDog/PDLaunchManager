//
//  AppDelegate.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "AppDelegate.h"
#import "PDTaskDispatcher.h"
#import "PDLaunchManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"LaunchTask" ofType:@"plist"];
    
    NSDictionary *(^collectLaunchTasks)(void) = ^{
        if (@available(iOS 11.0, *)) {
            NSURL *URL = [NSURL fileURLWithPath:plistPath];
            return [NSDictionary dictionaryWithContentsOfURL:URL error:nil];
        } else {
            // Fallback on earlier versions
            return [NSDictionary dictionaryWithContentsOfFile:plistPath];
        }
    };
    
    NSDictionary *launchTasks = collectLaunchTasks();
    
    PDLaunchManager *launchManager = [PDLaunchManager defaultManager];
    [launchManager performLaunchTasks:launchTasks options:launchOptions];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    [[PDTaskDispatcher globalDispatcher] applicationWillResignActive:application];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[PDTaskDispatcher globalDispatcher] applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[PDTaskDispatcher globalDispatcher] applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[PDTaskDispatcher globalDispatcher] applicationDidBecomeActive:application];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    [[PDTaskDispatcher globalDispatcher] applicationWillTerminate:application];
}


@end
