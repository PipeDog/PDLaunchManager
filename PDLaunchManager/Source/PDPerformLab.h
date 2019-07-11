//
//  PDPerformLab.h
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface PDPerformLab : NSObject

@property (class, strong, readonly) PDPerformLab *globalLab;

- (void)beginForKey:(NSString *)key;
- (void)endForKey:(NSString *)key;

- (void)performBlock:(void (^)(void))block forKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
