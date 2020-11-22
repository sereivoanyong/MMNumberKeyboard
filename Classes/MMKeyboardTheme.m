//
//  MMKeyboardTheme.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 8/7/19.
//  Copyright © 2019 Matías Martínez. All rights reserved.
//

#import "MMKeyboardTheme.h"
#import "UIColor+MMNumberKeyboardAdditions.h"

@implementation MMKeyboardTheme

- (instancetype)init
{
    self = [super init];
    if (self) {
        UIColor *controlColor = [UIColor.blackColor MM_colorWithDarkColor:UIColor.whiteColor];
        
        _controlColor = controlColor;
        _highlightedControlColor = controlColor;
        _disabledFillColor = [UIColor colorWithRed:0.678f green:0.701f blue:0.735f alpha:1];
        _disabledControlColor = [UIColor colorWithRed:0.458f green:0.478f blue:0.499f alpha:1];
        _shadowColor = [UIColor colorWithWhite:0.0f alpha:0.25f];
    }
    return self;
}

+ (instancetype)themeForStyle:(MMKeyboardButtonStyle)style
{
    static MMKeyboardTheme *primaryStyleTheme;
    static MMKeyboardTheme *secondaryStyleTheme;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIColor *darkBackgroundPrimary = [UIColor colorWithWhite:0.365 alpha:1.000];
        UIColor *darkBackgroundSecondary = [UIColor colorWithWhite:0.220 alpha:1.000];
        UIColor *backgroundColorPrimary = [UIColor whiteColor];
        UIColor *backgroundColorSecondary = [UIColor colorWithRed:0.672 green:0.686 blue:0.738 alpha:1.000];
        
        // Primary:
        primaryStyleTheme = [[self alloc] init];
        primaryStyleTheme->_fillColor = [backgroundColorPrimary MM_colorWithDarkColor:darkBackgroundPrimary];
        primaryStyleTheme->_highlightedFillColor = [backgroundColorSecondary MM_colorWithDarkColor:darkBackgroundSecondary];
        
        // Secondary:
        secondaryStyleTheme = [[self alloc] init];
        secondaryStyleTheme->_fillColor = [backgroundColorSecondary MM_colorWithDarkColor:darkBackgroundSecondary];
        secondaryStyleTheme->_highlightedFillColor = [backgroundColorPrimary MM_colorWithDarkColor:darkBackgroundPrimary];
    });
    
    MMKeyboardTheme *theme = nil;
    
    switch (style) {
        case MMKeyboardButtonStylePrimary:
            theme = primaryStyleTheme;
            break;
        case MMKeyboardButtonStyleSecondary:
            theme = secondaryStyleTheme;
            break;
        default:
            [[NSException exceptionWithName:NSInternalInconsistencyException reason:[NSString stringWithFormat:@"The `MMNumberKeyboardButtonStyle` value of (%@) is not supported.", @(style)] userInfo:nil] raise];
            break;
    }
    
    return theme;
}

@end
