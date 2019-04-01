//
//  NSArray+SafeBeyondOut.m
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/23.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "NSArray+SafeBeyondOut.h"
#import <objc/runtime.h>


@implementation NSArray (SafeBeyondOut)
+ (void)load{
    
    //为什么有三种？
    /*
     NSArray是类簇，初始化之后对应的具体类有 __NSArray0，__NSSingleObjectArrayI，__NSArrayI
     分别对应空数组，只有一个元素的数组，以及大于一个元素的数组类型
     
     所以需要对实际数组类型进行方法交换
     */
    Method originalM1 = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndex:));
    Method swizzleM1 = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(sw_objectAtIndex:));
    method_exchangeImplementations(originalM1, swizzleM1);
    
    Method originalM2 = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndex:));
    Method swizzleM2 = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(sw_emptyObjectAtIndex:));
    method_exchangeImplementations(originalM2, swizzleM2);

    Method originalM3 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndex:));
    Method swizzleM3 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(sw_singleObjectAtIndex:));
    method_exchangeImplementations(originalM3, swizzleM3);
    //    总结：以上方法只能对 objectAtIndex:这种取值方式能起到防止崩溃效果，如果用户是采用array[index]这种方式则无法防止崩溃
    
    //因此，需要对array[index]这种方式再进行防止崩溃处理，通过log可以知道array[index]实际调用的是
    //    -objectAtIndexedSubscript：这个方法,所以对这个方法再次进行runtime交换就行了
    //同理还是需要对三种数组类型都要进行处理
    Method originalSubM1 = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(objectAtIndexedSubscript:));
    Method swizzleSubM1 = class_getInstanceMethod(objc_getClass("__NSArrayI"), @selector(sw_objectAtIndexedSubscript:));
    method_exchangeImplementations(originalSubM1, swizzleSubM1);
    
    Method originalSubM2 = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(objectAtIndexedSubscript:));
    Method swizzleSubM2 = class_getInstanceMethod(objc_getClass("__NSArray0"), @selector(sw_emptyObjectAtIndexedSubscript:));
    method_exchangeImplementations(originalSubM2, swizzleSubM2);
    
    Method originalSubM3 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(objectAtIndexedSubscript:));
    Method swizzleSubM3 = class_getInstanceMethod(objc_getClass("__NSSingleObjectArrayI"), @selector(sw_singleObjectAtIndexedSubscript:));
    method_exchangeImplementations(originalSubM3, swizzleSubM3);
    
}

#pragma mark - objectAtIndex
- (id)sw_objectAtIndex:(NSInteger)index {
    
    if (self.count - 1 < index) {
        @try {
            return [self sw_objectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
             NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
//            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }else{
        return [self sw_objectAtIndex:index];
    }
}

- (id)sw_singleObjectAtIndex:(NSInteger)index {
    
    if (self.count - 1 < index) {
        @try {
            return [self sw_singleObjectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
//            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }else{
        return [self sw_singleObjectAtIndex:index];
    }
}

- (id)sw_emptyObjectAtIndex:(NSInteger)index {
    
    if (self.count - 1 < index) {
        @try {
            return [self sw_emptyObjectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
             NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
//            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }else{
        return [self sw_emptyObjectAtIndex:index];
    }
}

#pragma mark - objectAtIndexedSubscript
- (id)sw_objectAtIndexedSubscript:(NSInteger)index{
    if (self.count - 1 < index) {
        @try {
            return [self sw_objectAtIndexedSubscript:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
            //            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }else{
        return [self sw_objectAtIndexedSubscript:index];
    }
}

- (id)sw_emptyObjectAtIndexedSubscript:(NSInteger)index{
    if (self.count - 1 < index) {
        @try {
            return [self sw_emptyObjectAtIndexedSubscript:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
            //            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }else{
        return [self sw_emptyObjectAtIndexedSubscript:index];
    }
}

- (id)sw_singleObjectAtIndexedSubscript:(NSInteger)index{
    if (self.count - 1 < index) {
        @try {
            return [self sw_singleObjectAtIndexedSubscript:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
            //            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
            return nil;
        } @finally {}
    }else{
        return [self sw_singleObjectAtIndexedSubscript:index];
    }
}





@end
