//
//  PDPerformLab.m
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import "PDPerformLab.h"
#import <QuartzCore/QuartzCore.h>

@interface PDPerformLab ()

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *dict;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation PDPerformLab

+ (PDPerformLab *)globalLab {
    static PDPerformLab *__globalLab;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __globalLab = [[self alloc] init];
    });
    return __globalLab;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _dict = [NSMutableDictionary dictionary];
        _lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)beginForKey:(NSString *)key {
    if (!key.length) { return; }
    
    CFTimeInterval begin = CACurrentMediaTime();

    [self.lock lock];
    self.dict[key] = @(begin);
    [self.lock unlock];
    
    NSLog(@"====> key = %@ ====> begin = %lf", key, begin);
}

- (void)endForKey:(NSString *)key {
    if (!key.length) { return; }
    
    CFTimeInterval end = CACurrentMediaTime();
    
    [self.lock lock];
    
    CFTimeInterval begin = [self.dict[key] doubleValue];
    CFTimeInterval diff = end - begin;
    
    [self.lock unlock];
    
    NSLog(@"====> key = %@ ====> end = %lf ====> time = %lf", key, end, diff);
}

- (void)performBlock:(void (^)(void))block forKey:(NSString *)key {
    [self beginForKey:key];
    !block ?: block();
    [self endForKey:key];
}

@end
