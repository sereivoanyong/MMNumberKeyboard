//
//  MMTextInputDelegateProxy.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 2/13/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import "MMTextInputDelegateProxy.h"

@implementation MMTextInputDelegateProxy

- (instancetype)initWithTextInput:(id<UITextInput>)textInput delegate:(id<UITextInputDelegate>)delegate
{
    NSParameterAssert(delegate);
    self = [super init];
    if (self) {
        _delegate = delegate;
        _previousTextInputDelegate = textInput.inputDelegate;
    }
    return self;
}

#pragma mark - Forwarding.

- (NSArray<id<UITextInputDelegate>> *)delegates
{
    NSMutableArray<id<UITextInputDelegate>> *delegates = [NSMutableArray array];
    
    id<UITextInputDelegate> previousTextInputDelegate = self.previousTextInputDelegate;
    if (previousTextInputDelegate) {
        [delegates addObject:previousTextInputDelegate];
    }
    
    id<UITextInputDelegate> delegate = self.delegate;
    if (delegate) {
        [delegates addObject:delegate];
    }
    
    return [delegates copy];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    if ([super respondsToSelector:selector]) {
        return YES;
    }
    
    for (id<UITextInputDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:selector]) {
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature *signature = [super methodSignatureForSelector:selector];
    
    if (!signature) {
        for (id<UITextInputDelegate> delegate in self.delegates) {
            if ([delegate respondsToSelector:selector]) {
                return [(NSObject *)delegate methodSignatureForSelector:selector];
            }
        }
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    for (id<UITextInputDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:invocation.selector]) {
            [invocation invokeWithTarget:delegate];
        }
    }
}

@end
