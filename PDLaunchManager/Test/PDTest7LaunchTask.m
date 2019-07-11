//
//  PDTest7LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest7LaunchTask.h"

@implementation PDTest7LaunchTask

- (PDLaunchTaskPriority)priority {
    return PDLaunchTaskPriorityAsyncInMainThread;
}

- (NSUInteger)subPriority {
    return 101;
}

- (void)run {
    int i = 10000;
    
    while (i > 0) {
        i --;
    }
    
    NSLog(@"%@, pri => %zd, subPri => %zd", [self class], [self priority], [self subPriority]);
}

@end