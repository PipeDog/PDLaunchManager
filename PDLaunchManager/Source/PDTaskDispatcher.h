//
//  PDTaskDispatcher.h
//  PDLaunchManager
//
//  Created by liang on 2019/7/29.
//  Copyright © 2019 liang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PDTaskDispatcher <UIApplicationDelegate>
@end

@interface PDTaskDispatcher : NSObject <PDTaskDispatcher>

@property (class, strong, readonly) PDTaskDispatcher *globalDispatcher;

@end

NS_ASSUME_NONNULL_END
