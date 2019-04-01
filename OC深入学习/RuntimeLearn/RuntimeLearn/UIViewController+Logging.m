//
//  UIViewController+Logging.m
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/23.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "UIViewController+Logging.h"
#import <objc/runtime.h>


@implementation UIViewController (Logging)


+ (void)load {
    
    
    swizzledMethod([self class], @selector(viewDidAppear:), @selector(swizzled_ViewDidAppear:));
    
}


- (void)swizzled_ViewDidAppear:(BOOL)animated {
    
     //调用原方法
    [self swizzled_ViewDidAppear:animated];
    // Logging
    NSLog(@"%@",NSStringFromClass([self class]));
}

void swizzledMethod(Class class, SEL originalSelector, SEL swizzledSelector) {

    //获取原实例方法
    Method  originalMethod = class_getInstanceMethod(class, originalSelector);
    //要交换的方法
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    
    //为类动态添加方法。如果有同名会返回NO，修改的话需要使用method_setImplementation
    //替换原方法的实现，将原方法的实现替换为交换方法的实现
    BOOL didAddMethod = class_addMethod(class, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        //替代方法的实现
        class_replaceMethod(class, swizzledSelector,method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
        //替换成功则将原方法的实现替换交换方法的实现，从而实现方法交换
        
    }else{
        //直接交换方法
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}



@end
