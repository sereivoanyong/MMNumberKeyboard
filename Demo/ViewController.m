//
//  ViewController.m
//  MMNumberKeyboard
//
//  Created by Matías Martínez on 12/10/15.
//  Copyright © 2015 Matías Martínez. All rights reserved.
//

#import "ViewController.h"
#import "MMNumberKeyboardView.h"

@interface ViewController () <MMNumberKeyboardViewDelegate>

@property (strong, nonatomic) UITextField *textField;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Create and configure the keyboard.
    MMNumberKeyboardView *keyboardView = [[MMNumberKeyboardView alloc] initWithFrame:CGRectZero];
    keyboardView.allowsDecimalPoint = YES;
    keyboardView.delegate = self;
    
    // Configure an example UITextField.
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.inputView = keyboardView;
    textField.text = @(123456789).stringValue;
    textField.placeholder = @"Type something…";
    textField.font = [UIFont systemFontOfSize:24.0f];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    
    self.textField = textField;
    
    [self.view addSubview:textField];
    
    // Setup view.
    UIColor *backgroundColor = [UIColor whiteColor];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000
    if (@available(iOS 13.0, *)) {
        backgroundColor = [UIColor systemBackgroundColor];
    }
#endif
    
    self.view.backgroundColor = backgroundColor;
}

#pragma mark - Layout.

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect bounds = (CGRect){
        .size = self.view.bounds.size
    };
    
    CGRect contentRect = UIEdgeInsetsInsetRect(bounds, (UIEdgeInsets){
        .top = self.topLayoutGuide.length,
        .bottom = self.bottomLayoutGuide.length,
    });
    
    const CGFloat pad = 20.0f;
    
    self.textField.frame = CGRectInset(contentRect, pad, pad);
}

#pragma mark - View events.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.textField becomeFirstResponder];
}

@end
