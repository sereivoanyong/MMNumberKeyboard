//
//  MMKeyboardButton.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 2/12/18.
//  Copyright © 2018 Matías Martínez. All rights reserved.
//

#import "MMKeyboardButton.h"
#import "MMKeyboardTheme.h"

@interface MMKeyboardButton ()

@property (nonatomic, strong) NSTimer *continuousPressTimer;
@property (nonatomic, assign) NSTimeInterval continuousPressTimeInterval;
@property (nonatomic, strong) MMKeyboardTheme *theme;

@end

@implementation MMKeyboardButton

- (instancetype)initWithStyle:(MMKeyboardButtonStyle)style
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _style = style;
        self.theme = [MMKeyboardTheme themeForStyle:self.style];
        [self _updateButtonAppearance];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self _updateButtonAppearance];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.layer.cornerRadius].CGPath;
}

- (void)_updateButtonAppearance
{
    const auto MMKeyboardTheme *theme = self.theme;
    const BOOL isRounded = (self.usesRoundedCorners);
    
    if (!self.isEnabled) {
        self.backgroundColor = theme.disabledFillColor;
        self.imageView.tintColor = theme.disabledControlColor;
    } else {
        if (self.isHighlighted || self.isSelected) {
            self.backgroundColor = theme.highlightedFillColor;
            self.imageView.tintColor = theme.highlightedControlColor;
        } else {
            self.backgroundColor = theme.fillColor;
            self.imageView.tintColor = theme.controlColor;
        }
    }
    
    static const CGFloat radius = 4.0f;
    
    if (theme.fillColor != [UIColor clearColor]) {
        CALayer *buttonLayer = self.layer;
        buttonLayer.cornerRadius = (isRounded) ? radius : 0.0f;
        if (@available(iOS 13.0, *)) {
            buttonLayer.cornerCurve = kCACornerCurveContinuous;
        }
        buttonLayer.shadowOpacity = (isRounded) ? 1.0f : 0.0f;
        buttonLayer.shadowColor = theme.shadowColor.CGColor;
        buttonLayer.shadowOffset = CGSizeMake(0, 1.0f);
        buttonLayer.shadowRadius = 0.0f;
        buttonLayer.rasterizationScale = [UIScreen mainScreen].scale;
        buttonLayer.shouldRasterize = YES;
    }
    
    UIColor *controlColor = theme.controlColor;
    UIColor *highlightedControlColor = theme.highlightedControlColor;
    UIColor *disabledControlColor = theme.disabledControlColor;
    
    [self setTitleColor:controlColor forState:UIControlStateNormal];
    [self setTitleColor:highlightedControlColor forState:UIControlStateSelected];
    [self setTitleColor:highlightedControlColor forState:UIControlStateHighlighted];
    [self setTitleColor:disabledControlColor forState:UIControlStateDisabled];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    [self _updateButtonAppearance];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self _updateButtonAppearance];
}

- (void)setUsesRoundedCorners:(BOOL)usesRoundedCorners
{
    if (usesRoundedCorners != _usesRoundedCorners) {
        _usesRoundedCorners = usesRoundedCorners;
        
        [self _updateButtonAppearance];
    }
}

#pragma mark - Continuous press.

- (void)addTarget:(id)target action:(SEL)action forContinuousPressWithTimeInterval:(NSTimeInterval)timeInterval
{
    self.continuousPressTimeInterval = timeInterval;
    
    [self addTarget:target action:action forControlEvents:UIControlEventValueChanged];
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    BOOL begins = [super beginTrackingWithTouch:touch withEvent:event];
    const NSTimeInterval continuousPressTimeInterval = self.continuousPressTimeInterval;
    
    if (begins && continuousPressTimeInterval > 0) {
        [self _beginContinuousPressDelayed];
    }
    
    return begins;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    [self _cancelContinousPressIfNeeded];
}

- (void)dealloc
{
    [self _cancelContinousPressIfNeeded];
}

- (void)_beginContinuousPress
{
    const NSTimeInterval continuousPressTimeInterval = self.continuousPressTimeInterval;
    
    if (!self.isTracking || continuousPressTimeInterval == 0) {
        return;
    }
    
    self.continuousPressTimer = [NSTimer scheduledTimerWithTimeInterval:continuousPressTimeInterval target:self selector:@selector(_handleContinuousPressTimer:) userInfo:nil repeats:YES];
}

- (void)_handleContinuousPressTimer:(NSTimer *)timer
{
    if (!self.isTracking) {
        [self _cancelContinousPressIfNeeded];
        return;
    }
    
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)_beginContinuousPressDelayed
{
    [self performSelector:@selector(_beginContinuousPress) withObject:nil afterDelay:self.continuousPressTimeInterval * 2.0f];
}

- (void)_cancelContinousPressIfNeeded
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_beginContinuousPress) object:nil];
    
    NSTimer *timer = self.continuousPressTimer;
    if (timer) {
        [timer invalidate];
        
        self.continuousPressTimer = nil;
    }
}

@end
