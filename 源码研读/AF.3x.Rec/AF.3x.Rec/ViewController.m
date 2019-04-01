//
//  ViewController.m
//  AF.3x.Rec
//
//  Created by iOSDev on 2019/3/19.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) NSInteger ticketSurplusCount;

@property (nonatomic, strong) dispatch_semaphore_t semaphoreLock;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTicketNotSave];
    
}



/*
    GCD
 */
#pragma mark - 队列与线程的关系
/*
 与其说GCD是面向线程的，不如说是面向队列的。 **它隐藏了内部线程的调度。
 
 我们所做的仅仅是创建不同的队列，把Block追加到队列中去执行，而队列是FIFO（先进先出）的。
 它会按照我们追加的Block的顺序，在综合我们调用的gcd的api（sync、async、dispatch_barrier_async等等），以及根据系统负载来增减线程并发数， 来调度线程执行Block。
 */
//ex.1
- (void)syncConcurrentQueue{
    dispatch_queue_t queue1 = dispatch_queue_create("并行", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue1, ^{
        NSLog(@"%@",[NSThread currentThread]);
    });
//    输出结果：<NSThread: 0x60000007fc80>{number = 1, name = main}
//    我们在主线程中，往一个并行queue，以sync的方式提交了一个Block，结果Block在主线程中执行。
}

//ex.2
- (void)asyncInMainQueue{
    
    dispatch_queue_t queue1 = dispatch_queue_create("并行", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue1, ^{
        NSLog(@"%@",[NSThread currentThread]);
    });
//    输出结果：<NSThread: 0x7fea68607750>{number = 2, name = (null)}
//    我们在主线程中用aync方式提交一个Block，结果Block在分线程中执行。
}

//ex.3
- (void)syncAndAsyncInMianQueue{
//    我们不能直接在主线程用sync如下的形式去提交Block，否则会引起死锁：
    dispatch_queue_t queue1 = dispatch_queue_create("并行", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue1, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"%@",[NSThread currentThread]);
        });
    });
//    输出结果：<NSThread: 0x60000007fc80>{number = 1, name = main}
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@",[NSThread currentThread]);
    });
//    输出结果：<NSThread: 0x60000007fc80>{number = 1, name = main}
    
}

/*
 结论：
 
 往主队列提交Block，无论是sync，还是async，都是在主线程中执行。
 往非主队列中提交，如果是sync，会在当前提交Block的线程中执行。如果是async，则会在分线程中执行。
 
 上文需要注意以下两点:
 这里的sync，async并不局限于dispatch_sync、dispatch_async，而指的是GCD中所有同步异步的API。
 
 这里我们用的是并行queue，如果用串行queue，结果也是一样的。唯一的区别是并行queue会权衡当前系统负载，去同时并发几条线程去执行Block，而串行queue中，始终只会在同一条线程中执行Block。
 
 */


#pragma mark - GCD的死锁
- (void)exOfGcdDeadLock{
    dispatch_sync(dispatch_get_main_queue(), ^{
        NSLog(@"任务一");
    });
    NSLog(@"任务二");
    
    //消除死锁
    dispatch_sync(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"任务一");
    });
    NSLog(@"任务二");
    /*
     我们在主线程中，往全局队列同步提交了Block，因为全局队列和主队列是两个队列，所以任务一的执行，并不需要等待任务二。所以等任务一结束，任务二也可以被执行。
     当然这里因为提交Block所在队列，Block被执行的队列是完全不同的两个队列，所以这里用串行queue，也是不会死锁的
     */
}
/*
 死锁的流程：
 如上，在主线程中，往主队列同步提交了任务一。因为往queue中提交Block，总是追加在队列尾部的，而queue执行Block的顺序为先进先出（FIFO），所以任务一需要在当前队列执行完它之前所有的任务（例如任务二），才能轮到它被执行。（注意，这里引起死锁并不是因为任务二，哪怕删去任务二，这里仍然会死锁。这里只是为了举例说明，看很多人都在费解这一点，特此说明...）
 而任务二因为任务一的sync，被阻塞了，它需要等任务一执行完才能被执行。两者互相等待对方执行完，才能执行，程序被死锁在这了。
 这里需要注意这里死锁的很重要一个条件也因为主队列是一个串行的队列(主队列中只有一条主线程)。如果我们如下例，在并行队列中提交，则不会造成死锁：
 */
- (void)asyncNoDeadLock{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_sync(dispatch_get_global_queue(0, 0), ^{
            NSLog(@"任务一");
        });
        NSLog(@"任务二");
    });
/*
 原因是并行队列中任务一虽被提交仍然是在queue的队尾，在任务二之后，但是因为是并行的，所以任务一并不会一直等任务二结束才去执行，而是直接执行完。此时任务二的因为任务一的结束，sync阻塞也就消除，任务二得以执行。
 */
}

