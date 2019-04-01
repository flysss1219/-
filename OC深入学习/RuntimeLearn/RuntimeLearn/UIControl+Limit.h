//
//  UIControl+Limit.h
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/23.
//  Copyright © 2019 Berui. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIControl (Limit)


@property (nonatomic, assign) NSTimeInterval acceptEventInterval;

@property (nonatomic, assign) BOOL ignoreEvent;



@end

NS_ASSUME_NONNULL_END
