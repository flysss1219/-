//
//  ViewController.m
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/18.
//  Copyright © 2019 Berui. All rights reserved.
//


/*
 Runtime
 
 */


#import "ViewController.h"
#import <objc/message.h>
#import "Person.h"
#import "Student.h"
#import "Person+FirstName.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self exchangeMethodImp];
}

- (void)baseUseOfSendMsg{
    // 创建person对象
    Person *p = [Person new];
     // 调用对象方法
    [p eat];
     // 本质：让对象发送消息
//    objc_msgSend(p,@selector(eat));
    
    // 调用类方法的方式：两种
    // 第一种通过类名调用
    [Person run];
    // 第二种通过类对象调用
    [[Person class] run];
    // 用类名调用类方法，底层会自动把类名转换成类对象调用
    // 本质：让类对象发送消息
//    objc_msgSend([Person class],@selector(run));

    
}


- (void)exchangeMethodImp{
    
    // 需求：给imageNamed方法提供功能，每次加载图片就判断下图片是否加载成功。
    // 步骤一：先搞个分类，定义一个能加载图片并且能打印的方法+ (instancetype)imageWithName:(NSString *)name;
    // 步骤二：交换imageNamed和imageWithName的实现，就能调用imageWithName，间接调用imageWithName的实现。
    UIImage *image = [UIImage imageNamed:@"123"];

    
}

- (void)dynamicAddMethod{
    Student *sdu = [Student new];
    // 默认person，没有实现eat方法，可以通过performSelector调用，但是会报错。
    // 动态添加方法就不会报错
    [sdu performSelector:@selector(study) withObject:nil];
}


- (void)dynamicAddPropertyUseCategory{
    Person *p = [Person new];
    p.firstName = @"姓氏";
    NSLog(@"p.name = %@",p.firstName);
}

/*
 一、 runtime作用
 
 1、发送消息
    方法调用的本质，就是让对象发送消息。
    objc_msgSend,只有对象才能发送消息，因此以objc开头.
    使用消息机制前提，必须导入#import <objc/message.h>
    消息机制简单使用
    - (void)baseUseOfSendMsg
    消息机制原理：对象根据方法编号SEL去映射表查找对应的方法实现(https://upload-images.jianshu.io/upload_images/304825-eced87b260a7c5d4.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000)
 
 2、交换方法
    开发使用场景:系统自带的方法功能不够，给系统自带的方法扩展一些功能，并且保持原有的功能。
    方式一:继承系统的类，重写方法.
    方式二:使用runtime,交换方法.
    - (void)exchangeMethodImp
 
 3、动态添加方法
    开发使用场景：如果一个类方法非常多，加载类到内存的时候也比较耗费资源，需要给每个方法生成映射表，可以使用动态给某个类，添加方法解决。
    经典面试题：有没有使用performSelector，其实主要想问你有没有动态添加过方法。
    - (void)dynamicAddMethod
 
 4、给分类添加属性
    原理：给一个类声明属性，其实本质就是给这个类添加关联，并不是直接把这个值的内存空间添加到类存空间
    - (void)dynamicAddPropertyUseCategory
 
 
 5、字典转模型
    思路：利用运行时，遍历模型中所有属性，根据模型的属性名，去字典中查找key，取出对应的值，给模型的属性赋值。
    步骤：提供一个NSObject分类，专门字典转模型，以后所有模型都可以通过这个分类转。
 
 
 
 */



@end


#import <objc/message.h>
@implementation UIImage(Image)

// 加载分类到内存的时候调用
+ (void)load{
    // 交换方法
    
    // 获取imageWithName方法地址
    Method imageWithName = class_getClassMethod(self, @selector(imageWithLogName:));
    // 获取imageWithName方法地址
    Method imageName = class_getClassMethod(self, @selector(imageNamed:));
    // 交换方法地址，相当于交换实现方式
    method_exchangeImplementations(imageWithName, imageName);
    
}

// 不能在分类中重写系统方法imageNamed，因为会把系统的功能给覆盖掉，而且分类中不能调用super.
// 既能加载图片又能打印
+ (instancetype)imageWithLogName:(NSString*)name {
    // 这里调用imageWithName，相当于调用imageName
    UIImage *image = [self imageWithLogName:name];
    if (!image) {
        NSLog(@"加载空图片");
    }
    return image;
}

@end
