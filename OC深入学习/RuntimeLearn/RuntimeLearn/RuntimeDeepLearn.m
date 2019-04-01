//
//  RuntimeDeepLearn.m
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/18.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "RuntimeDeepLearn.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "Person.h"

@interface RuntimeDeepLearn ()

@end

@implementation RuntimeDeepLearn

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Runtime";
    
    [self arrayClassClustersTest];
    
}

#pragma mark - OC Message Forwarding
/*

 一、消息发送的主要步骤
 1、首先检查这个selector是不是要忽略。比如Mac OS X开发，有了垃圾回收就不会理会retain，release这些函数。
 2、检测这个selector的target是不是nil，OC允许我们对一个nil对象执行任何方法不会Crash，因为运行时会被忽略掉。
 3、如果上面两步都通过了，就开始查找这个类的实现IMP，先从cache里查找，如果找到了就运行对应的函数去执行相应的代码。
 4、如果cache中没有找到就找类的方法列表中是否有对应的方法。
 5、如果类的方法列表中找不到就到父类的方法列表中查找，一直找到NSObject类为止。
 6、如果还是没找到就要开始进入动态方法解析和消息转发
 
 二、OC方法本质
    OC中的方法默认被隐藏了两个参数：self和_cmd
    self指向对象本身
    _cmd指向方法本身，它保存了正在发送的消息的选择器
 

三、动态方法解析
    Objective-C 运行时会调用 + (BOOL)resolveInstanceMethod:或者 + (BOOL)resolveClassMethod:，让你有机会提供一个函数实现。如果你添加了函数并返回 YES， 那运行时系统就会重新启动一次消息发送的过程。还是以 foo 为例，你可以这么实现：
 
四、快速转发
 Fast Rorwarding这是一种快速消息转发：只需要在指定API方法里面返回一个新对象即可，当然其它的逻辑判断还是要的（比如该SEL是否某个指定SEL？）。
 
 消息转发机制执行前，runtime系统允许我们替换消息的接收者为其他对象。通过- (id)forwardingTargetForSelector:(SEL)aSelector方法。如果此方法返回的是nil 或者self,则会进入消息转发机制（- (void)forwardInvocation:(NSInvocation *)invocation），否则将会向返回的对象重新发送消息。
 
五、完整消息转发：Normal Forwarding
   forwardInvocation: 方法就是一个不能识别消息的分发中心，将这些不能识别的消息转发给不同的消息对象，或者转发给同一个对象，再或者将消息翻译成另外的消息，亦或者简单的“吃掉”某些消息，因此没有响应也不会报错
 
 其中，参数invocation是从哪来的？在forwardInvocation:消息发送前，runtime系统会向对象发送methodSignatureForSelector:消息，并取到返回的方法签名用于生成NSInvocation对象。所以重写forwardInvocation:的同时也要重写methodSignatureForSelector:方法，否则会抛出异常。当一个对象由于没有相应的方法实现而无法响应某个消息时，运行时系统将通过forwardInvocation:消息通知该对象。每个对象都继承了forwardInvocation:方法，我们可以将消息转发给其它的对象。

 
快速转发与完整转发的区别
 1、需要重载的API方法的用法不同
   前者只需要重载一个API即可，后者需要重载两个API。
   前者只需在API方法里面返回一个新对象即可，后者需要对被转发的消息进行重签并手动转发给新对象（利用 invokeWithTarget:）。
 2、转发给新对象的个数不同，前者只能转发一个对象，后者可以连续转发给多个对象
*/


//动态方法解析
void fooMethod(id obj, SEL _cmd){
    NSLog(@"doing foo");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel{
    if (sel == @selector(foo)) {
        class_addMethod([self class], sel, (IMP)fooMethod, "v@:");
//        这里第一字符v代表函数返回类型void，第二个字符@代表self的类型id，第三个字符:代表_cmd的类型SEL
    }
    return [super resolveInstanceMethod:sel];
}

//快速转发
- (id)forwardingTargetForSelector:(SEL)aSelector {
    if(aSelector == @selector(foo:)){
        return [[Person alloc] init];
    }
    return [super forwardingTargetForSelector:aSelector];
}

//完整消息转发
- (void)forwardInvocation:(NSInvocation *)anInvocation{
    
    SEL sel = anInvocation.selector;
    Person *p = [Person new];
    if ([p respondsToSelector:sel]) {
        [anInvocation invokeWithTarget:p];
    }else{
        [self doesNotRecognizeSelector:sel];
    }
}
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    if (!methodSignature) {
        methodSignature = [NSMethodSignature signatureWithObjCTypes:"v@:"];
    }
    return methodSignature;
}

