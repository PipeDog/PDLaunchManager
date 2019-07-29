//
//  PDTest13LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest13LaunchTask.h"

@implementation PDTest13LaunchTask

- (PDLaunchTaskPriority)priority {
    return PDLaunchTaskPriorityAsyncAfterLaunch;
}

- (PDLaunchTaskSubPriority)subPriority {
    return 10;
}

- (void)launchWithOptions:(NSDictionary *)options {
    int i = 10000;
    
    while (i > 0) {
        i --;
    }
    
    NSLog(@"%@, pri => %zd, subPri => %zd", [self class], [self priority], [self subPriority]);
}

@end
