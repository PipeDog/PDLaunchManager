//
//  PDLaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLaunchTask.h"

@implementation PDLaunchTask

- (PDLaunchTaskPriority)priority {
    NSAssert(NO, @"This method must be overrided!");
    return PDLaunchTaskPriorityUnknown;
}

- (NSUInteger)subPriority {
    return 0;
}

- (void)run {
    NSAssert(NO, @"This method must be overrided!");
}

@end
