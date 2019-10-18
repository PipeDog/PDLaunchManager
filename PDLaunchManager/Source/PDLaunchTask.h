//
//  PDLaunchTask.h
//  PDLaunchManager
//
//  Created by liang on 2019/7/11.
//  Copyright © 2019 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDLaunchTask <UIApplicationDelegate>
@end

@interface PDLaunchTask : NSObject <PDLaunchTask>

- (void)launchWithOptions:(NSDictionary *)options;

@end

NS_ASSUME_NONNULL_END
