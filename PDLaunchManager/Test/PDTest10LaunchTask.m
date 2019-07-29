//
//  PDTest10LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest10LaunchTask.h"

@implementation PDTest10LaunchTask

- (PDLaunchTaskPriority)priority {
    return PDLaunchTaskPrioritySync;
}

- (PDLaunchTaskSubPriority)subPriority {
    return 0;
}

- (void)launchWithOptions:(NSDictionary *)options {
    int i = 10000;
    
    while (i > 0) {
        i --;
    }
    
    NSLog(@"%@, pri => %zd, subPri => %zd", [self class], [self priority], [self subPriority]);
}

@end