/*
 
 Objective-C 中给一个对象发送消息会经过以下几个步骤：
 
 1、在对象类的 dispatch table 中尝试找到该消息。如果找到了，跳到相应的函数IMP去执行实现代码；
 
 2、如果没有找到，Runtime 会发送 +resolveInstanceMethod: 或者 +resolveClassMethod: 尝试去 resolve 这个消息；
 3、如果 resolve 方法返回 NO，Runtime 就发送 -forwardingTargetForSelector: 允许你把这个消息转发给另一个对象；
 
 4、如果没有新的目标对象返回， Runtime 就会发送-methodSignatureForSelector: 和 -forwardInvocation: 消息。你可以发送 -invokeWithTarget: 消息来手动转发消息或者发送 -doesNotRecognizeSelector: 抛出异常。
 
 */






#pragma mark - 关联对象
//分类(category)与关联对象(Associated Object)作为objective-c的扩展机制的两个特性：分类，可以通过它来扩展方法；Associated Object，可以通过它来扩展属性

/*
 一、如何关联对象
 
 //关联对象
 void objc_setAssociatedObject(id object, const void *key, id value, objc_AssociationPolicy policy)
 //获取关联的对象
 id objc_getAssociatedObject(id object, const void *key)
 //移除关联的对象
 void objc_removeAssociatedObjects(id object)
 
 参数：
 id object：被关联的对象
 const void *key：关联的key，要求唯一
 id value：关联的对象
 objc_AssociationPolicy policy：内存管理的策略
 
*/


#pragma mark - 方法交换

/*
 Method Swizzing是发生在运行时的，主要用于在运行时将两个Method进行交换，我们可以将Method Swizzling代码写到任何地方，但是只有在这段Method Swilzzling代码执行完毕之后互换才起作用。
 先给要替换的方法的类添加一个Category，然后在Category中的+(void)load方法中添加Method Swizzling方法，我们用来替换的方法也写在这个Category中。
 由于load类方法是程序运行时这个类被加载到内存中就调用的一个方法，执行比较早，并且不需要我们手动调用。
 
注意要点：
 1、Swizzling应该总在+load中执行
 2、Swizzling应该总是在dispatch_once中执行
 3、Swizzling在+load中执行时，不要调用[super load]。如果多次调用了[super load]，可能会出现“Swizzle无效”的假象。
 4、为了避免Swizzling的代码被重复执行，我们可以通过GCD的dispatch_once函数来解决，利用dispatch_once函数内代码只会执行一次的特性。
 
 相关api
 方式一：
 1、class_getInstanceMethod(Class _Nullable cls, SEL _Nonnull name)
 2、method_getImplementation(Method _Nonnull m)
 3、class_addMethod(Class _Nullable cls, SEL _Nonnull name, IMP _Nonnull imp, const char * _Nullable types)
 4、class_replaceMethod(Class _Nullable cls, SEL _Nonnull name, IMP _Nonnull imp,
 const char * _Nullable types)
 
 方式二：
 method_exchangeImplementations(Method _Nonnull m1, Method _Nonnull m2)
 
 
 实践：
 1.统计VC加载次数并打印
 UIViewController+Logging.h
 
 2.防止UI控件短时间多次激活事件,防止过快点击
 UIControl+Limit.m
 
 3、数组越界防止崩溃
 NSArray+CrashHandle.m
 
   思路：对NSArray的objectAtIndex:方法进行Swizzling，替换一个有处理逻辑的方法。但是，这时候还是有个问题，就是类簇的Swizzling没有那么简单。
 在iOS中NSNumber、NSArray、NSDictionary等这些类都是类簇(Class Clusters)，一个NSArray的实现可能由多个类组成。所以如果想对NSArray进行Swizzling，必须获取到其“真身”进行Swizzling，直接对NSArray进行操作是无效的。这是因为Method Swizzling对NSArray这些的类簇是不起作用的。
 因为这些类簇类，其实是一种抽象工厂的设计模式。抽象工厂内部有很多其它继承自当前类的子类，抽象工厂类会根据不同情况，创建不同的抽象对象来进行使用。例如我们调用NSArray的objectAtIndex:方法，这个类会在方法内部判断，内部创建不同抽象类进行操作。
 所以如果我们对NSArray类进行Swizzling操作其实只是对父类进行了操作，在NSArray内部会创建其他子类来执行操作，真正执行Swizzling操作的并不是NSArray自身，所以我们应该对其“真身”进行操作。
 下面列举了NSArray和NSDictionary本类的类名，可以通过Runtime函数取出本类：
 NSArray              __NSArrayI  __NSArray0 __NSSingleObjectArrayI
 NSMutableArray       __NSArrayM
 NSDictionary         __NSDictionaryI
 NSMutableDictionary  __NSDictionaryM
 
 
 */



