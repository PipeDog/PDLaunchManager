//
//  PDLaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLaunchTask.h"
#import "PDLaunchTaskInternal.h"

@implementation PDLaunchTask

- (instancetype)init {
    self = [super init];
    if (self) {
        /* State Changed */
        _hasImpl.willFinishLaunchingWithOptions = [self respondsToSelector:@selector(application:willFinishLaunchingWithOptions:)];
        _hasImpl.didFinishLaunchingWithOptions = [self respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)];
        _hasImpl.applicationDidBecomeActive = [self respondsToSelector:@selector(applicationDidBecomeActive:)];
        _hasImpl.applicationDidEnterBackground = [self respondsToSelector:@selector(applicationDidEnterBackground:)];
        _hasImpl.applicationWillResignActive = [self respondsToSelector:@selector(applicationWillResignActive:)];
        _hasImpl.applicationWillEnterForeground = [self respondsToSelector:@selector(applicationWillEnterForeground:)];
        _hasImpl.applicationWillTerminate = [self respondsToSelector:@selector(applicationWillTerminate:)];

        /* Remote Notification */
        _hasImpl.didRegisterForRemoteNotificationsWithDeviceToken = [self respondsToSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:)];
        _hasImpl.didFailToRegisterForRemoteNotificationsWithError = [self respondsToSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:)];
        _hasImpl.didReceiveRemoteNotification = [self respondsToSelector:@selector(application:didReceiveRemoteNotification:)];
        _hasImpl.didReceiveRemoteNotificationFetchCompletionHandler = [self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
    }
    return self;
}

- (PDLaunchTaskPriority)priority {
    NSAssert(NO, @"This method must be overrided!");
    return PDLaunchTaskPriorityUnknown;
}

- (PDLaunchTaskSubPriority)subPriority {
    return 0;
}

- (void)run {
    NSAssert(NO, @"This method must be overrided!");
}

@end
