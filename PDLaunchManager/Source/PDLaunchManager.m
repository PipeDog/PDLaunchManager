//
//  PDLaunchManager.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDLaunchManager.h"
#import <objc/runtime.h>
#import "PDLaunchTask.h"
#import <dlfcn.h>
#import <mach-o/getsect.h>
#import <QuartzCore/QuartzCore.h>
#import "PDPerformLab.h"

@interface PDLaunchManager ()

@property (nonatomic, strong) dispatch_queue_t asyncInSubThreadQueue;
@property (nonatomic, strong) dispatch_queue_t asyncInSubThreadAfterLaunchQueue;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<PDLaunchTask *> *> *tasks;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation PDLaunchManager

static PDLaunchManager *__launchManager;

+ (PDLaunchManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __launchManager = [[self alloc] init];
    });
    return __launchManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _asyncInSubThreadQueue = dispatch_queue_create("com.xdf.launchAsyncTaskQueue", DISPATCH_QUEUE_SERIAL);
        _asyncInSubThreadAfterLaunchQueue = dispatch_queue_create("com.xdf.launchasyncAfterLaunchTaskQueue", DISPATCH_QUEUE_SERIAL);
        _tasks = [NSMutableDictionary dictionary];
        
        [self collectTasks];
    }
    return self;
}

- (void)launch {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self executeHighestTasks];
    [self executeAsyncInSubThreadTasks];
    [self executeAsyncInMainThreadTasks];
}

#pragma mark - Collect Tasks Methods
- (void)collectTasks {
    [self loadTask:^(NSString *classname) {
        Class cls = NSClassFromString(classname);
        PDLaunchTask *task = [[cls alloc] init];
        PDLaunchTaskPriority priority = [task priority];
        
        NSMutableArray<PDLaunchTask *> *sameLevelTasks = self.tasks[@(priority)];
        if (!sameLevelTasks) {
            sameLevelTasks = [NSMutableArray array];
            self.tasks[@(priority)] = sameLevelTasks;
        }
        
        [sameLevelTasks addObject:task];
    }];
    
    // Sort tasks
    [[self.tasks.allValues copy] enumerateObjectsUsingBlock:^(NSMutableArray<PDLaunchTask *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sortUsingComparator:^NSComparisonResult(PDLaunchTask * _Nonnull obj1, PDLaunchTask * _Nonnull obj2) {
            return [obj1 subPriority] < [obj2 subPriority];
        }];
    }];
}

- (void)loadTask:(void (^)(NSString *classname))registerHandler {
    Dl_info info; dladdr(&__launchManager, &info);
    
#ifdef __LP64__
    uint64_t addr = 0; const uint64_t mach_header = (uint64_t)info.dli_fbase;
    const struct section_64 *section = getsectbynamefromheader_64((void *)mach_header, "__DATA", "pd_exp_task");
#else
    uint32_t addr = 0; const uint32_t mach_header = (uint32_t)info.dli_fbase;
    const struct section *section = getsectbynamefromheader((void *)mach_header, "__DATA", "pd_exp_task");
#endif
    
    if (section == NULL)  return;
    
    for (addr = section->offset; addr < section->offset + section->size; addr += sizeof(PDLaunchTaskName)) {
        PDLaunchTaskName *task = (PDLaunchTaskName *)(mach_header + addr);
        if (!task) continue;
        
        NSString *classname = [NSString stringWithUTF8String:task->classname];
        !registerHandler ?: registerHandler(classname);
    }
}

#pragma mark - Execute Methods
- (void)executeHighestTasks {
    NSMutableArray<PDLaunchTask *> *tasks = self.tasks[@(PDLaunchTaskPriorityHighest)];
    [self executeTasks:tasks priority:PDLaunchTaskPriorityHighest];
}

- (void)executeAsyncInMainThreadTasks {
    NSMutableArray<PDLaunchTask *> *tasks = self.tasks[@(PDLaunchTaskPriorityAsyncInMainThread)];
    [self executeTasks:tasks priority:PDLaunchTaskPriorityAsyncInMainThread];
}

- (void)executeAsyncInSubThreadTasks {
    dispatch_async(self.asyncInSubThreadQueue, ^{
        NSMutableArray<PDLaunchTask *> *tasks = self.tasks[@(PDLaunchTaskPriorityAsyncInSubThread)];
        [self executeTasks:tasks priority:PDLaunchTaskPriorityAsyncInSubThread];
    });
}

- (void)executeAsyncInSubThreadAfterLaunchTasks {
    dispatch_async(self.asyncInSubThreadAfterLaunchQueue, ^{
        NSMutableArray<PDLaunchTask *> *tasks = self.tasks[@(PDLaunchTaskPriorityAsyncInSubThreadAfterLaunch)];
        [self executeTasks:tasks priority:PDLaunchTaskPriorityAsyncInSubThreadAfterLaunch];
    });
}

- (void)executeTasks:(NSArray<PDLaunchTask *> *)tasks priority:(PDLaunchTaskPriority)priority {
    NSString *key = [NSString stringWithFormat:@"%zd", priority];
    
    PDPerformLab *lab = [PDPerformLab globalLab];
    [lab beginForKey:key];
    
    for (PDLaunchTask *task in [tasks copy]) {
        [task run];
    }

    [lab endForKey:key];
}

#pragma mark - Tick Methods
- (void)tick:(CADisplayLink *)displayLink {
    [self executeAsyncInSubThreadAfterLaunchTasks];
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end
