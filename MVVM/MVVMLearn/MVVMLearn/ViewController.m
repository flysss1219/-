//
//  ViewController.m
//  MVVMLearn
//
//  Created by iOSDev on 2019/1/11.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveObjC.h>
#import "FlagItem.h"
#import <RACReturnSignal.h>

#define Screen_width  [UIScreen mainScreen].bounds.size.width
#define Screen_height [UIScreen mainScreen].bounds.size.height;

@interface ViewController ()

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UITextField *passwordField;

@property (nonatomic, strong) UIButton *loginBtn;

@property (nonatomic, strong) UILabel *titleLabel;


//
@property (nonatomic, strong) RACCommand *command;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self eventObserve];
    
//    [self delegateCallBack];
   
//    [self receiveNotificaiton];
    
//    [self kvoObserve];
    
//    [self siganlCreateAndSubscribe];
//
//    [self subjectSimpleUse];
    
//    [self sequenceAndTupleUse];
    
//    [self racCommandUse];
    
//    [self multicastConnectionUse];
    
//    [self RACFlattenMapUse];
    
//    [self differentOfMapFlattenMap];
    
//    [self racMethodOfConcat];
    
//    [self racMethodOfThen];
//
//    [self racMethdOfMerge];
    
//    [self racMethodOfZip];
//
//    [self racMethodOfCombineLatest];
    
//    [self racMethodOfReduce];
//
//    [self racMethodOfFilter];
    
//    [self racMethodOfIgnore];
    
    [self racMethodOfDistinctUntilChanged];
    
}

//事件监听
- (void)eventObserve{
    [self.view addSubview:self.textField];
    [self.view addSubview:self.passwordField];
//    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.loginBtn];
    //1 textField的target—action监听
//    [[self.textField rac_signalForControlEvents:UIControlEventEditingChanged] subscribeNext:^(__kindof UITextField * _Nullable x) {
//        NSLog(@"change: %@",x.text);
//    }];
    //2 文字监听
    [[self.textField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"change: %@",x);
    }];
    
    [[self.passwordField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        
    }];
    
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]init];
//    [[tap rac_gestureSignal] subscribeNext:^(__kindof UIGestureRecognizer * _Nullable x) {
//        NSLog(@"点击了label");
//        NSMutableArray *dataArray = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", nil];
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"SendData" object:dataArray];
//    }];
//    [self.titleLabel addGestureRecognizer:tap];
    
    RACSignal *validUsernameSignal = [self.textField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidUserName:value]);
    }];
    RACSignal *validPasswordSignal = [self.passwordField.rac_textSignal map:^id _Nullable(NSString * _Nullable value) {
        return @([self isValidPassword:value]);
    }];
//    [[validUsernameSignal map:^id _Nullable(NSNumber* username) {
//        return [username boolValue]? [UIColor blueColor]:[UIColor cyanColor];
//    }] subscribeNext:^(UIColor* x) {
//        self.textField.backgroundColor = x;
//    }];
//  高级实现
    RAC(self.textField,backgroundColor) = [validUsernameSignal map:^id _Nullable(NSNumber*usernameValid) {
        return [usernameValid boolValue]?[UIColor blueColor]:[UIColor cyanColor];
    }];
    RAC(self.passwordField,backgroundColor) = [validPasswordSignal map:^id _Nullable(NSNumber* passwordValid) {
        return [passwordValid boolValue]?[UIColor blueColor]:[UIColor cyanColor];
    }];
/*
 小结：RAC宏将一个信号的输出和一个对象的属性绑定起来。宏接受两个参数，第一个是包含改变属性的对象，第二个为属性的名字。每次当信号发出一个新的事件，事件的值就会传递给绑定的属性。
 */
    
    RACSignal *loginActiveSignal = [RACSignal combineLatest:@[validUsernameSignal,validPasswordSignal] reduce:^id _Nullable(NSNumber *validUsername,NSNumber* validPassword){
        return @([validUsername boolValue] && [validPassword boolValue]);
    }];
    
    [loginActiveSignal subscribeNext:^(NSNumber *loginActive) {
        self.loginBtn.enabled = [loginActive boolValue];
        if (![loginActive boolValue]) {
            self.loginBtn.backgroundColor = [UIColor grayColor];
        }else{
            self.loginBtn.backgroundColor = [UIColor redColor];
        }
    }];
    
//    [[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
//        NSLog(@"Login Button Clicked");
//    }];
    
//    [[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] map:^id _Nullable(id x) {
//        return [self loginSignal];
//    }] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"Login reslut: %@",x);
//    }];
//    [[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] flattenMap:^__kindof RACSignal * _Nullable(__kindof UIControl * _Nullable value) {
//        return [self loginSignal];
//    }] subscribeNext:^(id  _Nullable x) {
//        BOOL success = [x boolValue];
//        NSLog(@"Login reslut: %@",x);
//    }];
    
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(__kindof UIControl * _Nullable x) {
        self.loginBtn.enabled = NO;
    }] flattenMap:^__kindof RACSignal * _Nullable(__kindof UIControl * _Nullable value) {
        return [self loginSignal];
    }] subscribeNext:^(id  _Nullable x) {
        BOOL success = [x boolValue];
        NSLog(@"Login reslut: %@",x);
    }];
