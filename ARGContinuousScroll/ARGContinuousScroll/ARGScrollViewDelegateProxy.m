//
//  ARGScrollViewDelegateProxy.m
//  ARGView
//
//  Created by Sergei Polshcha on 17.10.2020.
//  Copyright © 2020 Argentum. All rights reserved.
//

#import "ARGScrollViewDelegateProxy.h"

@interface ARGScrollViewDelegateProxy()

@property (nonatomic) NSMutableArray *delegates;

@end

@implementation ARGScrollViewDelegateProxy

- (void)addDelegate:(id<UIScrollViewDelegate>)delegate {
    if (!_delegates) {
        _delegates = [NSMutableArray new];
    }
    
    [_delegates addObject:delegate];
}

- (void)removeDelegate:(id<UIScrollViewDelegate>)delegate {
    [_delegates removeObject:delegate];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    SEL selector = [anInvocation selector];
    BOOL forwarded = NO;
    
    for (id <UIScrollViewDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:selector]) {
            [anInvocation invokeWithTarget:delegate];
            forwarded = YES;
        }
    }
    
    if (!forwarded) {
        [super forwardInvocation:anInvocation];
    }
}

@end
