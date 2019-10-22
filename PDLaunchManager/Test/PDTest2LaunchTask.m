//
//  PDTest2LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest2LaunchTask.h"

@implementation PDTest2LaunchTask

- (void)launchWithOptions:(NSDictionary *)launchOptions {
    int i = 100000;
    
    while (i > 0) {
        i --;
    }
    
    NSLog(@"%@", [self class]);
}

@end
