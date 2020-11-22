//
//  MMTextInputDelegateProxy.h
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 2/13/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  A proxy object used internally by @c MMNumberKeyboard that conveys notifications of pending or transpired changes in text and selection.
 */
@interface MMTextInputDelegateProxy : NSObject

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initializes and returns a proxy delegate object.
 *
 *  An initialized proxy object or @c nil if the proxy could not be initialized.
 *
 *  @param textInput The document object in the application that adopts the @c UITextInput protocol for the purposes of communicating with the text input system.
 *  @param delegate  An input delegate that is notified when text changes or when the selection changes.
 *
 *  @returns An initialized proxy object or @c nil if the proxy could not be initialized.
 */
- (instancetype)initWithTextInput:(nullable id<UITextInput>)textInput delegate:(id<UITextInputDelegate>)delegate NS_DESIGNATED_INITIALIZER;

/**
 *  An input delegate that is notified when text changes or when the selection changes.
 *
 *  @note This would normally be a @c MMNumberKeyboard instance.
 */
@property (nonatomic, weak, readonly, nullable) id<UITextInputDelegate> delegate;

/**
 *  The previous input delegate, so that it is also notified when text changes or when the selection changes.
 *
 *  @note This would normally be a system-assigned delegate.
 */
@property (nonatomic, weak, readonly, nullable) id<UITextInputDelegate> previousTextInputDelegate;

@end

NS_ASSUME_NONNULL_END
