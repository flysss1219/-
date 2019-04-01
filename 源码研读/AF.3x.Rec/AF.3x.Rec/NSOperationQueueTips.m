//
//  NSOperationQueueTips.m
//  AF.3x.Rec
//
//  Created by iOSDev on 2019/3/19.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "NSOperationQueueTips.h"

@interface NSOperationQueueTips ()

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, assign) NSInteger ticketSurplusCount;

@end

@implementation NSOperationQueueTips


#pragma mark - NSOperation、NSOperationQueue

/*为什么要使用 NSOperation、NSOperationQueue？*/
/*
 1、可添加完成的代码块，在操作完成后执行。
 2、添加操作之间的依赖关系，方便的控制执行顺序。
 3、设定操作执行的优先级。
 4、可以很方便的取消一个操作的执行。
 5、使用 KVO 观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled。
 
 */
//1、 NSOperation
/*
 执行操作的意思，换句话说就是你在线程中执行的那段代码。
 在 GCD 中是放在 block 中的。在 NSOperation 中，我们使用 NSOperation 子类 NSInvocationOperation、NSBlockOperation，或者自定义子类来封装操作。
 */

//2、NSOperationQueue
/*
 这里的队列指操作队列，即用来存放操作的队列。不同于 GCD 中的调度队列 FIFO（先进先出）的原则。NSOperationQueue 对于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的依赖关系），然后进入就绪状态的操作的开始执行顺序（非结束执行顺序）由操作之间相对的优先级决定（优先级是操作对象自身的属性）。
 操作队列通过设置最大并发操作数（maxConcurrentOperationCount）来控制并发、串行。
 NSOperationQueue 为我们提供了两种不同类型的队列：主队列和自定义队列。主队列运行在主线程之上，而自定义队列在后台执行。
 
 */

/**
* 使用子类 NSInvocationOperation
*/
- (void)useInvocationOperation{
    NSInvocationOperation *op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(task1) object:nil];
    [op start];
}
/**
 * 任务1
 */
- (void)task1 {
    for (int i = 0; i < 2; i++) {
        [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
    }
}
/*
 可以看到：在没有使用 NSOperationQueue、在主线程中单独使用使用子类 NSInvocationOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。
 */

/**
 * 使用子类 NSBlockOperation
 */
- (void)useBlockOperation{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op start];
}

- (void)addExcutionToBlockOperation{
    
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"5---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"6---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    // 3.调用 start 方法开始执行操作
    [op start];
}
/*
 使用子类 NSBlockOperation，并调用方法 AddExecutionBlock: 的情况下，blockOperationWithBlock:方法中的操作 和 addExecutionBlock: 中的操作是在不同的线程中异步执行的。而且，这次执行结果中 blockOperationWithBlock:方法中的操作也不是在当前线程（主线程）中执行的。从而印证了blockOperationWithBlock: 中的操作也可能会在其他线程（非当前线程）中执行。
 一般情况下，如果一个 NSBlockOperation 对象封装了多个操作。NSBlockOperation 是否开启新线程，取决于操作的个数。如果添加的操作的个数多，就会自动开启新线程。当然开启的线程数是由系统来决定的
 */

//使用自定义继承自 NSOperation 的子类
/*如果使用子类 NSInvocationOperation、NSBlockOperation 不能满足日常需求，我们可以使用自定义继承自 NSOperation 的子类。可以通过重写 main 或者 start 方法 来定义自己的 NSOperation 对象。重写main方法比较简单，我们不需要管理操作的状态属性 isExecuting 和 isFinished。当 main 执行完返回的时候，这个操作就结束了。
 */

//NSOperationQueue

/*
 主队列
 凡是添加到主队列中的操作，都会放到主线程中执行（注：不包括操作使用addExecutionBlock:添加的额外操作，额外操作可能在其他线程执行，感谢指正）
 // 主队列获取方法
 NSOperationQueue *queue = [NSOperationQueue mainQueue];
 
 自定义队列（非主队列）
 添加到这种队列中的操作，就会自动放到子线程中执行。
 同时包含了：串行、并发功能。
 // 自定义队列创建方法
 NSOperationQueue *queue = [[NSOperationQueue alloc] init];
 
 
 */