//    注意doNext:是一个副作用，所以block没有返回任何值；它并不影响事件的内容
    
}

- (RACSignal *)loginSignal{
    return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        sleep(1);
        NSLog(@"网络请求模拟");
        [subscriber sendNext:@(YES)];
        [subscriber sendCompleted];
        return nil;
    }];
}

- (BOOL)isValidUserName:(NSString*)text{
   return  [text isEqualToString:@"username"]?YES:NO;
}
- (BOOL)isValidPassword:(NSString*)text{
    return  [text isEqualToString:@"123456"]?YES:NO;
}


// RAC代理
- (void)delegateCallBack{
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"RAC" message:@"RAC TEST" delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"other", nil];
//    [[self rac_signalForSelector:@selector(alertView:clickedButtonAtIndex:) fromProtocol:@protocol(UIAlertViewDelegate)] subscribeNext:^(RACTuple *tuple) {
//        NSLog(@"alert1 %@",tuple.first);
//        NSLog(@"alert2 %@",tuple.second);
//        NSLog(@"alert3 %@",tuple.third);
//    }];
//    or
    [[alertView rac_buttonClickedSignal] subscribeNext:^(NSNumber * _Nullable x) {
        NSLog(@"index:%@",x);
    }];
    
    [alertView show];
}

//rac notification
- (void)receiveNotificaiton{
    
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:@"SendData" object:nil] subscribeNext:^(NSNotification * _Nullable x) {
        NSLog(@"%@", x.name);
        NSLog(@"%@", x.object);
    }];
    
}

//rac kvo
- (void)kvoObserve{
    
    UIScrollView *scrolView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, 400)];
    scrolView.contentSize = CGSizeMake(200, 800);
    scrolView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:scrolView];
    [RACObserve(scrolView, contentOffset) subscribeNext:^(id x) {
        NSLog(@"success");
    }];
    
   
}

- (UITextField*)textField{
    if (!_textField) {
        _textField = [[UITextField alloc]initWithFrame:CGRectMake(12, 50, Screen_width-24, 30)];
        _textField.placeholder = @"请输入";
    }
    return _textField;
}

- (UITextField*)passwordField{
    if (!_passwordField) {
        _passwordField = [[UITextField alloc]initWithFrame:CGRectMake(12, 90, Screen_width-24, 30)];
        _passwordField.placeholder = @"请输入密码";
    }
    return _passwordField;
}
- (UIButton*)loginBtn{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.frame = CGRectMake(20, 150, Screen_width-40, 40);
        [_loginBtn setTitle:@"Login" forState:UIControlStateNormal];
        _loginBtn.backgroundColor = [UIColor redColor];
        
    }
    return _loginBtn;
}
- (UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(12,90, Screen_width-24, 20)];
        _titleLabel.text = @"给label添加手势";
        _titleLabel.userInteractionEnabled = YES;
    }
    return _titleLabel;
}

#pragma mark - siganl创建与订阅
- (void)siganlCreateAndSubscribe{
    // 1.创建信号
    RACSignal *siganl = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
       // block调用时刻：每当有订阅者订阅信号，就会调用block。
        NSLog(@"发送信号");
        // 2.发送信号
        [subscriber sendNext:@1];
        // 如果不在发送数据，最好发送信号完成，内部会自动调用[RACDisposable disposable]取消订阅信号。
        [subscriber sendCompleted];
        
        return [RACDisposable disposableWithBlock:^{
            // block调用时刻：当信号发送完成或者发送错误，就会自动执行这个block,取消订阅信号。
            // 执行完Block后，当前信号就不在被订阅了。
            NSLog(@"信号被销毁");
        }];
    }];
    
    // 3.订阅信号,才会激活信号.
    [siganl subscribeNext:^(id  _Nullable x) {
        // block调用时刻：每当有信号发出数据，就会调用block.
        NSLog(@"接收到数据：%@",x);
    }];
    
    
    
}
#pragma mark - RACSubject/RACReplaySubject
- (void)subjectSimpleUse{
    // RACSubject使用步骤
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 3.发送信号 sendNext:(id)value
    
    // RACSubject:底层实现和RACSignal不一样。
    // 1.调用subscribeNext订阅信号，只是把订阅者保存起来，并且订阅者的nextBlock已经赋值了。
    // 2.调用sendNext发送信号，遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    
    // 1.创建信号
    RACSubject *subject = [RACSubject subject];
    // 2.订阅信号
    [subject subscribeNext:^(id  _Nullable x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第一个订阅者%@",x);
    }];
    
    [subject subscribeNext:^(id  _Nullable x) {
        // block调用时刻：当信号发出新值，就会调用.
        NSLog(@"第二个订阅者%@",x);
    }];
     // 3.发送信号
    [subject sendNext:@"1"];
    
    // RACReplaySubject使用步骤:
    // 1.创建信号 [RACSubject subject]，跟RACSiganl不一样，创建信号时没有block。
    // 2.可以先订阅信号，也可以先发送信号。
    // 2.1 订阅信号 - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
    // 2.2 发送信号 sendNext:(id)value
    
    // RACReplaySubject:底层实现和RACSubject不一样。
    // 1.调用sendNext发送信号，把值保存起来，然后遍历刚刚保存的所有订阅者，一个一个调用订阅者的nextBlock。
    // 2.调用subscribeNext订阅信号，遍历保存的所有值，一个一个调用订阅者的nextBlock
    
    // 如果想当一个信号被订阅，就重复播放之前所有值，需要先发送信号，在订阅信号。
    // 也就是先保存值，在订阅值。
    
    // 1.创建信号
    RACReplaySubject *replaySubject = [RACReplaySubject subject];
    // 2.发送信号
    [replaySubject sendNext:@"2"];
    [replaySubject sendNext:@"3"];
    
    [replaySubject subscribeNext:^(id  _Nullable x) {
         NSLog(@"第一个订阅者接收到的数据%@",x);
    }];
    
    [replaySubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"第二个订阅者接收到的数据%@",x);
    }];

}