/*sync的阻塞机制*/
/*
 sync提交Block，首先是阻塞的当前提交Block的线程（简单理解下就是阻塞sync之后的代码）。例如我们之前举的例子中，sync总是阻塞了任务二的执行。
 而在队列中，轮到sync提交的Block，仅仅阻塞串行queue，而不会阻塞并行queue
 如果同步（sync）提交一个Block到一个串行队列，而提交Block这个动作所处的线程，也是在当前队列，就会引起死锁
 */

#pragma mark - 4个gcd方法的区别
/*
 dispatch_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
 dispatch_sync(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
 dispatch_barrier_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
 dispatch_barrier_sync(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
 */

//ex.1
- (void)dispatch_barrier_async{
    
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        // 任务1
        NSLog(@"1");
    });
    dispatch_async(queue, ^{
        // 任务2
        NSLog(@"2");
    });
    dispatch_async(queue, ^{
        // 任务3
        NSLog(@"3");
    });
    dispatch_barrier_async(queue, ^{
        // 任务4
        NSLog(@"4");
    });
    dispatch_async(queue, ^{
        // 任务5
        NSLog(@"5");
    });
    dispatch_async(queue, ^{
        // 任务6
        NSLog(@"6");
    });
    /*任务1，2，3的顺序不一定，4在中间，最后是5，6任务顺序不一定。它就像一个栅栏一样，挡在了一个并行队列中间。
     当然这里有一点需要注意的是：dispatch_barrier_(a)sync只在自己创建的并发队列上有效，在全局(Global)并发队列、串行队列上，效果跟dispatch_(a)sync效果一样。
     */
    /*应用场景
     例如我们在一个读写操作中：
     我们要知道一个数据，读与读之间是可以用线程并行的，但是写与写、写与读之间，就必须串行同步或者使用线程锁来保证线程安全。但是我们有了dispatch_barrier_async，我们就可以如下使用：
     dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
     dispatch_async(queue, ^{
     //读操作
     });
     dispatch_async(queue, ^{
     // 读操作
     });
     dispatch_barrier_async(queue, ^{
     // 写操作
     });
     dispatch_barrier_async(queue, ^{
     // 写操作
     });
     dispatch_async(queue, ^{
     // 读操作
     });
     这样写操作的时候，始终只有它这一条线程在进行。而读操作一直是并行的。这么做充分利用了多线程的优势，还不需要加锁，减少了相当一部分的性能开销。实现了读写操作的线程安全。
     */
}

/*
 dispatch_barrier_sync这个方法和dispatch_barrier_async作用几乎一样，都可以在并行queue中当做栅栏。
 唯一的区别就是：dispatch_barrier_sync有GCD的sync共有特性，会阻塞提交Block的当前线程，而dispatch_barrier_async是异步提交，不会阻塞。
 */
/*
 dispatch_sync，我们来讲讲它和dispatch_barrier_sync的区别。二者因为是sync提交，所以都是阻塞当前提交Block线程。
 而它俩唯一的区别是：dispatch_sync并不能阻塞并行队列
 */

//ex.2
- (void)diffcientOfDispacth_syncAndDispatch_barrier_sync{
    
    dispatch_queue_t queue = dispatch_queue_create("并行", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(queue, ^{
        dispatch_async(queue, ^{
            NSLog(@"任务二");
        });
        dispatch_async(queue, ^{
            NSLog(@"任务三");
        });
        //睡眠2秒
        [NSThread sleepForTimeInterval:2];
        NSLog(@"任务一");
    });
    /*输出结果 :
     任务三
     任务二
     任务一*/
//    并行队列没有被sync所阻塞。
    
//    dispatch_barrier_sync可以阻塞并行队列（栅栏作用的体现）：
    dispatch_queue_t queue1 = dispatch_queue_create("concurrent", DISPATCH_QUEUE_CONCURRENT);
    dispatch_barrier_sync(queue1, ^{
        dispatch_async(queue1, ^{
            NSLog(@"任务五");
        });
        dispatch_async(queue1, ^{
            NSLog(@"任务六");
        });
        //睡眠2秒
        [NSThread sleepForTimeInterval:2];
        NSLog(@"任务四");
    });
    /*输出结果 :
     任务一
     任务二
     任务三*/
}


- (void)dispatchOnceToken{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
    });
    
}
//快速迭代
/*
 dispatch_apply按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束。
 如果是在串行队列中使用 dispatch_apply，那么就和 for 循环一样，按顺序同步执行
 
 ex:我们可以利用并发队列进行异步执行。比如说遍历 0~5 这6个数字，for 循环的做法是每次取出一个元素，逐个遍历。dispatch_apply 可以 在多个线程中同时（异步）遍历多个数字。
 */
- (void)dispathApply{
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSLog(@"apply---begin");
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"%zd---%@",index, [NSThread currentThread]);
    });
    NSLog(@"apply---end");
}


