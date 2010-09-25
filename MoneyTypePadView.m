/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyTypePadView

  Copyright (C) 2009 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import "MoneyTypePadView.h"
#import "MoneyModel.h"

#define kCompactLayout

#define kMarginX	(4)
#define kMarginY	(4)
#define kButtonWidth	(50)
#define kButtonHeight	(30)
#define kButtonSpace (2)

// should store shortname instead of index of UISegment...
#define kCurrencyPrefKey	@"moneypad.currency"
#define kLanguagePrefKey	@"moneypad.language"

typedef struct {
    NSString *label;
    int column;
    int row;
    int width;
} ButtonTable;

const ButtonTable buttons[] = {
    { @"7",0,0,1 },
    { @"8",1,0,1 },
    { @"9",2,0,1 },
    { @"4",0,1,1 },
    { @"5",1,1,1 },
    { @"6",2,1,1 },
    { @"1",0,2,1 },
    { @"2",1,2,1 },
    { @"3",2,2,1 },
#ifdef kCompactLayout
    { @"0",0,3,1 },
    { @".",1,3,1 },
    { @"C",2,3,1 },
#else
    { @"0",0,3,2 },
    { @"000",2,3,1 },
    { @"C",3,0,1 },
    { @".",3,1,1 },
#endif
};

@implementation MoneyTypePadView
@synthesize delegate;
- (void)keyAction:(id)sender {
    NSString *inputText = ((UIButton*)sender).titleLabel.text;
    NSLog(@"%@",inputText);
    if ([inputText compare:@"C"] == 0) {
        if ([delegate respondsToSelector:@selector(moneyTypePadShouldClear:)]) {
            [delegate moneyTypePadShouldClear:self];
        }
    }else{
        if ([delegate respondsToSelector:@selector(moneyTypePadView:shouldAppendText:)]) {
            [delegate moneyTypePadView:self shouldAppendText:((UIButton*)sender).titleLabel.text];
        }
    }
}

- (MoneyUnit*)unit {
    NSString *unitName = nil;
    if (languageSelector.selectedSegmentIndex == 0) {
        // japanese 
        unitName = [[jUnit1Selector titleForSegmentAtIndex:jUnit1Selector.selectedSegmentIndex]
                       stringByAppendingString:
                           [jUnit2Selector titleForSegmentAtIndex:jUnit2Selector.selectedSegmentIndex]];
    } else {
        // english
        unitName = [eUnitSelector titleForSegmentAtIndex:eUnitSelector.selectedSegmentIndex];
    }
    return [[MoneyUnitList sharedManager] searchForShortName:unitName];
}

- (void)changedUnit:(id)sender {
    MoneyUnit *newUnit = self.unit;
    if (newUnit != nil &&
        [delegate respondsToSelector:@selector(moneyTypePadView:shouldChangeUnit:)]) {
        [delegate moneyTypePadView:self shouldChangeUnit:newUnit];
    }
}

- (void)changedLanguage:(id)sender {
    NSInteger selected = ((UISegmentedControl*)sender).selectedSegmentIndex;
    if (selected == 0) {
        // japanese
        eUnitSelector.hidden = true;
        jUnit1Selector.hidden = false;
        jUnit2Selector.hidden = false;
    } else {
        // english
        eUnitSelector.hidden = false;
        jUnit1Selector.hidden = true;
        jUnit2Selector.hidden = true;
    }
    [self changedUnit:nil];
    [[NSUserDefaults standardUserDefaults] setInteger:languageSelector.selectedSegmentIndex forKey:kLanguagePrefKey];
}

- (MoneyCurrency*)currency {
    NSString *label = [currencySelector titleForSegmentAtIndex:currencySelector.selectedSegmentIndex];
    return [[MoneyCurrencyList sharedManager] searchForShortName:label];
}

- (void)changedCurrency:(id)sender {
    MoneyCurrency *newCurrency = self.currency;
    if (newCurrency != nil &&
        [delegate respondsToSelector:@selector(moneyTypePadView:shouldChangeCurrency:)]) {
        [[NSUserDefaults standardUserDefaults] setInteger:currencySelector.selectedSegmentIndex forKey:kCurrencyPrefKey];
        [delegate moneyTypePadView:self shouldChangeCurrency:newCurrency];
    }
}