#pragma mark -  RACSequence和RACTuple简单使用
- (void)sequenceAndTupleUse{
    // 1.遍历数组
    NSArray *numbers = @[@1,@2,@3,@4];
    // 这里其实是三步
    // 第一步: 把数组转换成集合RACSequence numbers.rac_sequence
    // 第二步: 把集合RACSequence转换RACSignal信号类,numbers.rac_sequence.signal
    // 第三步: 订阅信号，激活信号，会自动把集合中的所有值，遍历出来。
    [numbers.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    //2.遍历字典，遍历出来的键值对会包装成RACTuple(元组对象)
    NSDictionary *dict = @{@"name":@"lilei",@"age":@18};
    [dict.rac_sequence.signal subscribeNext:^(RACTuple * _Nullable x) {
        // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
        RACTupleUnpack(NSString *key,NSString *value) = x;
        // 相当于以下写法
        //        NSString *key = x[0];
        //        NSString *value = x[1];
        NSLog(@"key = %@, value = %@",key,value);
    }];
    
    // 3.字典转模型
    // 3.1 OC写法
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"flags.plist" ofType:nil];
    NSArray *dictArr = [NSArray arrayWithContentsOfFile:filePath];
    NSMutableArray *items = [NSMutableArray array];
    for (NSDictionary *dict in dictArr) {
        FlagItem *item = [FlagItem flagWithDict:dict];
        [items addObject:item];
    }
    // 3.2 RAC写法
    NSMutableArray *flags = [NSMutableArray array];
    // rac_sequence注意点：调用subscribeNext，并不会马上执行nextBlock，而是会等一会。
    [dictArr.rac_sequence.signal subscribeNext:^(id x) {
        // 运用RAC遍历字典，x：字典
        FlagItem *item = [FlagItem flagWithDict:x];
        [flags addObject:item];
    }];
    // 3.3 RAC高级写法:
    
    // map:映射的意思，目的：把原始值value映射成一个新值
    // array: 把集合转换成数组
    // 底层实现：当信号被订阅，会遍历集合中的原始值，映射成新值，并且保存到新的数组里。
    NSArray *flags1 = [[dictArr.rac_sequence map:^id _Nullable(id  _Nullable value) {
        return [FlagItem flagWithDict:value];
    }] array];


}

#pragma mark - RACCommand
- (void)racCommandUse{
    // 1.创建命令
    RACCommand *command = [[RACCommand alloc]initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
         NSLog(@"执行命令,网络请求");
        // 创建空信号,必须返回信号
//        return [RACSignal empty];
        
        // 2.创建信号,用来传递数据
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
           
            [subscriber sendNext:@"data"];
            // 注意：数据传递完，最好调用sendCompleted，这时命令才执行完毕。
            [subscriber sendCompleted];
            
            return nil;
        }];
    }];
    // 强引用命令，不要被销毁，否则接收不到数据
    _command = command;
    // 3.订阅RACCommand中的信号
    [command.executionSignals subscribeNext:^(id  _Nullable x) {
        [x subscribeNext:^(id  _Nullable x) {
            NSLog(@"x = %@",x);
        }];
    }];
    
    //rac高级用法
    // switchToLatest:用于signal of signals，获取signal of signals发出的最新信号,也就是可以直接拿到RACCommand中的信号
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
         NSLog(@"x = %@",x);
    }];
    // 4.监听命令是否执行完毕,默认会来一次，可以直接跳过，skip表示跳过第一次信号。
    [[command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue] == YES) {
            NSLog(@"正在执行");
        }else{
            NSLog(@"执行完成");
        }
    }];
    // 5.执行命令
    [self.command execute:@1];
    
}

