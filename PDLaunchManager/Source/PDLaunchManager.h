//
//  PDLaunchManager.h
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDLaunchTask;

NS_ASSUME_NONNULL_BEGIN

/**

 *******************************************************
            launch tasks config plist, @eg:
 *******************************************************
 <array>
    <dict>
        <key>type</key>
        <string>async</string>
        <key>tasks</key>
        <array>
            <string>PDTest9LaunchTask</string>
            <string>PDTest8LaunchTask</string>
            <string>PDTest7LaunchTask</string>
        </array>
    </dict>
    <dict>
        <key>type</key>
        <string>barrier_group</string>
        <key>tasks</key>
        <array>
            <string>PDTest1LaunchTask</string>
            <string>PDTest2LaunchTask</string>
            <string>PDTest3LaunchTask</string>
        </array>
    </dict>
    <dict>
        <key>type</key>
        <string>sync</string>
        <key>tasks</key>
        <array>
            <string>PDTest4LaunchTask</string>
            <string>PDTest5LaunchTask</string>
            <string>PDTest6LaunchTask</string>
        </array>
    </dict>
 </array>
 ********************************************************
 
 keyword |  value
 ------- | --------------
         |  sync
   type  |  async
         |  barrier_group
 ------- | --------------
   tasks |  Class names for launch tasks
 
*/

@interface PDLaunchManager : NSObject

@property (nonatomic, copy) NSString *plistPath;

+ (PDLaunchManager *)defaultManager;

- (NSArray<PDLaunchTask *> *)allTasks;

// Call this method in '- [UIApplication application:didFinishLaunchingWithOptions:]'.
- (void)launchWithOptions:(NSDictionary *)options;

@end

NS_ASSUME_NONNULL_END
