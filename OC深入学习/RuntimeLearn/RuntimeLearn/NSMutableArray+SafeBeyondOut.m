//
//  NSMutableArray+SafeBeyondOut.m
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/24.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "NSMutableArray+SafeBeyondOut.h"
#import <objc/runtime.h>


@implementation NSMutableArray (SafeBeyondOut)

+ (void)load{
    
    Method originalM1 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:));
    Method swizzleM1 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndex:));
    method_exchangeImplementations(originalM1, swizzleM1);
    
    Method originalM2 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(insertObject:atIndex:));
    Method swizzleM2 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(sw_insertObject:atIndex:));
    method_exchangeImplementations(originalM2, swizzleM2);
    
    Method originalM3 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(removeObjectAtIndex:));
    Method swizzleM3 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(sw_removeObjectAtIndex:));
    method_exchangeImplementations(originalM3, swizzleM3);
    
    Method originalM4 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(replaceObjectAtIndex:withObject:));
    Method swizzleM4 = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(sw_replaceObjectAtIndex:withObject:));
    method_exchangeImplementations(originalM4, swizzleM4);
    
    
//    Method originalSubM = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(objectAtIndexedSubscript:));
//    Method swizzleSubM = class_getInstanceMethod(objc_getClass("__NSArrayM"), @selector(sw_objectAtIndexedSubscript:));
//    method_exchangeImplementations(originalSubM, swizzleSubM);
    
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
#pragma mark -removeObjectAtIndex
- (void)sw_removeObjectAtIndex:(NSInteger)index{
    if (self.count - 1 < index) {
        @try {
            [self sw_removeObjectAtIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
            //            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
        } @finally {}
    }else{
        [self sw_removeObjectAtIndex:index];
    }
}

#pragma mark - insertObjectAtIndex
- (void)sw_insertObject:(id)object atIndex:(NSInteger)index{
    if (self.count - 1 < index) {
        @try {
            [self sw_insertObject:object atIndex:index];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
            //            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
        } @finally {}
    }else{
        [self sw_insertObject:object atIndex:index];
    }
}
#pragma mark - replaceObjectAtIndex
- (void)sw_replaceObjectAtIndex:(NSInteger)index withObject:(id)object{
    if (self.count - 1 < index) {
        @try {
            [self sw_replaceObjectAtIndex:index withObject:object];
        } @catch (NSException *exception) {
            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
            NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
            //            NSAssert(NO,err);
            NSLog(@"%@", [exception callStackSymbols]);
        } @finally {}
    }else{
        [self sw_replaceObjectAtIndex:index withObject:object];
    }
}


#pragma mark - objectAtIndexedSubscript

//- (id)sw_objectAtIndexedSubscript:(NSInteger)index {
//    if (self.count - 1 < index) {
//        @try {
//            return [self sw_objectAtIndexedSubscript:index];
//        } @catch (NSException *exception) {
//            // 在崩溃后会打印崩溃信息。如果是线上，可以在这里将崩溃信息发送到服务器
//            NSString *err = [NSString stringWithFormat:@"index %ld beyond  bounds %s %s",index,class_getName(self.class), __func__];
//            //            NSAssert(NO,err);
//            NSLog(@"%@", [exception callStackSymbols]);
//            return nil;
//        } @finally {}
//    }else{
//        return [self sw_objectAtIndexedSubscript:index];
//    }
//}








@end