- (void)multicastConnectionUse{
    // RACMulticastConnection使用步骤:
    // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
    // 2.创建连接 RACMulticastConnection *connect = [signal publish];
    // 3.订阅信号,注意：订阅的不在是之前的信号，而是连接的信号。 [connect.signal subscribeNext:nextBlock]
    // 4.连接 [connect connect]
    
    // RACMulticastConnection底层原理:
    // 1.创建connect，connect.sourceSignal -> RACSignal(原始信号)  connect.signal -> RACSubject
    // 2.订阅connect.signal，会调用RACSubject的subscribeNext，创建订阅者，而且把订阅者保存起来，不会执行block。
    // 3.[connect connect]内部会订阅RACSignal(原始信号)，并且订阅者是RACSubject
    // 3.1.订阅原始信号，就会调用原始信号中的didSubscribe
    // 3.2 didSubscribe，拿到订阅者调用sendNext，其实是调用RACSubject的sendNext
    // 4.RACSubject的sendNext,会遍历RACSubject所有订阅者发送信号。
    // 4.1 因为刚刚第二步，都是在订阅RACSubject，因此会拿到第二步所有的订阅者，调用他们的nextBlock
    
    
    // 需求：假设在一个信号中发送请求，每次订阅一次都会发送请求，这样就会导致多次请求。
    // 解决：使用RACMulticastConnection就能解决.
    
    // 1.创建请求信号
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
         NSLog(@"发送请求");
        [subscriber sendNext:nil];
        return nil;
    }];
    // 2.订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"接收数据");
    }];
    // 订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
       NSLog(@"接收数据");
    }];
    // 3.运行结果，会执行两遍发送请求，也就是每次订阅都会发送一次请求
    
    
    // RACMulticastConnection:解决重复请求问题
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送请求");
        [subscriber sendNext:@1];
        return nil;
    }];
     // 2.创建连接
    RACMulticastConnection *connection = [signal1 publish];
    // 3.订阅信号，
    // 注意：订阅信号，也不能激活信号，只是保存订阅者到数组，必须通过连接,当调用连接，就会一次性调用所有订阅者的sendNext:
    [connection.signal subscribeNext:^(id  _Nullable x) {
         NSLog(@"订阅者一信号");
    }];
    [connection.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"订阅者二信号");
    }];
     // 4.连接,激活信号
    [connection connect];
    
}

- (void)racNormalFunctionForReplaceOC{
    // 1.代替代理
    // 需求：自定义redView,监听红色view中按钮点击
    // 之前都是需要通过代理监听，给红色View添加一个代理属性，点击按钮的时候，通知代理做事情
    // rac_signalForSelector:把调用某个对象的方法的信息转换成信号，就要调用这个方法，就会发送信号。
    // 这里表示只要redV调用btnClick:,就会发出信号，订阅就好了。
    UIView*redV = [[UIView alloc]initWithFrame:CGRectMake(50, 50, 50, 50)];
    [[redV rac_signalForSelector:@selector(btnClick:)] subscribeNext:^(id x) {
        NSLog(@"点击红色按钮");
    }];
    
    // 2.KVO
    // 把监听redV的center属性改变转换成信号，只要值改变就会发送信号
    // observer:可以传入nil
    [[redV rac_valuesAndChangesForKeyPath:@"center" options:NSKeyValueObservingOptionNew observer:nil] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 3.监听事件
    // 把按钮点击事件转换为信号，点击按钮，就会发送信号
    UIButton *btn = [[UIButton alloc]init];
    [[btn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"按钮被点击了");
    }];
    
    // 4.代替通知
    // 把监听到的通知转换信号
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillShowNotification object:nil] subscribeNext:^(id x) {
        NSLog(@"键盘弹出");
    }];
    
    // 5.监听文本框的文字改变
    [_textField.rac_textSignal subscribeNext:^(id x) {
        
        NSLog(@"文字改变了%@",x);
    }];
    
    // 6.处理多个请求，都返回结果的时候，统一做处理.
    RACSignal *request1 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求1
        [subscriber sendNext:@"发送请求1"];
        return nil;
    }];
    RACSignal *request2 = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 发送请求2
        [subscriber sendNext:@"发送请求2"];
        return nil;
    }];
    // 使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
    [self rac_liftSelector:@selector(updateUIWithR1:r2:) withSignalsFromArray:@[request1,request2]];
}
// 更新UI
- (void)updateUIWithR1:(id)data r2:(id)data1
{
    NSLog(@"更新UI%@  %@",data,data1);
}


