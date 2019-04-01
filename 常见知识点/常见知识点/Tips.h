//
//  Tips.h
//  常见知识点
//
//  Created by iOSDev on 2019/1/31.
//  Copyright © 2019 Berui. All rights reserved.
//


/*常量，enum，宏*/
/*
 
 宏定义跟const的区别：
 1.宏在编译开始之前就会被替换，而const只是变量进行修饰;
 2.宏可以定义一些函数方法，const不能
 3.宏编译时只替换不做检查不报错，也就是说有重复定义问题。而const会编译检查，会报错
 
 那到底什么时候使用宏，什么时候该使用const？
 定义不对外公开的常量的时候，我们应该尽量先考虑使用 static 方式声名const来替代使用宏定义。const不能满足的情况再考虑使用宏定义。比如用以下定义：
 static NSString * const kConst = @"Hello"；
 static const CGFloat kWidth = 10.0;
 代替：
 #define DEFINE @"Hello"
 #define WIDTH 10.0
 
 当定义对外公开的常量的时候，我们一般使用如下定义：
 //Test.h
 extern NSString * const CLASSNAMEconst;
 //Test.m
 NSString * const CLASSNAMEconst = @"hello";
 
 对于整型类型，代替宏定义直接定义整型常量比较好的办法是使用enum，使用enum时推荐使用NS_ENUM和NS_OPTIONS宏。比如用以下定义：
 typedef NS_ENUM(NSInteger,TestEnum) {
 MY_INT_CONST = 12345
 };
 代替：
 #define MY_INT_CONST 12345
 
 NS_OPTIONS定义方式如下：
 typedef NS_OPTIONS(NSInteger, SelectType) {
 SelectA    = 0,
 SelectB    = 1 << 0,
 SelectC    = 1 << 1,
 SelectD    = 1 << 2
 };
 
 */
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Tips : NSObject







@end

/*
 const 的一些使用方式，主要说明这几种写法的区别：
 
 const NSString *constString1 = @"I am a const NSString * string";
 
 NSString const *constString2 = @"I am a NSString const * string";
 
 static const NSString *staticConstString1 = @"I am a static const NSString * string";
 
 static NSString const *staticConstString2 = @"I am a static NSString const * string";
 
 NSString * const stringConst = @"I am a NSString * const string";
 
 全局变量：
 
 //全局变量，constString1地址不能修改，constString1值能修改
 const NSString *constString1 = @"I am a const NSString * string";
 
 //意义同上，无区别
 NSString const *constString2 = @"I am a NSString const * string";
 
 // stringConst 地址能修改，stringConst值不能修改
 NSString * const stringConst = @"I am a NSString * const string";
 
 constString1 跟constString2 无区别.
 ＊左边代表指针本身的类型信息，const表示这个指针指向的这个地址是不可变的
 ＊右边代表指针指向变量的可变性，即指针存储的地址指向的内存单元所存储的变量的可变性
 
 
 局部常量：
 //作用域只在本文件中
 static const NSString *kstaticConstString1 = @"I am a static const NSString * string";
 static NSString const *kstaticConstString2 = @"I am a static NSString const * string";
 
 */





NS_ASSUME_NONNULL_END
