//
//  PDLaunchTask.h
//  PDLaunchManager
//
//  Created by liang on 2019/10/21.
//  Copyright © 2019 liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDLaunchTask <UIApplicationDelegate, UNUserNotificationCenterDelegate>

- (void)launchWithOptions:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