/*
 ReactiveCocoa常见类
 一、RACSiganl:信号类,一般表示将来有数据传递，只要有数据改变，信号内部接收到数据，就会马上发出数据。
 
 注意：
  信号类(RACSiganl)，只是表示当数据改变时，信号内部会发出数据，它本身不具备发送信号的能力，而是交给内部一个订阅者去发出。
  默认一个信号都是冷信号，也就是值改变了，也不会触发，只有订阅了这个信号，这个信号才会变为热信号，值改变了才会触发。
  如何订阅信号：调用信号RACSignal的subscribeNext就能订阅。
 
RACSiganl简单使用:
 // RACSignal使用步骤：
 // 1.创建信号 + (RACSignal *)createSignal:(RACDisposable * (^)(id<RACSubscriber> subscriber))didSubscribe
 // 2.订阅信号,才会激活信号. - (RACDisposable *)subscribeNext:(void (^)(id x))nextBlock
 // 3.发送信号 - (void)sendNext:(id)value
 
 
 // RACSignal底层实现：
 // 1.创建信号，首先把didSubscribe保存到信号中，还不会触发。
 // 2.当信号被订阅，也就是调用signal的subscribeNext:nextBlock
 // 2.2 subscribeNext内部会创建订阅者subscriber，并且把nextBlock保存到subscriber中。
 // 2.1 subscribeNext内部会调用siganl的didSubscribe
 // 3.siganl的didSubscribe中调用[subscriber sendNext:@1];
 // 3.1 sendNext底层其实就是执行subscriber的nextBlock
    示例方法 -siganlCreateAndSubscribe
 
二、RACSubscriber:表示订阅者的意思，用于发送信号，这是一个协议，不是一个类，只要遵守这个协议，并且实现方法才能成为订阅者。通过create创建的信号，都有一个订阅者，帮助他发送数据。
 
 
三、RACDisposable:用于取消订阅或者清理资源，当信号发送完成或者发送错误的时候，就会自动触发它。
    使用场景:不想监听某个信号时，可以通过它主动取消订阅信号

四、RACSubject:RACSubject:信号提供者，自己可以充当信号，又能发送信号。
    使用场景:通常用来代替代理，有了它，就不必要定义代理了。
 
    RACReplaySubject:重复提供信号类，RACSubject的子类。

    RACReplaySubject与RACSubject区别:
    RACReplaySubject可以先发送信号，在订阅信号，RACSubject就不可以。
    使用场景一:如果一个信号每被订阅一次，就需要把之前的值重复发送一遍，使用重复提供信号类
    使用场景二:可以设置capacity数量来限制缓存的value的数量,即只缓充最新的几个值。
 
 RACSubject和RACReplaySubject简单使用：-subjectSimpleUse
 
 RACSubjectt代替代理
 // 需求:
 // 1.给当前控制器添加一个按钮，modal到另一个控制器界面
 // 2.另一个控制器view中有个按钮，点击按钮，通知当前控制器
 
 步骤一：在第二个控制器.h，添加一个RACSubject代替代理。
 @interface TwoViewController : UIViewController
 
 @property (nonatomic, strong) RACSubject *delegateSignal;
 
 @end
 
 步骤二：监听第二个控制器按钮点击
 @implementation TwoViewController
 - (IBAction)notice:(id)sender {
 // 通知第一个控制器，告诉它，按钮被点了
 
 // 通知代理
 // 判断代理信号是否有值
 if (self.delegateSignal) {
 // 有值，才需要通知
 [self.delegateSignal sendNext:nil];
 }
 }
 @end
 
 步骤三：在第一个控制器中，监听跳转按钮，给第二个控制器的代理信号赋值，并且监听.
 @implementation OneViewController
 - (IBAction)btnClick:(id)sender {
 
 // 创建第二个控制器
 TwoViewController *twoVc = [[TwoViewController alloc] init];
 
 // 设置代理信号
 twoVc.delegateSignal = [RACSubject subject];
 
 // 订阅代理信号
 [twoVc.delegateSignal subscribeNext:^(id x) {
 
 NSLog(@"点击了通知按钮");
 }];

 // 跳转到第二个控制器
 [self presentViewController:twoVc animated:YES completion:nil];
 
 }
 @end

 五、RACTuple:元组类,类似NSArray,用来包装值.
 
 六、RACSequence:RAC中的集合类，用于代替NSArray,NSDictionary,可以使用它来快速遍历数组和字典。
    使用场景：1.字典转模型
 
 七、RACCommand:RAC中用于处理事件的类，可以把事件如何处理,事件中的数据如何传递，包装到这个类中，他可以很方便的监控事件的执行过程。
    使用场景:监听按钮点击，网络请求
 // 一、RACCommand使用步骤:
 // 1.创建命令 initWithSignalBlock:(RACSignal * (^)(id input))signalBlock
 // 2.在signalBlock中，创建RACSignal，并且作为signalBlock的返回值
 // 3.执行命令 - (RACSignal *)execute:(id)input
 
 // 二、RACCommand使用注意:
 // 1.signalBlock必须要返回一个信号，不能传nil.
 // 2.如果不想要传递信号，直接创建空的信号[RACSignal empty];
 // 3.RACCommand中信号如果数据传递完，必须调用[subscriber sendCompleted]，这时命令才会执行完毕，否则永远处于执行中。
 // 4.RACCommand需要被强引用，否则接收不到RACCommand中的信号，因此RACCommand中的信号是延迟发送的。
 
 // 三、RACCommand设计思想：内部signalBlock为什么要返回一个信号，这个信号有什么用。
 // 1.在RAC开发中，通常会把网络请求封装到RACCommand，直接执行某个RACCommand就能发送请求。
 // 2.当RACCommand内部请求到数据的时候，需要把请求的数据传递给外界，这时候就需要通过signalBlock返回的信号传递了。
 
 // 四、如何拿到RACCommand中返回信号发出的数据。
 // 1.RACCommand有个执行信号源executionSignals，这个是signal of signals(信号的信号),意思是信号发出的数据是信号，不是普通的类型。
 // 2.订阅executionSignals就能拿到RACCommand中返回的信号，然后订阅signalBlock返回的信号，就能获取发出的值。
 
 // 五、监听当前命令是否正在执行executing
 
 // 六、使用场景,监听按钮点击，网络请求
 

 八、RACMulticastConnection:用于当一个信号，被多次订阅时，为了保证创建信号时，避免多次调用创建信号中的block，造成副作用，可以使用这个类处理。
     使用注意:RACMulticastConnection通过RACSignal的-publish或者-muticast:方法创建
     RACMulticastConnection简单使用:
 
 
 
 九、RACScheduler:RAC中的队列，用GCD封装的
 
 十、RACUnit :表⽰stream不包含有意义的值,也就是看到这个，可以直接理解为nil.
 
 十一、RACEvent: 把数据包装成信号事件(signal event)。它主要通过RACSignal的-materialize来使用，然并卵
 
 
 
 ReactiveCocoa开发中常见用法
 一、代替代理：
    rac_signalForSelector：用于替代代理
 
 二、代替KVO :
    rac_valuesAndChangesForKeyPath：用于监听某个对象的属性改变。
 
 三、监听事件:
    rac_signalForControlEvents：用于监听某个事件。
 
 四、代替通知:
    rac_addObserverForName:用于监听某个通知。
 
 五、监听文本框文字改变:
    rac_textSignal:只要文本框发出改变就会发出这个信号
 
 六、处理当界面有多次请求时，需要都获取到数据时，才能展示界面
    rac_liftSelector:withSignalsFromArray:Signals:当传入的Signals(信号数组)，每一个signal都至少sendNext过一次，就会去触发第一个selector参数的方法。
    使用注意：几个信号，参数一的方法就几个参数，每个参数对应信号发出的数据。
 

 
 ReactiveCocoa常见宏
 
 一、RAC(TARGET, [KEYPATH, [NIL_VALUE]]):用于给某个对象的某个属性绑定。
    // 只要文本框文字改变，就会修改label的文字
    RAC(self.labelView,text) = _textField.rac_textSignal;

 二、RACObserve(self, name):监听某个对象的某个属性,返回的是信号。
    [RACObserve(self.view, center) subscribeNext:^(id x) {
      NSLog(@"%@",x);
    }];

 三、@weakify(Obj)和@strongify(Obj),一般两个都是配套使用,在主头文件(ReactiveCocoa.h)中并没有导入，需要自己手动导入，RACEXTScope.h才可以使用。但是每次导入都非常麻烦，只需要在主头文件自己导入就好了
 
 四、RACTuplePack：把数据包装成RACTuple（元组类）
 // 把参数中的数据包装成元组
 RACTuple *tuple = RACTuplePack(@"xmg",@20);
 
 // 解包元组，会把元组的值，按顺序给参数里面的变量赋值
 // name = @"xmg" age = @20
 RACTupleUnpack(NSString *name,NSNumber *age) = tuple;
 
 
 ReactiveCocoa核心方法bind
 // 假设想监听文本框的内容，并且在每次输出结果的时候，都在文本框的内容拼接一段文字“输出：”
 
 // 方式一:在返回结果后，拼接
 [_textField.rac_textSignal subscribeNext:^(id x) {
    NSLog(@"输出:%@",x);
 }];
 
 // 方式二:在返回结果前，拼接，使用RAC中bind方法做处理。
 // bind方法参数:需要传入一个返回值是RACStreamBindBlock的block参数
 // RACStreamBindBlock是一个block的类型，返回值是信号，参数（value,stop），因此参数的block返回值也是一个block。
 
 // RACStreamBindBlock:
 // 参数一(value):表示接收到信号的原始值，还没做处理
 // 参数二(*stop):用来控制绑定Block，如果*stop = yes,那么就会结束绑定。
 // 返回值：信号，做好处理，在通过这个信号返回出去，一般使用RACReturnSignal,需要手动导入头文件RACReturnSignal.h。
 
 // bind方法使用步骤:
 // 1.传入一个返回值RACStreamBindBlock的block。
 // 2.描述一个RACStreamBindBlock类型的bindBlock作为block的返回值。
 // 3.描述一个返回结果的信号，作为bindBlock的返回值。
 // 注意：在bindBlock中做信号结果的处理。
 
 // 底层实现:
 // 1.源信号调用bind,会重新创建一个绑定信号。
 // 2.当绑定信号被订阅，就会调用绑定信号中的didSubscribe，生成一个bindingBlock。
 // 3.当源信号有内容发出，就会把内容传递到bindingBlock处理，调用bindingBlock(value,stop)
 // 4.调用bindingBlock(value,stop)，会返回一个内容处理完成的信号（RACReturnSignal）。
 // 5.订阅RACReturnSignal，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来
 // 注意:不同订阅者，保存不同的nextBlock，看源码的时候，一定要看清楚订阅者是哪个。
 // 这里需要手动导入#import <ReactiveCocoa/RACReturnSignal.h>，才能使用RACReturnSignal。
 
 [[_textField.rac_textSignal bind:^RACStreamBindBlock{
 
 // 什么时候调用:
 // block作用:表示绑定了一个信号.
 
 return ^RACStream *(id value, BOOL *stop){
 
 // 什么时候调用block:当信号有新的值发出，就会来到这个block。
 
 // block作用:做返回值的处理
 
 // 做好处理，通过信号返回出去.
 return [RACReturnSignal return:[NSString stringWithFormat:@"输出:%@",value]];
 };
 
 }] subscribeNext:^(id x) {
 
 NSLog(@"%@",x);
 
 }];


 
 ReactiveCocoa操作方法之映射(flattenMap,Map)
   flattenMap，Map用于把源信号内容映射成新的内容。
 
 
 
 */

