//
//  PDLaunchTask.h
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PDLaunchManager.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, PDLaunchTaskPriority) {
    // Invalid task priority
    PDLaunchTaskPriorityUnknown             = 0,
    
    // A task that must be initialized first on the main thread.
    PDLaunchTaskPriorityHighest             = 1,
    
    // A main thread task that can be executed in parallel with tasks in other subthreads
    PDLaunchTaskPriorityAsyncInMainThread   = 2,
    
    // Tasks that can be performed by subthreads
    PDLaunchTaskPriorityAsyncInSubThread    = 3,
    
    // Tasks performed by child threads can be displayed on the home page
    PDLaunchTaskPriorityAsyncInSubThreadAfterLaunch = 4,
};

typedef NSUInteger PDLaunchTaskSubPriority;

@protocol PDLaunchTask <UIApplicationDelegate>
@end

@interface PDLaunchTask : NSObject <PDLaunchTask>

- (PDLaunchTaskPriority)priority;

// The higher the value, the higher the priority, default is 0.
- (PDLaunchTaskSubPriority)subPriority;

- (void)run;

@end

NS_ASSUME_NONNULL_END
