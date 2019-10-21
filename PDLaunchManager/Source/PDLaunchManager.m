//
//  PDLaunchManager.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLaunchManager.h"

#define Lock() dispatch_semaphore_wait(self->_lock, DISPATCH_TIME_FOREVER)
#define Unlock() dispatch_semaphore_signal(self->_lock)

@interface PDLaunchManager () {
    dispatch_semaphore_t _lock;
}

@property (nonatomic, strong) NSMutableDictionary<NSString *, id<PDLaunchTask>> *launchTasks;

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
        _lock = dispatch_semaphore_create(1);
        _launchTasks = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - Execute Methods
- (void)performLaunchTasks:(NSDictionary *)launchTasks options:(NSDictionary *)launchOptions {
    NSArray *groupList = launchTasks[@"groupList"];
    
    for (NSDictionary *group in groupList) {
        NSString *type = group[@"type"];
        NSArray *tasks = group[@"tasks"];
        
        if ([type isEqualToString:@"sync"]) {
            [self performSyncGroupTasks:tasks options:launchOptions];
        } else if ([type isEqualToString:@"async"]) {
            [self performAsyncGroupTasks:tasks options:launchOptions];
        } else if ([type isEqualToString:@"barrier"]) {
            [self performBarrierGroupTasks:tasks options:launchOptions];
        } else {
            NSAssert(NO, @"Invalid `type`!");
        }
    }
}

- (NSArray<id<PDLaunchTask>> *)allTasks {
    return self.launchTasks.allValues;
}

#pragma mark - Private Methods
- (void)performSyncGroupTasks:(NSArray *)launchTasks options:(NSDictionary *)launchOptions {
    for (NSString *taskName in launchTasks) {
        [self performLaunchTaskWithTaskName:taskName options:launchOptions];
    }
}

- (void)performAsyncGroupTasks:(NSArray *)launchTasks options:(NSDictionary *)launchOptions {
    dispatch_queue_t queue = dispatch_queue_create("com.launchTaskQueue.async", DISPATCH_QUEUE_CONCURRENT);
    
    for (NSString *taskName in launchTasks) {
        dispatch_async(queue, ^{
            [self performLaunchTaskWithTaskName:taskName options:launchOptions];
        });
    }
}

- (void)performBarrierGroupTasks:(NSArray *)launchTasks options:(NSDictionary *)launchOptions {
    dispatch_queue_t queue = dispatch_queue_create("com.launchTaskQueue.barrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    for (NSString *taskName in launchTasks) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self performLaunchTaskWithTaskName:taskName options:launchOptions];
            dispatch_group_leave(group);
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (void)performLaunchTaskWithTaskName:(NSString *)taskName options:(NSDictionary *)launchOptions {
    if (!taskName.length) {
        NSAssert(NO, @"Launch class can not be nil!");
        return;
    }
    
    Class launchClass = NSClassFromString(taskName);
    if (!launchClass) {
        NSAssert(NO, @"Launch class does not exist!");
        return;
    }

    if (self.launchTasks[taskName]) {
        NSAssert(NO, @"Duplicate launch task for class name 「%@」!", taskName);
        return;
    }

    id<PDLaunchTask> task = [[launchClass alloc] init];
    
    Lock();
    self.launchTasks[taskName] = task;
    Unlock();
    
    if ([task respondsToSelector:@selector(launchWithOptions:)]) {
        [task launchWithOptions:launchOptions];
    }
}

@end