//flattenMap简单使用
- (void)RACFlattenMapUse{
    // 监听文本框的内容改变，把结构重新映射成一个新值.
    // flattenMap作用:把源信号的内容映射成一个新的信号，信号可以是任意类型。
    
    // flattenMap使用步骤:
    // 1.传入一个block，block类型是返回值RACStream，参数value
    // 2.参数value就是源信号的内容，拿到源信号的内容做处理
    // 3.包装成RACReturnSignal信号，返回出去。
    
    // flattenMap底层实现:
    // 0.flattenMap内部调用bind方法实现的,flattenMap中block的返回值，会作为bind中bindBlock的返回值。
    // 1.当订阅绑定信号，就会生成bindBlock。
    // 2.当源信号发送内容，就会调用bindBlock(value, *stop)
    // 3.调用bindBlock，内部就会调用flattenMap的block，flattenMap的block作用：就是把处理好的数据包装成信号。
    // 4.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
    // 5.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。
    
    [self.view addSubview:self.textField];
    [[self.textField.rac_textSignal flattenMap:^__kindof RACSignal * _Nullable(NSString * _Nullable value) {
        // block什么时候 : 源信号发出的时候，就会调用这个block。
        
        // block作用 : 改变源信号的内容。
        
        // 返回值：绑定信号的内容.
        return [RACReturnSignal return:[NSString stringWithFormat:@"他说:%@",value]];
        
    }] subscribeNext:^(id  _Nullable x) {
        // 订阅绑定信号，每当源信号发送内容，做完处理，就会调用这个block。
        NSLog(@"%@",x);
    }];

    
}

