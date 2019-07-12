//
//  PDTest4LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest4LaunchTask.h"

@implementation PDTest4LaunchTask

- (PDLaunchTaskPriority)priority {
    return PDLaunchTaskPriorityHighest;
}

- (PDLaunchTaskSubPriority)subPriority {
    return 100;
}

- (void)run {
    int i = 10000;
    
    while (i > 0) {
        i --;
    }
    
    NSLog(@"%@, pri => %zd, subPri => %zd", [self class], [self priority], [self subPriority]);
}

@end