- (void)addOperationToOperationQueue{
    
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [op1 addExecutionBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"5---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperation:op1];
    [queue addOperation:op2];
//    使用 NSOperation 子类创建操作，并使用 addOperation: 将操作加入到操作队列后能够开启新线程，进行并发执行。
}

- (void)addOperationWithBlockToQueue{
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.使用 addOperationWithBlock: 添加操作到队列中
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
}


// NSOperationQueue 控制串行执行、并发执行
/**
 * 设置 MaxConcurrentOperationCount（最大并发操作数）
 */
- (void)setMaxConcurrentOperationCount {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.设置最大并发操作数
    queue.maxConcurrentOperationCount = 1; // 串行队列
    // queue.maxConcurrentOperationCount = 2; // 并发队列
    // queue.maxConcurrentOperationCount = 8; // 并发队列
    
    // 3.添加操作
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"3---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [queue addOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"4---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
/*
 当最大并发操作数为1时，操作是按顺序串行执行的，并且一个操作完成之后，下一个操作才开始执行。当最大操作并发数为2时，操作是并发执行的，可以同时执行两个操作。而开启线程数量是由系统决定的，不需要我们来管理
 */
}


//NSOperation 操作依赖
/**
 * 操作依赖
 * 使用方法：addDependency:
 */
- (void)addDependency {
    
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    // 2.创建操作
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    // 3.添加依赖
    [op2 addDependency:op1]; // 让op2 依赖于 op1，则先执行op1，在执行op2
    
    // 4.添加操作到队列中
    [queue addOperation:op1];
    [queue addOperation:op2];
    
//    通过添加操作依赖，无论运行几次，其结果都是 op1 先执行，op2 后执行。
}


//NSOperation 优先级
/*
 NSOperation 提供了queuePriority（优先级）属性，queuePriority属性适用于同一操作队列中的操作，不适用于不同操作队列中的操作。默认情况下，所有新创建的操作对象优先级都是NSOperationQueuePriorityNormal。但是我们可以通过setQueuePriority:方法来改变当前操作在同一队列中的执行优先级。
 
 // 优先级的取值
 typedef NS_ENUM(NSInteger, NSOperationQueuePriority) {
 NSOperationQueuePriorityVeryLow = -8L,
 NSOperationQueuePriorityLow = -4L,
 NSOperationQueuePriorityNormal = 0,
 NSOperationQueuePriorityHigh = 4,
 NSOperationQueuePriorityVeryHigh = 8
 };
 于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的依赖关系），然后进入就绪状态的操作的开始执行顺序（非结束执行顺序）由操作之间相对的优先级决定（优先级是操作对象自身的属性）
 那么，什么样的操作才是进入就绪状态的操作呢？
 
 当一个操作的所有依赖都已经完成时，操作对象通常会进入准备就绪状态，等待执行。
 
 举个例子，现在有4个优先级都是 NSOperationQueuePriorityNormal（默认级别）的操作：op1，op2，op3，op4。其中 op3 依赖于 op2，op2 依赖于 op1，即 op3 -> op2 -> op1。现在将这4个操作添加到队列中并发执行。
 
 因为 op1 和 op4 都没有需要依赖的操作，所以在 op1，op4 执行之前，就是处于准备就绪状态的操作。
 而 op3 和 op2 都有依赖的操作（op3 依赖于 op2，op2 依赖于 op1），所以 op3 和 op2 都不是准备就绪状态下的操作。
 
 理解了进入就绪状态的操作，那么我们就理解了queuePriority 属性的作用对象。
 
 
 queuePriority 属性决定了进入准备就绪状态下的操作之间的开始执行顺序。并且，优先级不能取代依赖关系。
 如果一个队列中既包含高优先级操作，又包含低优先级操作，并且两个操作都已经准备就绪，那么队列先执行高优先级操作。比如上例中，如果 op1 和 op4 是不同优先级的操作，那么就会先执行优先级高的操作。
 如果，一个队列中既包含了准备就绪状态的操作，又包含了未准备就绪的操作，未准备就绪的操作优先级比准备就绪的操作优先级高。那么，虽然准备就绪的操作优先级低，也会优先执行。优先级不能取代依赖关系。如果要控制操作间的启动顺序，则必须使用依赖关系。
 
 */


//线程间的通信
- (void)threadCommunication{
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
        
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"UI刷新");
        }];
    }];
    
}


//线程同步与线程安全
/**
 * 非线程安全：不使用 NSLock
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)sellTicketWithNoLock{
    
    NSLog(@"currentThread--- %@",[NSThread currentThread]);// 打印当前线程
    
    self.lock = [[NSLock alloc]init];
    self.ticketSurplusCount = 50;
    
    NSOperationQueue *q1 = [[NSOperationQueue alloc]init];
    q1.maxConcurrentOperationCount = 1;
    
    NSOperationQueue *q2 = [[NSOperationQueue alloc]init];
    q2.maxConcurrentOperationCount = 1;
    
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        //        [self saleTicketNotSafe];
        [self saleTicketSafe];
        
    }];
    
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        //        [self saleTicketNotSafe];
        [self saleTicketSafe];
    }];
    
    
    [q1 addOperation:op1];
    [q2 addOperation:op2];
    
}

- (void)saleTicketNotSafe{
    while (1) {
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount--;
            NSLog(@"%@",[NSString stringWithFormat:@"剩余票数：%d,售票窗口:%@",self.ticketSurplusCount,[NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }else{
            NSLog(@"所有票已售完");
            break;
        }
    }
}

- (void)saleTicketSafe{
    
    while (1) {
        [self.lock lock];
        
        if (self.ticketSurplusCount > 0)  {
            self.ticketSurplusCount--;
            NSLog(@"%@",[NSString stringWithFormat:@"剩余票数：%d,售票窗口:%@",self.ticketSurplusCount,[NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        
        [self.lock unlock];
        
        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有票已售完");
            break;
        }
    }
    
    
    //    @synchronized (self) {
    //        while (1) {
    //
    //            if (self.ticketSurplusCount > 0) {
    //                self.ticketSurplusCount--;
    //                NSLog(@"%@",[NSString stringWithFormat:@"剩余票数：%d,售票窗口:%@",self.ticketSurplusCount,[NSThread currentThread]]);
    //                [NSThread sleepForTimeInterval:0.2];
    //            }else{
    //                NSLog(@"所有票已售完");
    //                break;
    //            }
    //        }
    //    }
}

/*
 相关链接
 1、http://blog.leichunfeng.com/blog/2015/07/29/ios-concurrency-programming-operation-queues/
 
 
 */





@end
