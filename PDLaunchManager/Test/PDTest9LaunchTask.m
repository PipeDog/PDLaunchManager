//
//  PDTest9LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest9LaunchTask.h"

@implementation PDTest9LaunchTask

- (PDLaunchTaskPriority)priority {
    return PDLaunchTaskPriorityAsync;
}

- (void)launchWithOptions:(NSDictionary *)options {
    int i = 10000;
    
    while (i > 0) {
        i --;
    }
    
    NSLog(@"%@, pri => %zd, subPri => %zd", [self class], [self priority], [self subPriority]);
}

@end
