//
//  PDTest8LaunchTask.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDTest8LaunchTask.h"

@implementation PDTest8LaunchTask

- (void)launchWithOptions:(NSDictionary *)launchOptions {
    int i = 10000;
    
    while (i > 0) {
        i --;
    }
    
    NSLog(@"%@", [self class]);
}

@end
