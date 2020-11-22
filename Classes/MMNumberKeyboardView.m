//
//  MMNumberKeyboardView.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import "MMNumberKeyboardView.h"
#import "MMKeyButton.h"
#import "MMTextInputDelegateProxy.h"
#import "UIColor+MMNumberKeyboardAdditions.h"

typedef NS_ENUM(NSUInteger, MMNumberKeyboardButton) {
    MMNumberKeyboardButtonNumberMin,
    MMNumberKeyboardButtonNumberMax = MMNumberKeyboardButtonNumberMin + 10, // Ten digits.
    MMNumberKeyboardButtonBackspace,
    MMNumberKeyboardButtonDecimalPoint,
    MMNumberKeyboardButtonNone = NSNotFound,
};

@interface MMNumberKeyboardView () <UIInputViewAudioFeedback, UITextInputDelegate>

@property (nonatomic, strong) NSDictionary<NSNumber *, MMKeyButton *> *buttonDictionary;
@property (nonatomic, strong) NSMutableArray<UIView *> *separatorViews;
@property (nonatomic, strong) MMTextInputDelegateProxy *keyInputProxy;

@end

__weak static id currentFirstResponder;

@implementation UIResponder (FirstResponder)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-repeated-use-of-weak"
+ (id)MM_currentFirstResponder
{
    currentFirstResponder = nil;
    [[UIApplication sharedApplication] sendAction:@selector(MM_findFirstResponder:) to:nil from:nil forEvent:nil];
    return currentFirstResponder;
}
#pragma clang diagnostic pop

- (void)MM_findFirstResponder:(id)sender
{
    currentFirstResponder = self;
}

@end

@implementation MMNumberKeyboardView

static const NSInteger MMNumberKeyboardRows = 4;
static const CGFloat MMNumberKeyboardRowHeight = 55.0f;
static const CGFloat MMNumberKeyboardPadBorder = 7.0f;
static const CGFloat MMNumberKeyboardPadSpacing = 8.0f;

@synthesize locale = _locale;

#define UIKitLocalizedString(key) [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] localizedStringForKey:key value:@"" table:nil]

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame inputViewStyle:(UIInputViewStyle)inputViewStyle
{
    self = [super initWithFrame:frame inputViewStyle:inputViewStyle];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (void)_commonInit
{
    // Configure buttons.
    [self _configureButtonsForCurrentStyle];
    
    // Initialize an array for the separators.
    self.separatorViews = [NSMutableArray array];
    
    // If an input view contains the .flexibleHeight option, the view will be sized as the default keyboard. This doesn't make much sense in the iPad, as we prefer a more compact keyboard.
    if ([UIDevice currentDevice].userInterfaceIdiom != UIUserInterfaceIdiomPad) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    } else {
        [self sizeToFit];
    }
}

