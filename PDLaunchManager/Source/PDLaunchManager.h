//
//  PDLaunchManager.h
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    const char *taskname;
    const char *classname;
} PDLaunchTaskName;

/* Export task */
#define __PD_EXPORT_LAUNCH_TASK_EXT(taskname, classname) \
__attribute__((used, section("__DATA , pd_exp_task"))) \
static const PDLaunchTaskName __pd_exp_task_##taskname##__ = {#taskname, #classname};

#define PD_EXPORT_LAUNCH_TASK_EXT(classname) __PD_EXPORT_LAUNCH_TASK_EXT(classname, classname)

@interface PDLaunchManager : NSObject

@end

NS_ASSUME_NONNULL_END