#pragma mark - 类簇验证
- (void)arrayClassClustersTest{
    
    NSArray * a1 = [NSArray alloc];
    
    NSArray *a2 = [[NSArray alloc]init];
    
    NSArray *a3 = [NSArray array];
    
    NSArray *a4 = [NSArray arrayWithObjects:@1,@2, nil];
    
    NSArray *a5 = @[@1];
    
    NSArray *a6 = [NSArray arrayWithArray:@[@1,@2]];
    
    NSLog(@"a1: %s", object_getClassName(a1));//__NSPlaceholderArray
    NSLog(@"a2: %s", object_getClassName(a2));//__NSArray0
    NSLog(@"a3: %s", object_getClassName(a3));//__NSArray0
    NSLog(@"a4: %s", object_getClassName(a4));//__NSArrayI
    NSLog(@"a5: %s", object_getClassName(a5));//__NSSingleObjectArrayI
    NSLog(@"a6: %s", object_getClassName(a6));//__NSArrayI
    
    NSLog(@"single Array : %@",[a5 objectAtIndex:2]);
    NSLog(@"Array : %@",[a4 objectAtIndex:4]);
    NSLog(@"下标去值法：%@",a4[3]);
    
    NSMutableArray *m1 = [NSMutableArray alloc];
    NSMutableArray *m2 = [[NSMutableArray alloc]init];
    NSMutableArray *m3 = [NSMutableArray arrayWithCapacity:1];
    NSMutableArray *m4 = [[NSMutableArray alloc]initWithArray:@[@1]];
    NSMutableArray *m5 = [NSMutableArray arrayWithObjects:@1,@2, nil];
    NSMutableArray *m6 = [NSMutableArray arrayWithArray:@[@1]];
    
    NSLog(@"m1: %s", object_getClassName(m1));//__NSPlaceholderArray
    NSLog(@"m2: %s", object_getClassName(m2));//__NSArrayM
    NSLog(@"m3: %s", object_getClassName(m3));//__NSArrayM
    NSLog(@"m4: %s", object_getClassName(m4));//__NSArrayM
    NSLog(@"m5: %s", object_getClassName(m5));//__NSArrayM
    NSLog(@"m6: %s", object_getClassName(m6));//__NSArrayM
    
   NSLog(@"可变下标去值法：%@",m5[3]);
    
}


/*
 KVO的实现原理

简单概述下 KVO 的实现：
当你观察一个对象时，一个新的类会动态被创建。这个类继承自该对象的原本的类，并重写了被观察属性的 setter 方法。自然，重写的 setter 方法会负责在调用原 setter方法之前和之后，通知所有观察对象值的更改。最后把这个对象的 isa 指针 ( isa 指针告诉 Runtime 系统这个对象的类是什么 ) 指向这个新创建的子类，对象就神奇的变成了新创建的子类的实例。
 原来，这个中间类，继承自原本的那个类。不仅如此，Apple 还重写了 -class 方法，企图欺骗我们这个类没有变，就是原本那个类
 
 
 
 
 */


@end
