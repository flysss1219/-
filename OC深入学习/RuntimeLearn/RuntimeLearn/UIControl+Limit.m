//
//  UIControl+Limit.m
//  RuntimeLearn
//
//  Created by iOSDev on 2019/1/23.
//  Copyright © 2019 Berui. All rights reserved.
//

#import "UIControl+Limit.h"
#import <objc/runtime.h>


static const char  *UIControl_acceptEventInterval = "UIControl_acceptEventInterval";

static const char *UIControl_ignoreEvent = "UIControl_ignoreEvent";

@implementation UIControl (Limit)


#pragma mark - acceptEventInterval

- (void)setAcceptEventInterval:(NSTimeInterval)acceptEventInterval{
    objc_setAssociatedObject(self, UIControl_acceptEventInterval, @(acceptEventInterval),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSTimeInterval)acceptEventInterval{
   return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

#pragma mark - igoreEvent
- (void)setIgnoreEvent:(BOOL)ignoreEvent{
    objc_setAssociatedObject(self, UIControl_ignoreEvent, @(ignoreEvent), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ignoreEvent{
    return [objc_getAssociatedObject(self, UIControl_ignoreEvent) boolValue];
}


#pragma mark - swizzling
+ (void)load {
    
    Method originalM = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    
    Method swizzledM = class_getInstanceMethod(self, @selector(swizzle_sendAction:to:forEvent:));
    
    method_exchangeImplementations(originalM, swizzledM);
    
}

- (void)swizzle_sendAction:(SEL)action to:(id)target forEvent:(UIEvent*)event {
    if (self.ignoreEvent) {
        NSLog(@"btn action is interceted");
        return;
    }
    if (self.acceptEventInterval > 0) {
        self.ignoreEvent = YES;
        [self performSelector:@selector(setIgnoreEventWithNo) withObject:nil afterDelay:self.acceptEventInterval];
    }
    [self swizzle_sendAction:action to:target forEvent:event];
}

- (void)setIgnoreEventWithNo{
    self.ignoreEvent = NO;
}


@end
