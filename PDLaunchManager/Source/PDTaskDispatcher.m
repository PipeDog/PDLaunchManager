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

- (NSArray<id<PDLaunchTask>> *)tasks {
    return [[PDLaunchManager defaultManager] allTasks];
}

#pragma mark -  App States Methods
- (void)applicationDidBecomeActive:(UIApplication *)application {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationDidBecomeActive:)]) {
            [task applicationDidBecomeActive:application];
        }
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationDidEnterBackground:)]) {
            [task applicationDidEnterBackground:application];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationWillResignActive:)]) {
            [task applicationWillResignActive:application];
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationWillEnterForeground:)]) {
            [task applicationWillEnterForeground:application];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(applicationWillTerminate:)]) {
            [task applicationWillTerminate:application];
        }
    }
}

#pragma mark - Deep Link
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    BOOL ret = NO;
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(application:openURL:options:)]) {
            ret = ret || [task application:app openURL:url options:options];
        }
    }
    return ret;
}

#pragma mark - Remote Notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)]) {
            [task application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
        }
    }
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)]) {
            [task application:application didFailToRegisterForRemoteNotificationsWithError:error];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(application:didReceiveRemoteNotification:)]) {
            [task application:application didReceiveRemoteNotification:userInfo];
        }
    }
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)]) {
            [task application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
        }
    }
}

#pragma mark - Screen orientation
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    for (id<PDLaunchTask> task in self.tasks) {
        if ([task respondsToSelector:@selector(application:supportedInterfaceOrientationsForWindow:)]) {
            return [task application:application supportedInterfaceOrientationsForWindow:window];
        }
    }
    return UIInterfaceOrientationMaskAll;
}

@end
