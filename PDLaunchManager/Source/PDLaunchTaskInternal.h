//
//  PDLaunchTaskInternal.h
//  PDLaunchManager
//
//  Created by liang on 2019/7/24.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLaunchTask.h"

@interface PDLaunchTask () {
    @public
    struct {
        /* App States */
        unsigned willFinishLaunchingWithOptions : 1;
        unsigned didFinishLaunchingWithOptions : 1;
        unsigned applicationDidBecomeActive : 1;
        unsigned applicationDidEnterBackground : 1;
        unsigned applicationWillResignActive : 1;
        unsigned applicationWillEnterForeground : 1;
        unsigned applicationWillTerminate : 1;
        
        /* Remote Notification */
        unsigned didRegisterForRemoteNotificationsWithDeviceToken : 1;
        unsigned didFailToRegisterForRemoteNotificationsWithError : 1;
        unsigned didReceiveRemoteNotification : 1;
        unsigned didReceiveRemoteNotificationFetchCompletionHandler : 1;
        
        /* Screen orientation */
        unsigned supportedInterfaceOrientationsForWindow : 1;
    } _hasImpl;
}

@end