- (void)_configureButtonsForCurrentStyle
{
    NSMutableDictionary<NSNumber *, MMKeyButton *> *buttonDictionary = [NSMutableDictionary dictionary];
    
    const NSUInteger numberMin = MMNumberKeyboardButtonNumberMin;
    const NSUInteger numberMax = MMNumberKeyboardButtonNumberMax;
    
    UIFont *buttonFont = [UIFont systemFontOfSize:28.0f weight:UIFontWeightLight];
    
    for (MMNumberKeyboardButton key = numberMin; key < numberMax; key++) {
        MMKeyButton *button = [[MMKeyButton alloc] initWithStyle:MMKeyButtonStylePrimary];
        button.titleLabel.font = buttonFont;
        NSString *title = @(key - numberMin).stringValue;
        [button setTitle:title forState:UIControlStateNormal];
        buttonDictionary[@(key)] = button;
    }
    
    MMKeyButton *backspaceButton = [[MMKeyButton alloc] initWithStyle:MMKeyButtonStyleSecondary];
    UIImage *backspaceImage = [[[self class] _keyboardImageNamed:@"MMNumberKeyboardDeleteKey.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [backspaceButton setImage:backspaceImage forState:UIControlStateNormal];
    [backspaceButton addTarget:self action:@selector(_backspaceRepeat:) forContinuousPressWithTimeInterval:0.15f];
    buttonDictionary[@(MMNumberKeyboardButtonBackspace)] = backspaceButton;
    
    MMKeyButton *decimalPointButton = [[MMKeyButton alloc] initWithStyle:MMKeyButtonStyleSecondary];
    NSString *decimalSeparator = [self.locale objectForKey:NSLocaleDecimalSeparator] ?: @".";
    [decimalPointButton setTitle:decimalSeparator forState:UIControlStateNormal];
    buttonDictionary[@(MMNumberKeyboardButtonDecimalPoint)] = decimalPointButton;
    
    for (MMKeyButton *button in buttonDictionary.objectEnumerator) {
        button.exclusiveTouch = YES;
        [button addTarget:self action:@selector(_buttonInput:) forControlEvents:UIControlEventTouchUpInside];
        [button addTarget:self action:@selector(_buttonPlayClick:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:button];
    }
    
    UIPanGestureRecognizer *highlightGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(_handleHighlightGestureRecognizer:)];
    [self addGestureRecognizer:highlightGestureRecognizer];
    
    self.buttonDictionary = buttonDictionary;
}

#pragma mark - Input.

- (void)_handleHighlightGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
{
    CGPoint point = [gestureRecognizer locationInView:self];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateChanged || gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        for (MMKeyButton *button in self.buttonDictionary.objectEnumerator) {
            BOOL points = CGRectContainsPoint(button.frame, point) && !button.isHidden;
            
            if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
                button.highlighted = points;
            } else {
                button.highlighted = NO;
            }
            
            if (gestureRecognizer.state == UIGestureRecognizerStateEnded && points) {
                [button sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (void)_buttonPlayClick:(MMKeyButton *)button
{
    [[UIDevice currentDevice] playInputClick];
}

- (void)_buttonInput:(MMKeyButton *)button
{
    __block MMNumberKeyboardButton keyboardButton = MMNumberKeyboardButtonNone;
    
    [self.buttonDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, MMKeyButton *obj, BOOL *stop) {
        MMNumberKeyboardButton k = key.unsignedIntegerValue;
        if (button == obj) {
            keyboardButton = k;
            *stop = YES;
        }
    }];
    
    if (keyboardButton == MMNumberKeyboardButtonNone) {
        return;
    }
    
    // Get first responder.
    id<UIKeyInput> keyInput = self.keyInput;
    id<MMNumberKeyboardViewDelegate> delegate = self.delegate;
    
    if (!keyInput) {
        return;
    }
    
    // Handle number.
    const NSInteger numberMin = MMNumberKeyboardButtonNumberMin;
    const NSInteger numberMax = MMNumberKeyboardButtonNumberMax;
    
    if (keyboardButton >= numberMin && keyboardButton < numberMax) {
        NSNumber *number = @(keyboardButton - numberMin);
        NSString *string = number.stringValue;
        
        if ([delegate respondsToSelector:@selector(numberKeyboardView:shouldInsertText:)]) {
            BOOL shouldInsert = [delegate numberKeyboardView:self shouldInsertText:string];
            if (!shouldInsert) {
                return;
            }
        }
        
        [keyInput insertText:string];
    }
    
    // Handle backspace.
    else if (keyboardButton == MMNumberKeyboardButtonBackspace) {
        BOOL shouldDeleteBackward = YES;
		
        if ([delegate respondsToSelector:@selector(numberKeyboardViewShouldDeleteBackward:)]) {
            shouldDeleteBackward = [delegate numberKeyboardViewShouldDeleteBackward:self];
        }
		
        if (shouldDeleteBackward) {
            [keyInput deleteBackward];
        }
    }
    
    // Handle .
    else if (keyboardButton == MMNumberKeyboardButtonDecimalPoint) {
        NSString *decimalText = [button titleForState:UIControlStateNormal];
        if ([delegate respondsToSelector:@selector(numberKeyboardView:shouldInsertText:)]) {
            BOOL shouldInsert = [delegate numberKeyboardView:self shouldInsertText:decimalText];
            if (!shouldInsert) {
                return;
            }
        }
        
        [keyInput insertText:decimalText];
    }
}

- (void)_backspaceRepeat:(MMKeyButton *)button
{
    id<UIKeyInput> keyInput = self.keyInput;
    
    if (!keyInput.hasText) {
        return;
    }
    
    [self _buttonPlayClick:button];
    [self _buttonInput:button];
}

- (id<UIKeyInput>)keyInput
{
    id<UIKeyInput> keyInput = _keyInput;
    
    if (!keyInput) {
        keyInput = [UIResponder MM_currentFirstResponder];
        
        if (![keyInput conformsToProtocol:@protocol(UIKeyInput)]) {
            NSLog(@"Warning: First responder %@ does not conform to the UIKeyInput protocol.", keyInput);
            keyInput = nil;
        }
    }
    
    MMTextInputDelegateProxy *keyInputProxy = _keyInputProxy;
    
    if (keyInput != _keyInput) {
        if ([_keyInput conformsToProtocol:@protocol(UITextInput)]) {
            id<UITextInput> _textInput = (id<UITextInput>)_keyInput;
            _textInput.inputDelegate = keyInputProxy.previousTextInputDelegate;
        }
        
        if ([keyInput conformsToProtocol:@protocol(UITextInput)]) {
            id<UITextInput> textInput = (id<UITextInput>)keyInput;
            keyInputProxy = [[MMTextInputDelegateProxy alloc] initWithTextInput:textInput delegate:self];
            textInput.inputDelegate = (id)keyInputProxy;
        } else {
            keyInputProxy = nil;
        }
    }
    
    _keyInput = keyInput;
    _keyInputProxy = keyInputProxy;
    
    return keyInput;
}

#pragma mark - <UITextInputDelegate>

- (void)selectionWillChange:(id<UITextInput>)textInput
{
    // Intentionally left unimplemented in conformance with <UITextInputDelegate>.
}

- (void)selectionDidChange:(id<UITextInput>)textInput
{
    // Intentionally left unimplemented in conformance with <UITextInputDelegate>.
}

- (void)textWillChange:(id<UITextInput>)textInput
{
    // Intentionally left unimplemented in conformance with <UITextInputDelegate>.
}

- (void)textDidChange:(id<UITextInput>)textInput
{
    // Intentionally left unimplemented in conformance with <UITextInputDelegate>.
}

#pragma mark - Public.

- (NSLocale *)locale
{
    return _locale ?: [NSLocale currentLocale];
}

- (void)setLocale:(NSLocale *)locale
{
    if (locale == _locale) {
        return;
    }
    _locale = locale;
    UIButton *decimalPointButton = self.buttonDictionary[@(MMNumberKeyboardButtonDecimalPoint)];
    NSString *decimalSeparator = [self.locale objectForKey:NSLocaleDecimalSeparator] ?: @".";
    [decimalPointButton setTitle:decimalSeparator forState:UIControlStateNormal];
}

- (void)setAllowsDecimalPoint:(BOOL)allowsDecimalPoint
{
    if (allowsDecimalPoint != _allowsDecimalPoint) {
        _allowsDecimalPoint = allowsDecimalPoint;
        
        [self setNeedsLayout];
    }
}

- (void)setPreferredStyle:(MMNumberKeyboardViewStyle)style
{
    if (style != _preferredStyle) {
        _preferredStyle = style;
        
        [self setNeedsLayout];
    }
}

#pragma mark - Layout.

NS_INLINE CGRect MMButtonRectMake(CGRect rect, CGRect contentRect, BOOL usesRoundedCorners)
{
    rect = CGRectOffset(rect, contentRect.origin.x, contentRect.origin.y);
    
    if (usesRoundedCorners) {
        CGFloat inset = MMNumberKeyboardPadSpacing / 2.0f;
        rect = CGRectInset(rect, inset, inset);
    }
    
    return rect;
};

#if CGFLOAT_IS_DOUBLE
#define MMRound round
#else
#define MMRound roundf
#endif

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = (CGRect) {
        .size = self.bounds.size
    };
    
    UIEdgeInsets insets = UIEdgeInsetsZero;
    
    if (@available(iOS 11.0, *)) {
        insets = self.safeAreaInsets;
    }
    
    NSDictionary<NSNumber *, MMKeyButton *> *buttonDictionary = self.buttonDictionary;
    NSMutableArray<UIView *> *separatorViews = self.separatorViews;
    
    // Settings.
    BOOL usesRoundedButtons = NO;
    
    if ([UITraitCollection class]) {
        const BOOL hasMargins = !UIEdgeInsetsEqualToEdgeInsets(insets, UIEdgeInsetsZero);
        const BOOL isIdiomPad = self.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiomPad;
        const BOOL systemKeyboardUsesRoundedButtons = self._systemUsesRoundedRectButtonsOnAllInterfaceIdioms;
        
        if (hasMargins || isIdiomPad) {
            usesRoundedButtons = YES;
        } else {
            const BOOL prefersPlainButtons = self.preferredStyle == MMNumberKeyboardViewStylePlainButtons;
            const BOOL prefersRoundedButtons = self.preferredStyle == MMNumberKeyboardViewStyleRoundedButtons;
            
            if (!prefersPlainButtons) {
                usesRoundedButtons = systemKeyboardUsesRoundedButtons || prefersRoundedButtons;
            }
        }
    } else {
        usesRoundedButtons = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad;
    }
    
    const CGFloat spacing = usesRoundedButtons ? MMNumberKeyboardPadBorder : 0.0f;
    const CGFloat maximumWidth = usesRoundedButtons ? 400.0f : CGRectGetWidth(bounds);
    const BOOL allowsDecimalPoint = self.allowsDecimalPoint;
    
    const CGFloat width = MIN(maximumWidth, CGRectGetWidth(bounds) - (spacing * 2.0f));
    
    CGRect contentRect = (CGRect) {
        .origin.x = MMRound((CGRectGetWidth(bounds) - width) / 2.0f),
        .origin.y = spacing,
        .size.width = width,
        .size.height = CGRectGetHeight(bounds) - (spacing * 2.0f)
    };
    
    contentRect = UIEdgeInsetsInsetRect(contentRect, insets);
    
    // Layout.
    const CGFloat columnWidth = CGRectGetWidth(contentRect) / 3.0f;
    const CGFloat rowHeight = CGRectGetHeight(contentRect) / MMNumberKeyboardRows;
    
    CGSize numberSize = CGSizeMake(columnWidth, rowHeight);
    
    // Layout numbers.
    const NSInteger numberMin = MMNumberKeyboardButtonNumberMin;
    const NSInteger numberMax = MMNumberKeyboardButtonNumberMax;
    
    const NSInteger numbersPerLine = 3;
    
    for (MMNumberKeyboardButton key = numberMin; key < numberMax; key++) {
        MMKeyButton *button = buttonDictionary[@(key)];
        NSInteger digit = key - numberMin;
        
        CGRect rect = (CGRect) {
            .size = numberSize
        };
        
        if (digit == 0) {
            rect.origin.y = numberSize.height * 3;
            rect.origin.x = numberSize.width;
            
            if (!allowsDecimalPoint) {
                rect.size.width = numberSize.width * 2.0f;
                button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, numberSize.width);
            }
            
        } else {
            NSUInteger index = digit - 1;
            
            NSInteger line = index / numbersPerLine;
            NSInteger pos = index % numbersPerLine;
            
            rect.origin.y = line * numberSize.height;
            rect.origin.x = pos * numberSize.width;
        }
        
        button.frame = MMButtonRectMake(rect, contentRect, usesRoundedButtons);
    }
    
    // Layout special key.
    MMKeyButton *specialKey = buttonDictionary[@(MMNumberKeyboardButtonDecimalPoint)];
    if (specialKey) {
        CGRect rect = (CGRect) {
            .size = numberSize
        };
        rect.origin.y = numberSize.height * 3;
        
        specialKey.frame = MMButtonRectMake(rect, contentRect, usesRoundedButtons);
    }
    
    // Layout decimal point.
    MMKeyButton *decimalPointKey = buttonDictionary[@(MMNumberKeyboardButtonBackspace)];
    if (decimalPointKey) {
        CGRect rect = (CGRect) {
            .size = numberSize
        };
        rect.origin.y = numberSize.height * 3;
        rect.origin.x = numberSize.width * 2;
        
        decimalPointKey.frame = MMButtonRectMake(rect, contentRect, usesRoundedButtons);
        
        decimalPointKey.hidden = !allowsDecimalPoint;
    }
    
    // Layout separators:
    const BOOL usesSeparators = !usesRoundedButtons;
    
    if (usesSeparators) {
        const NSUInteger totalColumns = 4;
        const NSUInteger totalRows = numbersPerLine + 1;
        const NSUInteger numberOfSeparators = totalColumns + totalRows - 1;
        
        if (separatorViews.count != numberOfSeparators) {
            const NSUInteger delta = numberOfSeparators - separatorViews.count;
            const BOOL removes = separatorViews.count > numberOfSeparators;
            if (removes) {
                NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, delta)];
                [[separatorViews objectsAtIndexes:indexes] makeObjectsPerformSelector:@selector(removeFromSuperview)];
                [separatorViews removeObjectsAtIndexes:indexes];
            } else {
                UIColor *separatorColor = [[UIColor colorWithWhite:0.0f alpha:0.1f] MM_colorWithDarkColor:[UIColor colorWithWhite:0.0f alpha:0.1f]];
                
                NSUInteger separatorsToInsert = delta;
                while (separatorsToInsert--) {
                    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectZero];
                    separatorView.backgroundColor = separatorColor;
                    [self addSubview:separatorView];
                    [separatorViews addObject:separatorView];
                }
            }
        }
        
        const CGFloat separatorDimension = 1.0f / (self.window.screen.scale ?: 1.0f);
        
        [separatorViews enumerateObjectsUsingBlock:^(UIView *separatorView, NSUInteger index, BOOL *stop) {
            CGRect rect = CGRectZero;
            
            if (index < totalRows) {
                rect.origin.y = index * rowHeight;
                if (index % 2) {
                    rect.size.width = CGRectGetWidth(contentRect) - columnWidth;
                } else {
                    rect.size.width = CGRectGetWidth(contentRect);
                }
                rect.size.height = separatorDimension;
            } else {
                NSInteger col = index - totalRows;
                
                rect.origin.x = (col + 1) * columnWidth;
                rect.size.width = separatorDimension;
                
                if (col == 1 && !allowsDecimalPoint) {
                    rect.size.height = CGRectGetHeight(contentRect) - rowHeight;
                } else {
                    rect.size.height = CGRectGetHeight(contentRect);
                }
            }
            
            separatorView.frame = MMButtonRectMake(rect, contentRect, usesRoundedButtons);
        }];
    } else {
        [separatorViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [separatorViews removeAllObjects];
    }
    
    for (MMKeyButton *button in buttonDictionary.allValues) {
        button.usesRoundedCorners = usesRoundedButtons;
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    const CGFloat spacing = [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad ? MMNumberKeyboardPadBorder : 0.0f;
    
    size.height = MMNumberKeyboardRowHeight * MMNumberKeyboardRows + (spacing * 2.0f);
    
    if (size.width == 0.0f) {
        size.width = [UIScreen mainScreen].bounds.size.width;
    }
    
    return size;
}

#pragma mark - Audio feedback.

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

#pragma mark - Accessing keyboard images.

+ (UIImage *)_keyboardImageNamed:(NSString *)name
{
    NSString *resource = name.stringByDeletingPathExtension;
    NSString *extension = name.pathExtension;
    
    if (!resource.length) {
        return nil;
    }

    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    NSString *resourcePath = [bundle pathForResource:resource ofType:extension];

    if (resourcePath.length) {
        return [UIImage imageWithContentsOfFile:resourcePath];
    }

    return [UIImage imageNamed:resource];
}

#pragma mark - Matching the system's appearance.

- (BOOL)_systemUsesRoundedRectButtonsOnAllInterfaceIdioms
{
    static BOOL usesRoundedRectButtons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        usesRoundedRectButtons = [[UIDevice currentDevice].systemVersion compare:@"11.0" options:NSNumericSearch] != NSOrderedAscending;
    });
    return usesRoundedRectButtons;
}

@end
