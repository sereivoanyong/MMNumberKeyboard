//
//  MMNumberKeyboard.h
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//! Project version number for MMNumberKeyboard.
FOUNDATION_EXPORT double MMNumberKeyboardVersionNumber;

//! Project version string for MMNumberKeyboard.
FOUNDATION_EXPORT const unsigned char MMNumberKeyboardVersionString[];

@class MMNumberKeyboard;

/**
 *  The @c MMNumberKeyboardDelegate protocol defines the messages sent to a delegate object as part of the sequence of editing text. All of the methods of this protocol are optional.
 */
@protocol MMNumberKeyboardDelegate <NSObject>
@optional

/**
 *  Asks whether the specified text should be inserted.
 *
 *  @param numberKeyboard The keyboard instance proposing the text insertion.
 *  @param text           The proposed text to be inserted.
 *
 *  @return Returns	@c YES if the text should be inserted or @c NO if it should not.
 */
- (BOOL)numberKeyboard:(MMNumberKeyboard *)numberKeyboard shouldInsertText:(NSString *)text;

/**
 *  Asks the delegate if the keyboard should remove the character just before the cursor.
 *
 *  @param numberKeyboard The keyboard whose return button was pressed.
 *
 *  @return Returns	@c YES if the keyboard should implement its default behavior for the delete backward button; otherwise, @c NO.
 */
- (BOOL)numberKeyboardShouldDeleteBackward:(MMNumberKeyboard *)numberKeyboard;

@end

/**
 *  Specifies the style for the keyboard.
 */
typedef NS_ENUM(NSUInteger, MMNumberKeyboardStyle) {
    /**
     *  An automatic style. It sets the appropiate style to match the appearance of the system keyboard, for example, using rounded buttons on an iPad.
     */
    MMNumberKeyboardStyleAutomatic,
    
    /**
     *  A plain buttons keyboard style. The buttons take the full width of the keyboard and are divided by inline separators. This style is not supported when the keyboard needs to be inset.
     */
    MMNumberKeyboardStylePlainButtons,
    
    /**
     *  A rounded buttons keyboard style. The buttons are displayed with a rounded style, and can be inset from the sides of the keyboard.
     */
    MMNumberKeyboardStyleRoundedButtons
};

/**
 *  A simple keyboard to use with numbers and, optionally, a decimal point.
 */
@interface MMNumberKeyboard : UIInputView

/**
 *  Initializes and returns a number keyboard view using the specified style information and locale.
 *
 *  An initialized view object or @c nil if the view could not be initialized.
 *
 *  @param frame          The frame rectangle for the view, measured in points. The origin of the frame is relative to the superview in which you plan to add it.
 *  @param inputViewStyle The style to use when altering the appearance of the view and its subviews. For a list of possible values, see @c UIInputViewStyle
 *  @param locale         An @c NSLocale object that specifies options (specifically the @c NSLocaleDecimalSeparator) used for the keyboard. Specify @c nil if you want to use the current locale.
 *
 *  @returns An initialized view object or @c nil if the view could not be initialized.
 */
- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle locale:(nullable NSLocale *)locale;

/**
 *  The receiver key input object. If @c nil the object at top of the responder chain is used.
 */
@property (nonatomic, weak, nullable) id <UIKeyInput> keyInput;

/**
 *  Delegate to change text insertion or return key behavior.
 */
@property (nonatomic, weak, nullable) id <MMNumberKeyboardDelegate> delegate;

/**
 *  If @c YES, the decimal separator key will be displayed.
 *
 *  @note The default value of this property is @c NO.
 */
@property (nonatomic, assign) BOOL allowsDecimalPoint;

/**
 *  The preferred keyboard style.
 *
 *  @note The default style for the keyboard is @c MMNumberKeyboardStyleAutomatic.
 */
@property (nonatomic, assign) MMNumberKeyboardStyle preferredStyle;

@end

NS_ASSUME_NONNULL_END
