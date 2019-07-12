//
//  PDTest2LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest2LaunchTask.h"

@implementation PDTest2LaunchTask

- (PDLaunchTaskPriority)priority {
    return PDLaunchTaskPriorityHighest;
}

- (PDLaunchTaskSubPriority)subPriority {
    return 10;
}

- (void)run {
    int i = 100000;
    
    while (i > 0) {
        i --;
    }
    
    NSLog(@"%@, pri => %zd, subPri => %zd", [self class], [self priority], [self subPriority]);
}

@end
