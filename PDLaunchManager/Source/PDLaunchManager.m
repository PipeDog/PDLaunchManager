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
#import <UIKit/UIKit.h>
#import <Aspects.h>
#import "PDLaunchTaskInternal.h"

#ifndef force_inline
#define force_inline __inline__ __attribute__((always_inline))

static force_inline id NilOrObjectAtIndex(NSArray *args, NSInteger index) {
    id arg = index < args.count ? args[index] : nil;
    if (arg == [NSNull null]) {
        arg = nil;
    }
    return arg;
}

@interface PDLaunchManager ()

@property (nonatomic, copy) NSString *portName;
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
        
        [self collectPortName];
        [self collectTasks];
    }
    return self;
}

- (void)launch {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    // Warning: Do not modify the following order.
    [self executeHighestTasks];
    [self executeAsyncInSubThreadTasks];
    [self executeAsyncInMainThreadTasks];
}

#pragma mark - Collect Tasks Methods
- (void)collectPortName {
    Dl_info info; dladdr(&__launchManager, &info);
    
#ifdef __LP64__
    uint64_t addr = 0; const uint64_t mach_header = (uint64_t)info.dli_fbase;
    const struct section_64 *section = getsectbynamefromheader_64((void *)mach_header, "__DATA", "pd_exp_port");
#else
    uint32_t addr = 0; const uint32_t mach_header = (uint32_t)info.dli_fbase;
    const struct section *section = getsectbynamefromheader((void *)mach_header, "__DATA", "pd_exp_port");
#endif
    
    if (section == NULL)  return;
    
    addr = section->offset;
    PDLaunchPortName *port = (PDLaunchPortName *)(mach_header + addr);
    if (!port) { return; }
    
    self.portName = [NSString stringWithUTF8String:port->portname];    
}

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

#pragma mark - Notification Methods
- (void)listen {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidFinishLaunchingWithOptions:) name:UIApplicationDidFinishLaunchingNotification object:nil];
}

- (void)applicationDidFinishLaunchingWithOptions:(NSNotification *)notification {
    [self launch];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
    for (PDLaunchTask *task in [tasks copy]) {
        [task run];
    }
}

#pragma mark - Tick Methods
- (void)tick:(CADisplayLink *)displayLink {
    [self executeAsyncInSubThreadAfterLaunchTasks];
    
    [self.displayLink invalidate];
    self.displayLink = nil;
}

@end

@implementation PDLaunchManager (_LaunchHook)

#pragma mark - Hook Methods
- (void)enumTask:(void (^)(PDLaunchTask *task))block {
    [[self.tasks.allValues copy] enumerateObjectsUsingBlock:^(NSMutableArray<PDLaunchTask *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(PDLaunchTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            !block ?: block(obj);
        }];
    }];
}

- (void)hook {
    Class class = NSClassFromString(self.portName);

    /* App States */
    [class aspect_hookSelector:@selector(application:willFinishLaunchingWithOptions:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.willFinishLaunchingWithOptions) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                NSDictionary *options = NilOrObjectAtIndex(aspectInfo.arguments, 1);
                [task application:application willFinishLaunchingWithOptions:options];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(application:didFinishLaunchingWithOptions:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.didFinishLaunchingWithOptions) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                NSDictionary *options = NilOrObjectAtIndex(aspectInfo.arguments, 1);
                [task application:application didFinishLaunchingWithOptions:options];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(applicationDidBecomeActive:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.applicationDidBecomeActive) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                [task applicationDidBecomeActive:application];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(applicationDidEnterBackground:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.applicationDidEnterBackground) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                [task applicationDidEnterBackground:application];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(applicationWillResignActive:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.applicationWillResignActive) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                [task applicationWillResignActive:application];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(applicationWillEnterForeground:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.applicationWillEnterForeground) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                [task applicationWillEnterForeground:application];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(applicationWillTerminate:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.applicationWillTerminate) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                [task applicationWillTerminate:application];
            }
        }];
    } error:nil];
    
    /* Remote Notification */
    [class aspect_hookSelector:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.didRegisterForRemoteNotificationsWithDeviceToken) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                NSData *deviceToken = NilOrObjectAtIndex(aspectInfo.arguments, 1);
                [task application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(application:didFailToRegisterForRemoteNotificationsWithError:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.didFailToRegisterForRemoteNotificationsWithError) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                NSError *error = NilOrObjectAtIndex(aspectInfo.arguments, 1);
                [task application:application didFailToRegisterForRemoteNotificationsWithError:error];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(application:didReceiveRemoteNotification:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.didReceiveRemoteNotification) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                NSDictionary *userInfo = NilOrObjectAtIndex(aspectInfo.arguments, 1);
                [task application:application didReceiveRemoteNotification:userInfo];
            }
        }];
    } error:nil];
    
    [class aspect_hookSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo) {
        [self enumTask:^(PDLaunchTask *task) {
            if (task->_hasImpl.didReceiveRemoteNotificationFetchCompletionHandler) {
                UIApplication *application = NilOrObjectAtIndex(aspectInfo.arguments, 0);
                NSDictionary *userInfo = NilOrObjectAtIndex(aspectInfo.arguments, 1);
                void (^completionHandler)(UIBackgroundFetchResult) = NilOrObjectAtIndex(aspectInfo.arguments, 2);
                [task application:application didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
            }
        }];
    } error:nil];
}

@end

__attribute__((constructor))
static void launch(void) {
    [[PDLaunchManager defaultManager] listen];
    [[PDLaunchManager defaultManager] hook];
}

#endif