- (CGRect)logicalPosToRect:(int)column row:(int)row width:(int)width{
    return CGRectMake(kMarginX+column*(kButtonWidth+kButtonSpace),
                      kMarginY+row*(kButtonHeight+kButtonSpace),
                      kButtonWidth+(kButtonWidth+kButtonSpace)*(width-1),kButtonHeight);
}
- (UIButton*)createButtonWithTitle:(NSString*)title column:(int)column row:(int)row width:(int)width{
#if 1
    if (buttonBackground == nil) {
        buttonBackground = [[UIImage imageNamed:@"whiteButton.png"] retain];
    }
    if (buttonBackgroundPressed == nil) {
        buttonBackgroundPressed = [[UIImage imageNamed:@"blueButton.png"] retain];
    }
    UIButton *btn = [[UIButton alloc]
                        initWithFrame:[self logicalPosToRect:column row:row width:width]];
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIImage *newImage = [buttonBackground stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    [btn setBackgroundImage:newImage forState:UIControlStateNormal];
    UIImage *newPressedImage = [buttonBackgroundPressed stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    [btn setBackgroundImage:newPressedImage forState:UIControlStateHighlighted];

#else
    UIButton *btn = [[[UIButton buttonWithType:UIButtonTypeRoundedRect]
                         initWithFrame:[self logicalPosToRect:column row:row width:width]] retain];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
#endif
    btn.backgroundColor = [UIColor clearColor];
    return btn;
}

- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    if (self != nil) {
        self.backgroundColor = [UIColor grayColor];
        //self.backgroundColor = [UIColor groupTableViewBackgroundColor];
        for (int i=0; i < sizeof(buttons)/sizeof(buttons[0]); i++) {
            UIButton *btn = [self createButtonWithTitle:buttons[i].label
                                  column:buttons[i].column row:buttons[i].row width:buttons[i].width];
            [btn addTarget:self action:@selector(keyAction:)
                 forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
            [btn release];
        }
        currencySelector = 
            [[UISegmentedControl alloc]
                initWithItems:[NSArray arrayWithObjects:@"円", @"＄", nil]];
        currencySelector.segmentedControlStyle = UISegmentedControlStyleBordered;
        currencySelector.frame = [self logicalPosToRect:4 row:0 width:2];
        currencySelector.selectedSegmentIndex =
            [[NSUserDefaults standardUserDefaults] integerForKey:kCurrencyPrefKey];
        [currencySelector addTarget:self action:@selector(changedCurrency:)
                          forControlEvents:UIControlEventValueChanged];
        [self addSubview:currencySelector];

        languageSelector = 
            [[UISegmentedControl alloc]
                initWithItems:[NSArray arrayWithObjects:@"日", @"英", nil]];
        languageSelector.segmentedControlStyle = UISegmentedControlStyleBordered;
        languageSelector.frame = [self logicalPosToRect:4 row:1 width:2];
        languageSelector.selectedSegmentIndex = 
            [[NSUserDefaults standardUserDefaults] integerForKey:kLanguagePrefKey];
        [languageSelector addTarget:self action:@selector(changedLanguage:)
                          forControlEvents:UIControlEventValueChanged];
        [self addSubview:languageSelector];

        jUnit1Selector = 
            [[UISegmentedControl alloc]
                initWithItems:[NSArray arrayWithObjects:@"", /*@"十",*/ @"百", @"千", nil]];
        jUnit1Selector.segmentedControlStyle = UISegmentedControlStyleBordered;
        jUnit1Selector.frame = [self logicalPosToRect:3 row:2 width:3];
        jUnit1Selector.selectedSegmentIndex = 0;
        [jUnit1Selector addTarget:self action:@selector(changedUnit:)
                          forControlEvents:UIControlEventValueChanged];
        [self addSubview:jUnit1Selector];

        jUnit2Selector = 
            [[UISegmentedControl alloc]
                initWithItems:[NSArray arrayWithObjects:@"", @"万", @"億", @"兆", nil]];
        jUnit2Selector.segmentedControlStyle = UISegmentedControlStyleBordered;
        jUnit2Selector.frame = [self logicalPosToRect:3 row:3 width:3];
        jUnit2Selector.selectedSegmentIndex = 0;
        [jUnit2Selector addTarget:self action:@selector(changedUnit:)
                          forControlEvents:UIControlEventValueChanged];
        [self addSubview:jUnit2Selector];

        eUnitSelector = 
            [[UISegmentedControl alloc]
                initWithItems:[NSArray arrayWithObjects:@"", @"M", @"B", @"T", nil]];
        eUnitSelector.segmentedControlStyle = UISegmentedControlStyleBordered;
        eUnitSelector.frame = [self logicalPosToRect:3 row:2 width:3];
        eUnitSelector.selectedSegmentIndex = 0;
        [eUnitSelector addTarget:self action:@selector(changedUnit:)
                          forControlEvents:UIControlEventValueChanged];
        [self addSubview:eUnitSelector];
        [self changedLanguage:languageSelector];
    }
    return self;
}

- (void)dealloc {
    [currencySelector release];
    [eUnitSelector release];
    [jUnit2Selector release];
    [jUnit1Selector release];
    [languageSelector release];
    [buttonBackground release];
    [buttonBackgroundPressed release];
    [super dealloc];
}

@end