//Map使用
- (void)RACMapSimpleUse{
    // 监听文本框的内容改变，把结构重新映射成一个新值.
    
    // Map作用:把源信号的值映射成一个新的值
    
    // Map使用步骤:
    // 1.传入一个block,类型是返回对象，参数是value
    // 2.value就是源信号的内容，直接拿到源信号的内容做处理
    // 3.把处理好的内容，直接返回就好了，不用包装成信号，返回的值，就是映射的值。
    
    // Map底层实现:
    // 0.Map底层其实是调用flatternMap,Map中block中的返回的值会作为flatternMap中block中的值。
    // 1.当订阅绑定信号，就会生成bindBlock。
    // 3.当源信号发送内容，就会调用bindBlock(value, *stop)
    // 4.调用bindBlock，内部就会调用flattenMap的block
    // 5.flattenMap的block内部会调用Map中的block，把Map中的block返回的内容包装成返回的信号。
    // 5.返回的信号最终会作为bindBlock中的返回信号，当做bindBlock的返回信号。
    // 6.订阅bindBlock的返回信号，就会拿到绑定信号的订阅者，把处理完成的信号内容发送出来。

    [self.view addSubview:self.textField];
    [[self.textField.rac_textSignal map:^id _Nullable(NSString * _Nullable value)
    {
        // 当源信号发出，就会调用这个block，修改源信号的内容
        // 返回值：就是处理完源信号的内容。
        return [NSString stringWithFormat:@"他说：%@",value];
    }] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}
/*
 FlatternMap和Map的区别
 
 1.FlatternMap中的Block返回信号。
 2.Map中的Block返回对象。
 3.开发中，如果信号发出的值不是信号，映射一般使用Map
 4.开发中，如果信号发出的值是信号，映射一般使用FlatternMap
 
 总结：signalOfsignals用FlatternMap
 */
- (void)differentOfMapFlattenMap{
    
    // 创建信号中的信号
    RACSubject *signalOfsignals = [RACSubject subject];
    RACSubject *signal = [RACSubject subject];

//    signalOfsignals flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
//
//    }];
    [[signalOfsignals flattenMap:^__kindof RACStream *(id value) {
        
        // 当signalOfsignals的signals发出信号才会调用
        NSLog(@"flatMap:%@",value);
        return value;
        
    }] subscribeNext:^(id x) {
        
        // 只有signalOfsignals的signal发出信号才会调用，因为内部订阅了bindBlock中返回的信号，也就是flattenMap返回的信号。
        // 也就是flattenMap返回的信号发出内容，才会调用。
        
        NSLog(@"map:%@",x);
    }];
    
    // 信号的信号发送信号
    [signalOfsignals sendNext:signal];
    
    // 信号发送内容
    [signal sendNext:@1];
    
}

//ReactiveCocoa操作方法之组合
//concat:按一定顺序拼接信号，当多个信号发出的时候，有顺序的接收信号
- (void)racMethodOfConcat{
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@2];
        [subscriber sendCompleted];
        return nil;
    }];
    // 把signalA拼接到signalB后，signalA发送完成，signalB才会被激活。
    RACSignal *concatSignal = [signalA concat:signalB];
    // 以后只需要面对拼接信号开发。
    // 订阅拼接的信号，不需要单独订阅signalA，signalB
    // 内部会自动订阅。
    // 注意：第一个信号必须发送完成，第二个信号才会被激活
    [concatSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    /*
     // concat底层实现:
     // 1.当拼接信号被订阅，就会调用拼接信号的didSubscribe
     // 2.didSubscribe中，会先订阅第一个源信号（signalA）
     // 3.会执行第一个源信号（signalA）的didSubscribe
     // 4.第一个源信号（signalA）didSubscribe中发送值，就会调用第一个源信号（signalA）订阅者的nextBlock,通过拼接信号的订阅者把值发送出来.
     // 5.第一个源信号（signalA）didSubscribe中发送完成，就会调用第一个源信号（signalA）订阅者的completedBlock,订阅第二个源信号（signalB）这时候才激活（signalB）。
     // 6.订阅第二个源信号（signalB）,执行第二个源信号（signalB）的didSubscribe
     // 7.第二个源信号（signalA）didSubscribe中发送值,就会通过拼接信号的订阅者把值发送出来.
     
     */
    
}
//then 用于连接两个信号，当第一个信号完成，才会连接then返回的信号
- (void)racMethodOfThen{
    // 注意使用then，之前信号的值会被忽略掉.
    // 底层实现：1、先过滤掉之前的信号发出的值。2.使用concat连接then返回的信号
    [[[RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        [subscriber sendCompleted];
        return nil;
    }] then:^RACSignal * _Nonnull{
      
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@2];
            return nil;
        }];
    }] subscribeNext:^(id  _Nullable x) {
        // 只能接收到第二个信号的值，也就是then返回信号的值
        NSLog(@"then %@",x);
    }];
}

