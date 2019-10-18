//
//  PDLaunchManager.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLaunchManager.h"
#import "PDLaunchTask.h"

@interface PDLaunchManager () {
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) NSMutableArray<PDLaunchTask *> *launchTasks;
@property (nonatomic, copy) NSDictionary *launchOptions;

@end

@implementation PDLaunchManager

+ (PDLaunchManager *)defaultManager {
    static PDLaunchManager *__launchManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __launchManager = [[self alloc] init];
    });
    return __launchManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _launchTasks = [NSMutableArray array];
        _lock = dispatch_semaphore_create(1);
    }
    return self;
}

#pragma mark - Execute Methods
- (void)launchWithOptions:(NSDictionary *)options {
    self.launchOptions = options;
    
    NSArray *(^collectLaunchTasks)(void) = ^{
        if (@available(iOS 11.0, *)) {
            NSURL *URL = [NSURL fileURLWithPath:self.plistPath];
            return [NSArray arrayWithContentsOfURL:URL error:nil];
        } else {
            // Fallback on earlier versions
            return [NSArray arrayWithContentsOfFile:self.plistPath];
        }
    };
    
    NSArray *launchTasks = collectLaunchTasks();
    if (!launchTasks.count) {
        return;
    }

    for (NSDictionary *dict in launchTasks) {
        NSString *type = dict[@"type"];
        NSArray *tasks = dict[@"tasks"];
        
        if ([type isEqualToString:@"sync"]) {
            [self syncLaunchTasks:tasks];
        } else if ([type isEqualToString:@"async"]) {
            [self asyncLaunchTasks:tasks];
        } else if ([type isEqualToString:@"barrier_group"]) {
            [self barrierGroupLaunchTasks:tasks];
        } else {
            NSAssert(NO, @"Invalid `type`!");
        }
    }
}

- (NSArray<PDLaunchTask *> *)allTasks {
    return [self.launchTasks copy];
}

#pragma mark - Private Methods
- (void)syncLaunchTasks:(NSArray<NSString *> *)classnames {
    for (NSString *classname in classnames) {
        [self launchTask:classname];
    }
}

- (void)asyncLaunchTasks:(NSArray<NSString *> *)classnames {
    dispatch_queue_t queue = dispatch_queue_create("com.launchTaskQueue.async", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSString *classname in classnames) {
        dispatch_async(queue, ^{
            [self launchTask:classname];
        });
    }
}

- (void)barrierGroupLaunchTasks:(NSArray<NSString *> *)classnames {
    dispatch_queue_t queue = dispatch_queue_create("com.launchTaskQueue.barrierGroup", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    for (NSString *classname in classnames) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self launchTask:classname];
            dispatch_group_leave(group);
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (void)launchTask:(NSString *)classname {
    Class cls = NSClassFromString(classname);
    PDLaunchTask *task = [[cls alloc] init];
    
    dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER);
    [self.launchTasks addObject:task];
    dispatch_semaphore_signal(self->_lock);
    
    [task launchWithOptions:self.launchOptions];
}

@end
