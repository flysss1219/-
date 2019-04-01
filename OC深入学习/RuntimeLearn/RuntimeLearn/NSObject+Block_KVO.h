//
//  NSObject+Block_KVO.h
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/25.
//  Copyright © 2019 Berui. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SWObeservingHandler)(id observeObject, NSString *key, id newValue, id oldValue);


@interface NSObject (Block_KVO)


- (void)sw_addObserver:(NSObject *)observer forKey:(NSString*)key withBlock:(SWObeservingHandler)block;



- (void)sw_removeObserver:(NSObject*)observer forKey:(NSString*)key;



@end

NS_ASSUME_NONNULL_END
