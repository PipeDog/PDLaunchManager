//
//  PDTest3LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest3LaunchTask.h"

@implementation PDTest3LaunchTask

- (PDLaunchTaskPriority)priority {
    return PDLaunchTaskPriorityHighest;
}

- (NSUInteger)subPriority {
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
