//
//  ViewController.m
//  SDWebImageREC
//
//  Created by iOSDev on 2019/3/11.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
//    https://www.jianshu.com/p/f166c896a642  SDWebImage源码解析
}
/*
 SDWebImage原理
 
1、 入口 setImageWithURL:placeholderImage:options:会先把 placeholderImage 显示，然后 SDWebImageManager 根据 URL 开始处理图片。
2、进入SDWebImageManagerdownloadWithURL:delegate:options:userInfo:，交给 SDImageCache 从缓存查找图片是否已经下载queryDiskCacheForKey:delegate:userInfo:。
3、 先从内存图片缓存查找是否有图片，如果内存中已经有图片缓存，SDImageCacheDelegate 回调imageCache:didFindImage:forKey:userInfo: 到 SDWebImageManager。
 
4、SDWebImageManagerDelegate 回调webImageManager:didFinishWithImage:到 UIImageView+WebCache 等前端展示图片。
5、 如果内存缓存中没有，生成 NSInvocationOperation
6、 添加到队列开始从硬盘查找图片是否已经缓存。
7、 根据 URLKey 在硬盘缓存目录下尝试读取图片文件。这一步是在 NSOperation 进行的操作，所以回主线程进行结果回调 notifyDelegate:。
8、 如果上一操作从硬盘读取到了图片，将图片添加到内存缓存中
 （如果空闲内存过小，会先清空内存缓存）。    SDImageCacheDelegate 回调 imageCache:didFindImage:forKey:userInfo:。进而回调展示图片。
9、如果从硬盘缓存目录读取不到图片，
 说明所有缓存都不存在该图片，需要下载图片，
 回调 imageCache:didNotFindImageForKey:userInfo:。
10、 共享或重新生成一个下载器 SDWebImageDownloader 开始下载图片。
 图片下载由NSURLSession(NSURLConnection已经被剔除了) 来做，实现相关 delegate 来判断图片下载中、下载完成和下载失败。
 
11、 session:didReceiveData: 中利用 ImageIO做了按图片下载进度加载效果。
 
12、 sessionDidFinishLoading:数据下载完成后交给SDWebImageDecoder 做图片解码处理。
13、 图片解码处理在一个NSOperationQueue完成，不会拖慢主线程 UI。如果有需要对下载的图片进行二次处理，最好也在这里完成，效率会好很多。
14、 在主线程 notifyDelegateOnMainThreadWithInfo: 宣告解码完成，imageDecoder:didFinishDecodingImage:userInfo:回调给 SDWebImageDownloader。
 
15、 imageDownloader:didFinishWithImage:回调给 SDWebImageManager 告知图片下载完成。
16、 通知所有的 downloadDelegates下载完成，回调给需要的地方展示图片。
17、 将图片保存到 SDImageCache 中，内存缓存和硬盘缓存同时保存。
18、 写文件到硬盘也在以单独 NSInvocationOperation 完成， 避免拖慢主线程。

 
19、 SDImageCache 在初始化的时候会注册一些消息通知，在内存警告或退到后台的时候清理内存图片缓存，应用结束的时候清理过期图片。
 
20、 SDImageCache 也提供了 UIButton+WebCache 和 MKAnnotationView+WebCache，方便使用。
 
21、 SDWebImagePrefetcher 可以预先下载图片，方便后续使用

图解：https://upload-images.jianshu.io/upload_images/3691932-bbeadc4de1ad23fd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/793
 
 
 */


//tips
/*
1、 FOUNDATION_EXPORT 与 ＃define 都可以用来定义常量
 
 .h文件
 FOUNDATION_EXPORT  NSString *const kMyConstantString;
 
 .m文件
 NSString *const kMyConstantString = @"hello world";
 
 另一种就是常用的#define 方法定义常量了
 #define kMyConstantString @"Hello"
 
 那么他们有什么区别呢?
 使用FOUNDATION_EXPORT方法在检测字符串的值是否相等的时候效率更快.
 可以直接使用(myString == MyFirstConstant)来比较, 而define则使用的是([myString isEqualToString:MyFirstContant])
 哪个效率更高,显而易见了
 第一种是直接比较指针地址
 第二种则是一一比较字符串的每一个字符是否相等.
 
 2、NS_DESIGNATED_INITIALIZER ：
 NS_DESIGNATED_INITIALIZER宏来实现指定构造器，通常是想告诉调用者要用这个方法去初始化类对象，便于规范API。
 
 3、initialize
 initialize静态方法会在第一次使用该类之前由运行期系统调用，而且仅调用一次，属于懒加载范畴，如果不使用则不会调用，可以在方法内部做一些初始化操作，但是load方法是只要启动程序就会调用
 
4、UIView+WebCache.h
 - (void)sd_internalSetImageWithURL:(nullable NSURL *)url
 placeholderImage:(nullable UIImage *)placeholder
 options:(SDWebImageOptions)options
 operationKey:(nullable NSString *)operationKey
 setImageBlock:(nullable SDSetImageBlock)setImageBlock
 progress:(nullable SDWebImageDownloaderProgressBlock)progressBlock
 completed:(nullable SDExternalCompletionBlock)completedBlock
 context:(nullable NSDictionary<NSString *, id> *)context
 方法图解
 https://upload-images.jianshu.io/upload_images/1437388-6be06e2d64636766.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1000
 
 5、SDWebImageManager
   SDWebImageManager类是SDWebImage中的核心类，主要负责调用SDWebImageDownloader进行图片下载，以及在下载之后利用SDImageCache进行图片缓存。并且此类还可以跳过UIImageViewe/Cache或者UIView/Cache单独使用，不仅局限于一个UIView
 
 6、SDWebImageDownloaderOperation
 SDWebImageDownloaderOperation继承自NSOperation，是具体的执行图片下载的单位。负责生成NSURLSessionTask进行图片请求，支持下载取消和后台下载，在下载中及时汇报下载进度，在下载成功后，对图片进行解码，缩放和压缩等操作
 1.首先生成继承自NSOperation的SDWebImageDownloaderOperation，配置当前operation。
 2.将operation添加到NSOperationQueue下载队列中，添加到下载队列会触发operation的start方法。
 3.如果发现operation的isCancelled为YES，说明已经被取消，则finished=YES结束下载。
 4.创建NSURLSessionTask执行resume开始下载。
 5.当收到服务端的相应时根据code判断请求状态，如果是正常状态则发送正在接受response的通知以及下载进度。如果是304或者其他异常状态则cancel下载操作。
 6.在didReceiveData每次收到服务器的返回response时，给可变data追加图片当前下载的data，并汇报下载的进度。
 7.在didCompleteWithError下载结束时，如果下载成功进行图片data解码，图片的缩放或者压缩操作，发送下载结束通知。下载失败执行失败回调。
 
 
 
源码解读：https://www.jianshu.com/p/e5e6ef6a6093
阅读延伸：关于SDWebImage的面试题：https://www.jianshu.com/p/b8517dc833c7
 */


/*
 扩展：NSMapTable

 

 参考链接：http://www.isaced.com/post-235.html
 */


@end
