//
//  MMKeyboardTheme.h
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 8/7/19.
//  Copyright © 2019 Matías Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MMKeyboardButton.h"

NS_ASSUME_NONNULL_BEGIN

/**
*  A theme object used internally by @c MMNumberKeyboard that defines the color theme for the keyboard.
*/
@interface MMKeyboardTheme : NSObject

/**
 *  Returns an appropiate theme for the specified keyboard button style.
 *
 *  @param style          The style of the button that determines the theme.
 *
 *  @returns An initialized theme object.
 */
+ (instancetype)themeForStyle:(MMKeyboardButtonStyle)style;

/**
 *  The fill color for the buttons.
 */
@property (nonatomic, readonly) UIColor *fillColor;

/**
 *  The fill color for the buttons on their highlighted state.
 */
@property (nonatomic, readonly) UIColor *highlightedFillColor;

/**
 *  The foreground color for text and other elements.
 */
@property (nonatomic, readonly) UIColor *controlColor;

/**
 *  The foreground color for text and other elements on their highlighted state.
 */
@property (nonatomic, readonly) UIColor *highlightedControlColor;

/**
 *  The fill color for the buttons on their disabled state.
 */
@property (nonatomic, readonly) UIColor *disabledFillColor;

/**
 *  The foreground color for text and other elements on their disabled state.
 */
@property (nonatomic, readonly) UIColor *disabledControlColor;

/**
 *  The shadow color of the buttons.
 */
@property (nonatomic, readonly) UIColor *shadowColor;

@end

NS_ASSUME_NONNULL_END
