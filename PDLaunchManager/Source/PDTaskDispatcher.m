//
//  PDTaskDispatcher.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/29.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTaskDispatcher.h"
#import "PDLaunchTask.h"
#import "PDLaunchManager.h"

@implementation PDTaskDispatcher

+ (PDTaskDispatcher *)globalDispatcher {
    static PDTaskDispatcher *__globalDispatcher;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalDispatcher = [[self alloc] init];
    });
    return __globalDispatcher;
}

- (NSArray<PDLaunchTask *> *)tasks {
    return [PDLaunchManager defaultManager].launchTasks;
}

#pragma mark -  App States Methods
- (void)applicationDidBecomeActive:(UIApplication *)application {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationDidBecomeActive:)]) {
            [task applicationDidBecomeActive:application];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            [task applicationDidEnterBackground:application];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationWillResignActive:)]) {
            [task applicationWillResignActive:application];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            [task applicationWillEnterForeground:application];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationWillTerminate:)]) {
            [task applicationWillTerminate:application];
        }
    }
}

#pragma mark - Remote Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            [task application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
            [task application:application didFailToRegisterForRemoteNotificationsWithError:error];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
            [task application:application didReceiveRemoteNotification:userInfo];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            [task application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        }
    }
}

#pragma mark - Screen orientation
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskPortrait;
    NSUInteger sentinel = 0;
    
    for (PDLaunchTask *task in self.tasks) {
        if ([task respondsToSelector:@selector(application:supportedInterfaceOrientationsForWindow:)]) {
            if (!sentinel) {
                mask = [task application:application supportedInterfaceOrientationsForWindow:window];
                sentinel += 1;
            } else {
                [task application:application supportedInterfaceOrientationsForWindow:window];
            }
        }
    }
    
    return mask;
}

@end
