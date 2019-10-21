//
//  PDLaunchManager.h
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PDLaunchTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface PDLaunchManager : NSObject

+ (PDLaunchManager *)defaultManager;

- (NSArray<id<PDLaunchTask>> *)allTasks;

/**

 @param launchTasks @eg:
 
 {
    "groupList": [
        {
            "type": "sync", (sync | async | barrier)
            "tasks": [
                "task class name 1",
                "task class name 2",
                ...
            ]
        },
        {
            "type": "sync" ("sync" || "async" || "barrier"),
            "tasks": [
                "task class name 3",
                "task class name 4",
                ...
            ]
        },
        {
            "type": "sync" ("sync" || "async" || "barrier"),
            "tasks": [
                "task class name 5",
                "task class name 6",
                ...
            ]
        },
        ...
    ]
 }
*/

- (void)performLaunchTasks:(NSDictionary *)launchTasks options:(NSDictionary *)launchOptions;

@end

NS_ASSUME_NONNULL_END
