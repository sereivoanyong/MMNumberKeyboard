//
//  MMNumberKeyboardView.h
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MMNumberKeyboardView;

/**
 *  The @c MMNumberKeyboardViewDelegate protocol defines the messages sent to a delegate object as part of the sequence of editing text. All of the methods of this protocol are optional.
 */
NS_SWIFT_NAME(NumberKeyboardViewDelegate)
@protocol MMNumberKeyboardViewDelegate <NSObject>

@optional

/**
 *  Asks whether the specified text should be inserted.
 *
 *  @param numberKeyboard The keyboard instance proposing the text insertion.
 *  @param text           The proposed text to be inserted.
 *
 *  @return Returns	@c YES if the text should be inserted or @c NO if it should not.
 */
- (BOOL)numberKeyboardView:(MMNumberKeyboardView *)numberKeyboardView shouldInsertText:(NSString *)text;

/**
 *  Asks the delegate if the keyboard should remove the character just before the cursor.
 *
 *  @param numberKeyboard The keyboard whose return button was pressed.
 *
 *  @return Returns	@c YES if the keyboard should implement its default behavior for the delete backward button; otherwise, @c NO.
 */
- (BOOL)numberKeyboardViewShouldDeleteBackward:(MMNumberKeyboardView *)numberKeyboardView;

@end

/**
 *  Specifies the style for the keyboard.
 */
typedef NS_ENUM(NSUInteger, MMNumberKeyboardViewStyle) {
    /**
     *  An automatic style. It sets the appropiate style to match the appearance of the system keyboard, for example, using rounded buttons on an iPad.
     */
    MMNumberKeyboardViewStyleAutomatic,
    
    /**
     *  A plain buttons keyboard style. The buttons take the full width of the keyboard and are divided by inline separators. This style is not supported when the keyboard needs to be inset.
     */
    MMNumberKeyboardViewStylePlainButtons,
    
    /**
     *  A rounded buttons keyboard style. The buttons are displayed with a rounded style, and can be inset from the sides of the keyboard.
     */
    MMNumberKeyboardViewStyleRoundedButtons
} NS_SWIFT_NAME(NumberKeyboardView.Style);

/**
 *  A simple keyboard to use with numbers and, optionally, a decimal point.
 */
NS_SWIFT_NAME(NumberKeyboardView)
@interface MMNumberKeyboardView : UIInputView <UIInputViewAudioFeedback>

/**
 *  The receiver key input object. If @c nil the object at top of the responder chain is used.
 */
@property (nonatomic, weak, nullable) id <UIKeyInput> keyInput;

/**
 *  Delegate to change text insertion or return key behavior.
 */
@property (nonatomic, weak, nullable) id <MMNumberKeyboardViewDelegate> delegate;

/**
 *  An @c NSLocale object that specifies options (specifically the @c NSLocaleDecimalSeparator) used for the keyboard. Specify @c nil if you want to use the current locale.
 */
@property (nonatomic, strong, null_resettable) NSLocale *locale;

/**
 *  If @c YES, the decimal separator key will be showned.
 *
 *  @note The default value of this property is @c NO.
 */
@property (nonatomic, assign) BOOL showsDecimalSeparatorKey;

/**
 *  The preferred keyboard style.
 *
 *  @note The default style for the keyboard is @c MMNumberKeyboardViewStyleAutomatic.
 */
@property (nonatomic, assign) MMNumberKeyboardViewStyle preferredStyle;

/**
 *  Specifies whether or not the number keyboard view enables input clicks.
 *
 *  @note The default value of this property is @c YES.
 */
@property (nonatomic, assign) BOOL enableInputClicksWhenVisible;

@end

NS_ASSUME_NONNULL_END
