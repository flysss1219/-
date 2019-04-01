//
//  NSObject+Model.m
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/18.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "NSObject+Model.h"
#import <objc/runtime.h>

@implementation NSObject (Model)

//+ (instancetype)modelWithDict:(NSDictionary*)dict{
//    
//    id objc = [[self alloc]init];
//    
//    unsigned int count;
//    
//    Ivar *ivarList = class_copyIvarList(self, &count);
//    
//    for (int i = 0; i < count; i++) {
//        
//        Ivar ivar = ivarList[i];
//        
//        NSString *name = [NSString stringWithUTF8String:ivar_getName(ivar)];
//        NSString *key = [name substringFromIndex:1];
//        
//        id value = dict[key];
//        
//        if ([value isKindOfClass:[NSDictionary class]]) {
//            
//            NSString *type = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
//            
//            NSRange range = [type rangeOfString:@"\""];
//            
//            type = [type substringFromIndex:range.location+range.length];
//            
//            type = [type substringToIndex:range.location];
//            
//            Class modelClass = NSClassFromString(type);
//            
//            if (modelClass) {
//                value = [modelClass modelWithDict:value];
//            }
//        }
//        
//        if ([value isKindOfClass:[NSArray class]]) {
//            if ([self respondsToSelector:@selector(arryContainModelClass)]) {
//                
//                id idSelf = self;
//                // 获取数组中字典对应的模型
//                NSString *type =  [idSelf arryContainModelClass][key];
//                
//                // 生成模型
//                Class classModel = NSClassFromString(type);
//                NSMutableArray *arrM = [NSMutableArray array];
//                // 遍历字典数组，生成模型数组
//                for (NSDictionary *dict in value) {
//                    // 字典转模型
//                    id model =  [classModel modelWithDict:dict];
//                    [arrM addObject:model];
//                }
//                
//                // 把模型数组赋值给value
//                value = arrM;
//                
//            }
//        }
//        if (value) { // 有值，才需要给模型的属性赋值
//            // 利用KVC给模型中的属性赋值
//            [objc setValue:value forKey:key];
//        }
//    }
//     return objc;
//}
//
//
//+ (NSDictionary*)arryContainModelClass{
//    
//    
//    return nil;
//}


@end
