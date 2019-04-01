//
//  Person+FirstName.m
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/18.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "Person+FirstName.h"
#import <objc/message.h>

// 定义关联的key
static const char *kFirstName = "firstName";

@implementation Person (FirstName)

- (NSString*)firstName{
    
    // 根据关联的key，获取关联的值。
    return objc_getAssociatedObject(self, kFirstName);
}

- (void)setFirstName:(NSString*)firstName{
    // 第一个参数：给哪个对象添加关联
    // 第二个参数：关联的key，通过这个key获取
    // 第三个参数：关联的value
    // 第四个参数:关联的策略
    objc_setAssociatedObject(self, kFirstName, firstName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