//dispatch_group 队列组

- (void)dispatchGroupNotify{
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"UI刷新");
    });
    
}

// dispatch_group_wait：暂停当前线程（阻塞当前线程），等待指定的 group 中的任务执行完成后，才会往下继续执行
- (void)dispatchGroupWait{
    
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"group---begin");
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
    });
    
    // 等待上面的任务全部完成后，会往下继续执行（会阻塞当前线程）
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    NSLog(@"group---end");
//    当所有任务执行完成之后，才执行 dispatch_group_wait 之后的操作。但是，使用dispatch_group_wait 会阻塞当前线程
}
/**
 * 队列组 dispatch_group_enter、dispatch_group_leave
 */
- (void)groupEnterAndLeave{
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"2---%@",[NSThread currentThread]);      // 打印当前线程
        }
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"UI刷新");
    });
//当所有任务执行完成之后，才执行 dispatch_group_notify 中的任务。这里的dispatch_group_enter、dispatch_group_leave组合，其实等同于dispatch_group_async。
}

/**
 GCD 中的信号量是指 Dispatch Semaphore，是持有计数的信号
 
 Dispatch Semaphore 提供了三个函数。
 dispatch_semaphore_create：创建一个Semaphore并初始化信号的总量
 dispatch_semaphore_signal：发送一个信号，让信号总量加1
 dispatch_semaphore_wait：可以使总信号量减1，当信号总量为0时就会一直等待（阻塞所在线程），否则就可以正常执行。
 信号量的使用前提是：想清楚你需要处理哪个线程等待（阻塞），又要哪个线程继续执行，然后使用信号量。
 Dispatch Semaphore 在实际开发中主要用于：
 1、保持线程同步，将异步执行任务转换为同步执行任务
 2、保证线程安全，为线程加锁
 
 */
- (void)dispatchSemaphore{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block int number = 0;
    dispatch_async(queue, ^{
        // 追加任务1
        [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
        NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        number = 100;
        
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
     NSLog(@"semaphore---end,number = %zd",number);
    
}
//ex：异步执行耗时任务，并使用异步执行的结果进行一些额外的操作。换句话说，相当于，将将异步执行任务转换为同步执行任务。比如说：AFNetworking 中 AFURLSessionManager.m 里面的 tasksForKeyPath: 方法。通过引入信号量的方式，等待异步执行任务结果，获取到 tasks，然后再返回该 tasks。
#if 0
- (NSArray *)tasksForKeyPath:(NSString *)keyPath {
    __block NSArray *tasks = nil;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [self.session getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(dataTasks))]) {
            tasks = dataTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(uploadTasks))]) {
            tasks = uploadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(downloadTasks))]) {
            tasks = downloadTasks;
        } else if ([keyPath isEqualToString:NSStringFromSelector(@selector(tasks))]) {
            tasks = [@[dataTasks, uploadTasks, downloadTasks] valueForKeyPath:@"@unionOfArrays.self"];
        }
        
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return tasks;
}
#endif

// Dispatch Semaphore 线程安全和线程同步（为线程加锁）
/**
 * 非线程安全：不使用 semaphore
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketNotSave{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    self.ticketSurplusCount = 50;
    
    dispatch_queue_t q1 = dispatch_queue_create("www.af.queue1",DISPATCH_QUEUE_SERIAL);
    
    dispatch_queue_t q2 = dispatch_queue_create("www.af.queue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(q1, ^{
        [weakSelf saleTicketNotSafe];
    });
    
    dispatch_async(q2, ^{
        [weakSelf saleTicketNotSafe];
    });
    
}

- (void)saleTicketNotSafe{
    while (1) {
        if (self.ticketSurplusCount > 0) {  //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        } else { //如果已卖完，关闭售票窗口
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

- (void)initTicketSave{
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    _semaphoreLock = dispatch_semaphore_create(1);
    
    self.ticketSurplusCount = 50;
    
    // queue1 代表北京火车票售卖窗口
    dispatch_queue_t queue1 = dispatch_queue_create("net.bujige.testQueue1", DISPATCH_QUEUE_SERIAL);
    // queue2 代表上海火车票售卖窗口
    dispatch_queue_t queue2 = dispatch_queue_create("net.bujige.testQueue2", DISPATCH_QUEUE_SERIAL);
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(queue1, ^{
        [weakSelf saleTicketSafe];
    });
    
    dispatch_async(queue2, ^{
        [weakSelf saleTicketSafe];
    });
}

- (void)saleTicketSafe{
    
    while (1) {
        dispatch_semaphore_wait(_semaphoreLock, DISPATCH_TIME_FOREVER);
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%d 窗口：%@", self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }else {
             NSLog(@"所有火车票均已售完");
            dispatch_semaphore_signal(_semaphoreLock);
             break;
        }
        
        dispatch_semaphore_signal(_semaphoreLock);
    }
}

@end
