//
//  PDLaunchTask.h
//  PDLaunchManager
//
//  Created by liang on 2020/3/24.
//  Copyright © 2020 liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDLaunchTask : NSObject <UIApplicationDelegate, UNUserNotificationCenterDelegate>

- (BOOL)keep;
- (void)launchWithOptions:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