//merge:把多个信号合并为一个信号，任何一个信号有新值的时候就会调用
- (void)racMethdOfMerge{
    
    // merge:把多个信号合并成一个信号
    //创建多个信号
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@1];
        
        
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        
        [subscriber sendNext:@2];
        
        return nil;
    }];
    
    // 合并信号,任何一个信号发送数据，都能监听到.
    RACSignal *mergeSignal = [signalA merge:signalB];
    
    [mergeSignal subscribeNext:^(id x) {
        
        NSLog(@"merge %@",x);
        
    }];
    
    // 底层实现：
    // 1.合并信号被订阅的时候，就会遍历所有信号，并且发出这些信号。
    // 2.每发出一个信号，这个信号就会被订阅
    // 3.也就是合并信号一被订阅，就会订阅里面所有的信号。
    // 4.只要有一个信号被发出就会被监听。
}

//zipWith:把两个信号压缩成一个信号，只有当两个信号同时发出信号内容时，并且把两个信号的内容合并成一个元组，才会触发压缩流的next事件。
- (void)racMethodOfZip{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        return nil;
    }];
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@2];
        return nil;
    }];
    
    RACSignal *zipSignal = [signalA zipWith:signalB];
    [zipSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"zip %@",x);
    }];
    // 底层实现:
    // 1.定义压缩信号，内部就会自动订阅signalA，signalB
    // 2.每当signalA或者signalB发出信号，就会判断signalA，signalB有没有发出个信号，有就会把最近发出的信号都包装成元组发出。
}

//combineLatest:将多个信号合并起来，并且拿到各个信号的最新的值,必须每个合并的signal至少都有过一次sendNext，才会触发合并的信号
- (void)racMethodOfCombineLatest{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@2];
        return nil;
    }];
    
    RACSignal *combineSignal = [signalA combineLatestWith:signalB];
    [combineSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"combineLatest %@",x);
    }];
    
    // 底层实现：
    // 1.当组合信号被订阅，内部会自动订阅signalA，signalB,必须两个信号都发出内容，才会被触发。
    // 2.并且把两个信号组合成元组发出。
}
//reduce 聚合:用于信号发出的内容是元组，把信号发出元组的值聚合成一个值
- (void)racMethodOfReduce{
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@1];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        [subscriber sendNext:@2];
        return nil;
    }];
    // 聚合
    // 常见的用法，（先组合在聚合）。combineLatest:(id<NSFastEnumeration>)signals reduce:(id (^)())reduceBlock
    // reduce中的block简介:
    // reduceblcok中的参数，有多少信号组合，reduceblcok就有多少参数，每个参数就是之前信号发出的内容
    // reduceblcok的返回值：聚合信号之后的内容。
    
    RACSignal *reduceSignal = [[RACSignal combineLatest:@[signalA,signalB]] reduceEach:^id(NSNumber *s1,NSNumber *s2){
        return [NSString stringWithFormat:@" %@ %@",s1,s2];
    }];
    
    [reduceSignal subscribeNext:^(id  _Nullable x) {
        NSLog(@"reduce %@",x);
    }];
    // 底层实现:
    // 1.订阅聚合信号，每次有内容发出，就会执行reduceblcok，把信号内容转换成reduceblcok返回的值。
}

//filter:过滤信号，使用它可以获取满足条件的信号.
- (void)racMethodOfFilter{
    // 过滤:
    // 每次信号发出，会先执行过滤条件判断.
    [self.view addSubview:self.textField];
    [[_textField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return value.length>3;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    
}
//ignore:忽略完某些值的信号.
- (void)racMethodOfIgnore{
    // 内部调用filter过滤，忽略掉ignore的值
    [self.view addSubview:self.textField];
    [[_textField.rac_textSignal ignore:@"1"] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

//distinctUntilChanged:当上一次的值和当前的值有明显的变化就会发出信号，否则会被忽略掉。
- (void)racMethodOfDistinctUntilChanged{
    
    // 过滤，当上一次和当前的值不一样，就会发出内容。
    // 在开发中，刷新UI经常使用，只有两次数据不一样才需要刷新
    [self.view addSubview:self.textField];
    [[_textField.rac_textSignal distinctUntilChanged] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
}

//take 从开始一共取N次的信号
- (void)racMethodOfTake{
    // 1、创建信号
    RACSubject *signal = [RACSubject subject];
    
    // 2、处理信号，订阅信号
    [[signal take:1] subscribeNext:^(id x) {
        
        NSLog(@"%@",x);
    }];
    
    // 3.发送信号
    [signal sendNext:@1];
    
    [signal sendNext:@2];
    
}



@end
