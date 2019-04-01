//
//  ViewController.m
//  InterViewTheme
//
//  Created by iOSDev on 2019/3/18.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic ,readwrite, strong) NSArray *array;

@property (nonatomic, copy) NSMutableArray *mutableArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
}

//1、用@property声明的NSString（或NSArray，NSDictionary）经常使用copy关键字，为什么？如果改用strong关键字，可能造成什么问题？
- (void)deepCopy{
    NSArray *array = @[ @1, @2, @3, @4 ];
    NSMutableArray *mutableArray = [NSMutableArray arrayWithArray:array];
    
    self.array = mutableArray;
    [mutableArray removeAllObjects];;
    NSLog(@"%@",self.array);
    
    [mutableArray addObjectsFromArray:array];
    self.array = [mutableArray copy];//可变集合copy是深拷贝
    [mutableArray removeAllObjects];;
    NSLog(@"%@",self.array);
    
    
    //self.array 用strong修饰时：
    /*2019-03-18 15:56:32.285084+0800 InterViewTheme[27364:6149383] (
     )
     2019-03-18 15:56:32.285174+0800 InterViewTheme[27364:6149383] (
     1,
     2,
     3,
     4
     )*/
    
    //self.array 用copy修饰时：
    /*
     2019-03-18 15:57:35.332260+0800 InterViewTheme[27367:6149782] (
     1,
     2,
     3,
     4
     )
     2019-03-18 15:57:35.332332+0800 InterViewTheme[27367:6149782] (
     1,
     2,
     3,
     4
     )*/
}

//2、这个写法会出什么问题： @property (copy) NSMutableArray *array;
/*
 两个问题：
 1、添加,删除,修改数组内的元素的时候,程序会因为找不到对应的方法而崩溃.因为 copy 就是复制一个不可变 NSArray 的对象；
 2、使用了 atomic 属性会严重影响性能 ；
 
 第1条的相关原因在下文中有论述***《用@property声明的NSString（或NSArray，NSDictionary）经常使用 copy 关键字，为什么？如果改用strong关键字，可能造成什么问题？》*** 以及上文***《怎么用 copy 关键字？》***也有论述。
 */
- (void)mutableObjcetCopy{
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@1,@2,nil];
    self.mutableArray = array;
    [self.mutableArray removeObjectAtIndex:0];
//    -[__NSArrayI removeObjectAtIndex:]: unrecognized selector sent to instance 0x7fcd1bc30460
/*
 在默认情况下，由编译器所合成的方法会通过锁定机制确保其原子性(atomicity)。如果属性具备 nonatomic 特质，则不使用同步锁。请注意，尽管没有名为“atomic”的特质(如果某属性不具备 nonatomic 特质，那它就是“原子的”(atomic))。
 
 在iOS开发中，你会发现，几乎所有属性都声明为 nonatomic。
 
 一般情况下并不要求属性必须是“原子的”，因为这并不能保证“线程安全” ( thread safety)，若要实现“线程安全”的操作，还需采用更为深层的锁定机制才行。例如，一个线程在连续多次读取某属性值的过程中有别的线程在同时改写该值，那么即便将属性声明为 atomic，也还是会读到不同的属性值。
 
 因此，开发iOS程序时一般都会使用 nonatomic 属性。但是在开发 Mac OS X 程序时，使用 atomic 属性通常都不会有性能瓶颈。
 */
}

//3、深复制与浅复制
/*
 immutable对象进行 copy，是指针复制， mutableCopy 是内容复制；对 mutable 对象进行 copy 和 mutableCopy 都是内容复制。但是：集合对象的内容复制仅限于对象本身，对象元素仍然是指针复制
 
 [immutableObject copy] // 浅复制
 [immutableObject mutableCopy] //单层深复制
 [mutableObject copy] //单层深复制
 [mutableObject mutableCopy] //单层深复制
 
 */


//4、oc方法的本质
//[obj foo];在objc编译时，会被转意为：objc_msgSend(obj, @selector(foo));。

//5、什么时候会报unrecognized selector的异常？
//当调用该对象上某个方法,而该对象上没有实现这个方法的时候， 可以通过“消息转发”进行解决。
/*
 objc在向一个对象发送消息时，runtime库会根据对象的isa指针找到该对象实际所属的类，然后在该类中的方法列表以及其父类方法列表中寻找方法运行，如果，在最顶层的父类中依然找不到相应的方法时，程序在运行时会挂掉并抛出异常unrecognized selector sent to XXX 。但是在这之前，objc的运行时会给出三次拯救程序崩溃的机会：
 
 Method resolution
 objc运行时会调用+resolveInstanceMethod:或者 +resolveClassMethod:，让你有机会提供一个函数实现。如果你添加了函数，那运行时系统就会重新启动一次消息发送的过程，否则 ，运行时就会移到下一步，消息转发（Message Forwarding）。
 
 Fast forwarding
 如果目标对象实现了-forwardingTargetForSelector:，Runtime 这时就会调用这个方法，给你把这个消息转发给其他对象的机会。 只要这个方法返回的不是nil和self，整个消息发送的过程就会被重启，当然发送的对象会变成你返回的那个对象。否则，就会继续Normal Fowarding。 这里叫Fast，只是为了区别下一步的转发机制。因为这一步不会创建任何新的对象，但下一步转发会创建一个NSInvocation对象，所以相对更快点。 3. Normal forwarding
 
 这一步是Runtime最后一次给你挽救的机会。首先它会发送-methodSignatureForSelector:消息获得函数的参数和返回值类型。如果-methodSignatureForSelector:返回nil，Runtime则会发出-doesNotRecognizeSelector:消息，程序这时也就挂掉了。如果返回了一个函数签名，Runtime就会创建一个NSInvocation对象并发送-forwardInvocation:消息给目标对象。
 */


//6、下面的代码输出什么？
#if 0

@implementation Son : Father
- (id)init
{
    self = [super init];
    if (self) {
        NSLog(@"%@", NSStringFromClass([self class]));
        NSLog(@"%@", NSStringFromClass([super class]));
    }
    return self;
}
@end
//都输出 Son
//NSStringFromClass([self class]) = Son
//NSStringFromClass([super class]) = Son
/*
 关于 Objective-C 中对 self 和 super 的理解。
 我们都知道：self 是类的隐藏参数，指向当前调用方法的这个类的实例。那 super 呢？
 
 很多人会想当然的认为“ super 和 self 类似，应该是指向父类的指针吧！”。这是很普遍的一个误区。其实 super 是一个 Magic Keyword， 它本质是一个编译器标示符，和 self 是指向的同一个消息接受者！他们两个的不同点在于：super 会告诉编译器，调用 class 这个方法时，要去父类的方法，而不是本类里的。
 
 上面的例子不管调用[self class]还是[super class]，接受消息的对象都是当前 Son ＊xxx 这个对象。
 
 当使用 self 调用方法时，会从当前类的方法列表中开始找，如果没有，就从父类中再找；而当使用 super 时，则从父类的方法列表中开始找。然后调用父类的这个方法。
 
 这也就是为什么说“不推荐在 init 方法中使用点语法”，如果想访问实例变量 iVar 应该使用下划线（ _iVar ），而非点语法（ self.iVar ）。
 */
#endif


//7、runloop和线程有什么关系？






@end
