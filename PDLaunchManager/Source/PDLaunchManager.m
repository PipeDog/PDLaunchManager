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

@interface PDLaunchManager ()

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSMutableArray<PDLaunchTask *> *> *tasks;
@property (nonatomic, copy) NSArray<PDLaunchTask *> *launchTasks;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) dispatch_group_t startLaunchGroup;
@property (nonatomic, copy) NSDictionary *launchOptions;

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
        _startLaunchGroup = dispatch_group_create();
        _tasks = [NSMutableDictionary dictionary];
        
        dispatch_group_enter(_startLaunchGroup);
        
        [self collectTasks];
        
        __weak typeof(self) weakSelf = self;
        dispatch_group_notify(_startLaunchGroup, dispatch_get_main_queue(), ^{
            [weakSelf launch];
        });
    }
    return self;
}


- (void)launch {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    // Warning: Do not modify the following order.
    [self executeBarrierGroupTasks];
    [self executeAsyncTasks];
    [self executeSyncTasks];
}

#pragma mark - Collect Tasks Methods
- (void)collectTasks {
    dispatch_group_enter(self.startLaunchGroup);
    NSMutableArray<PDLaunchTask *> *tasks = [NSMutableArray array];
    
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
        [tasks addObject:task];
    }];
    
    // Sort tasks
    [[self.tasks.allValues copy] enumerateObjectsUsingBlock:^(NSMutableArray<PDLaunchTask *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj sortUsingComparator:^NSComparisonResult(PDLaunchTask * _Nonnull obj1, PDLaunchTask * _Nonnull obj2) {
            return [obj1 subPriority] < [obj2 subPriority];
        }];
    }];
    
    self.launchTasks = [tasks copy];
    dispatch_group_leave(self.startLaunchGroup);
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

#pragma mark - Notification Methods
- (void)listen {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunchingWithOptions:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)applicationDidFinishLaunchingWithOptions:(NSNotification *)notification {
    self.launchOptions = notification.userInfo;
    dispatch_group_leave(_startLaunchGroup);
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Execute Methods
- (void)executeBarrierGroupTasks {
    NSMutableArray<PDLaunchTask *> *tasks = self.tasks[@(PDLaunchTaskPriorityBarrierGroup)];
    dispatch_queue_t queue = dispatch_queue_create("com.launchqueue.barrier", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_t group = dispatch_group_create();
    
    for (PDLaunchTask *task in tasks) {
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [task launchWithOptions:self.launchOptions];
            dispatch_group_leave(group);
        });
    }
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

- (void)executeAsyncTasks {
    NSMutableArray<PDLaunchTask *> *tasks = self.tasks[@(PDLaunchTaskPriorityAsync)];
    dispatch_queue_t queue = dispatch_queue_create("com.launchqueue.async", DISPATCH_QUEUE_CONCURRENT);
    
    for (PDLaunchTask *task in tasks) {
        dispatch_async(queue, ^{
            [task launchWithOptions:self.launchOptions];
        });
    }
}

- (void)executeSyncTasks {
    NSMutableArray<PDLaunchTask *> *tasks = self.tasks[@(PDLaunchTaskPrioritySync)];
    
    for (PDLaunchTask *task in tasks) {
        [task launchWithOptions:self.launchOptions];
    }
}

- (void)executeAsyncAfterLaunchTasks {
    NSMutableArray<PDLaunchTask *> *tasks = self.tasks[@(PDLaunchTaskPriorityAsyncAfterLaunch)];
    dispatch_queue_t queue = dispatch_queue_create("com.launchqueue.async-afterlaunch", DISPATCH_QUEUE_CONCURRENT);
    
    for (PDLaunchTask *task in tasks) {
        dispatch_async(queue, ^{
            [task launchWithOptions:self.launchOptions];
        });
    }
}

#pragma mark - Tick Methods
- (void)tick:(CADisplayLink *)displayLink {
    [self executeAsyncAfterLaunchTasks];
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end

__attribute__((constructor))
static void launch(void) {
    [[PDLaunchManager defaultManager] listen];
}
