/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyTypePadView

  Copyright (C) 2009 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "MyUtil.h"
#import "MoneyTypePadView.h"
#import "MoneyModel.h"

#define kCompactLayout

#define kMarginX	(4)
#define kMarginY	(4)
#define kButtonWidth	(50)
#define kButtonHeight	(30)
#define kPopupItemHeight (28)
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

@interface PopupMenu : UIView <UITableViewDelegate> {
@private
    UITableView *table;
    id <PopupMenuDelegate> delegate;
}
@property (nonatomic, assign) id <UITableViewDataSource> dataSource;
@property (nonatomic, assign) id <PopupMenuDelegate> delegate;
@property (nonatomic) CGRect menuRect;
- (void)update;
@end

@implementation PopupMenu
@synthesize delegate;
- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    if (self != nil) {
        //table = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 200) style:UITableViewStylePlain];
        table.delegate = self;
        table.rowHeight = kPopupItemHeight;
        table.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:142.0/255.0 alpha:1.0];
        //table.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        table.separatorColor = [UIColor darkGrayColor];
        [self addSubview:table];
        [table release];

        [self setClipsToBounds:YES];
        //[self layer].cornerRadius = 10.0;
        //[self layer].borderColor = [[UIColor lightGrayColor] CGColor];
        //[self layer].borderWidth = 1.0;
        //[self layer].shadowOpacity = 0.5;
        //[self layer].shadowOffset = CGSizeMake(-10,10);
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLOG(@"touches");
    self.hidden = YES;
}

- (void)setMenuRect:(CGRect)rect {
    NSLOG(@"set table rect");
    table.frame = rect;
}

- (CGRect)menuRect {
    NSLOG(@"read table rect");
    return table.frame;
}

- (void)update {
    [table reloadData];
}

- (id <UITableViewDataSource>)dataSource {
    return table.dataSource;
}

- (void)setDataSource:(id <UITableViewDataSource>)s {
    table.dataSource = s;
    [table reloadData];
}

#pragma mark UITableViewDelegateMethods

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if ([delegate respondsToSelector:@selector(popupMenu:didItemSelected:)]) {
        [delegate popupMenu:self didItemSelected:newIndexPath.row];
    }
    self.hidden = YES;
}
@end

@implementation MoneyTypePadView
@synthesize delegate;
- (void)keyAction:(id)sender {
    NSString *inputText = ((UIButton*)sender).titleLabel.text;
    NSLOG(@"%@",inputText);
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
    int attr = ENGLISH;
    int value = 0;
    if (languageSelector.selectedSegmentIndex == 0) {
        // japanese 
        unitName = [[jUnit1Selector titleForSegmentAtIndex:jUnit1Selector.selectedSegmentIndex]
                       stringByAppendingString:
                           [jUnit2Selector titleForSegmentAtIndex:jUnit2Selector.selectedSegmentIndex]];
    } else {
        // english
        //unitName = [eUnit2Selector titleForSegmentAtIndex:eUnit2Selector.selectedSegmentIndex];
        unitName = [[eUnit1Selector titleForSegmentAtIndex:eUnit1Selector.selectedSegmentIndex]
                       stringByAppendingString:
                           [eUnit2Selector titleForSegmentAtIndex:eUnit2Selector.selectedSegmentIndex]];
        value = ENGLISH;
    }
    return [[MoneyUnitList sharedManager] searchForShortName:unitName withAttribute:attr isValue:value];
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
        eUnit1Selector.hidden = YES;
        eUnit2Selector.hidden = YES;
        jUnit1Selector.hidden = NO;
        jUnit2Selector.hidden = NO;
    } else {
        // english
        eUnit1Selector.hidden = NO;
        eUnit2Selector.hidden = NO;
        jUnit1Selector.hidden = YES;
        jUnit2Selector.hidden = YES;
    }
    [self changedUnit:nil];
    [[NSUserDefaults standardUserDefaults] setInteger:languageSelector.selectedSegmentIndex forKey:kLanguagePrefKey];
}

- (MoneyCurrency*)currency {
    return [[MoneyCurrencyList sharedManager] currencyAtIndex:currencyIndex];
}

- (void)updateCurrencySelector {
    [currencySelector setTitle:self.currency.longName forState:UIControlStateNormal];
    [currencySelector setImage:self.currency.image forState:UIControlStateNormal];
}

- (void)changeCurrency:(NSInteger)newCurrencyIndex {
    currencyIndex = newCurrencyIndex;
    MoneyCurrency *newCurrency = self.currency;
    [self updateCurrencySelector];
    if (newCurrency != nil &&
        [delegate respondsToSelector:@selector(moneyTypePadView:shouldChangeCurrency:)]) {
        [[NSUserDefaults standardUserDefaults] setInteger:currencyIndex forKey:kCurrencyPrefKey];
        [delegate moneyTypePadView:self shouldChangeCurrency:newCurrency];
    }
}

- (void)currencySelectorClicked:(id)sender {
    [timer invalidate];
    [timer release];
    NSInteger currencyCount = [[MoneyCurrencyList sharedManager] count];
    [self changeCurrency:(currencyIndex+1)%currencyCount];
}

- (void)handleTimer:(NSTimer*)timer {
    [currencySelectMenu update];

    // change coordinate from MoneyTypePadView to PopupMenu View.
    CGPoint pos = [self convertPoint:CGPointMake(currencySelector.frame.origin.x, currencySelector.frame.origin.y) toView:currencySelectMenu];
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    int numOfItem = MIN(appFrame.size.height/kPopupItemHeight,
                        [[MoneyCurrencyList sharedManager] count]);
    pos.y -= MAX(0, (pos.y+numOfItem*kPopupItemHeight)-currencySelectMenu.frame.size.height);
    currencySelectMenu.menuRect =
        CGRectMake(pos.x, pos.y, 
                   currencySelector.frame.size.width, numOfItem*kPopupItemHeight);

    currencySelectMenu.hidden = NO;
    [currencySelector cancelTrackingWithEvent:nil];
}

- (void)currencySelectorPressed:(id)sender {
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.4
                      target:self
                      selector:@selector(handleTimer:)
                      userInfo:nil
                      repeats:NO] retain];
}

- (void)currencySelectorCanceled:(id)sender {
    [timer invalidate];
    [timer release];
}

- (CGRect)logicalPosToRect:(int)column row:(int)row width:(int)width{
    return CGRectMake(kMarginX+column*(kButtonWidth+kButtonSpace),
                      kMarginY+row*(kButtonHeight+kButtonSpace),
                      kButtonWidth+(kButtonWidth+kButtonSpace)*(width-1),kButtonHeight);
}
- (UIButton*)createButtonWithTitle:(NSString*)title column:(int)column row:(int)row width:(int)width{
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

    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
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

        currencySelector = [self createButtonWithTitle:self.currency.longName column:3 row:0 width:3];
        [currencySelector addTarget:self action:@selector(currencySelectorClicked:)
                          forControlEvents:UIControlEventTouchUpInside];
        [currencySelector addTarget:self action:@selector(currencySelectorPressed:)
                          forControlEvents:UIControlEventTouchDown];
        [currencySelector addTarget:self action:@selector(currencySelectorCanceled:)
                          forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
        [self addSubview:currencySelector];

        currencyIndex = [[NSUserDefaults standardUserDefaults] integerForKey:kCurrencyPrefKey];
        [self updateCurrencySelector];

        languageSelector = 
            [[UISegmentedControl alloc]
                initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"Japan"],
                                       [UIImage imageNamed:@"United-States"], nil]];
        		//initWithItems:[NSArray arrayWithObjects:@"日", @"英", nil]];
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

        eUnit1Selector = 
            [[UISegmentedControl alloc]
                initWithItems:[NSArray arrayWithObjects:@"", @"h", nil]];
        //initWithItems:[NSArray arrayWithObjects:@"", @"h", @"K", nil]];
        eUnit1Selector.segmentedControlStyle = UISegmentedControlStyleBordered;
        eUnit1Selector.frame = [self logicalPosToRect:4 row:2 width:2];
        eUnit1Selector.selectedSegmentIndex = 0;
        [eUnit1Selector addTarget:self action:@selector(changedUnit:)
                          forControlEvents:UIControlEventValueChanged];
        [self addSubview:eUnit1Selector];

        eUnit2Selector = 
            [[UISegmentedControl alloc]
                initWithItems:[NSArray arrayWithObjects:@"", @"M", @"B", @"T", nil]];
        eUnit2Selector.segmentedControlStyle = UISegmentedControlStyleBordered;
        eUnit2Selector.frame = [self logicalPosToRect:3 row:3 width:3];
        eUnit2Selector.selectedSegmentIndex = 0;
        [eUnit2Selector addTarget:self action:@selector(changedUnit:)
                          forControlEvents:UIControlEventValueChanged];
        [self addSubview:eUnit2Selector];

        [self changedLanguage:languageSelector];

        currencySelectMenu = [[PopupMenu alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        currencySelectMenu.opaque = NO;
        currencySelectMenu.dataSource = self;
        currencySelectMenu.delegate = self;
        currencySelectMenu.hidden = YES;
        [[UIApplication sharedApplication].keyWindow addSubview:currencySelectMenu];
    }
    return self;
}

- (void)dealloc {
    [currencySelector release];
    [eUnit2Selector release];
    [eUnit1Selector release];
    [jUnit2Selector release];
    [jUnit1Selector release];
    [languageSelector release];
    [buttonBackground release];
    [buttonBackgroundPressed release];
    [super dealloc];
}

#pragma mark UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Return how many rows in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
    return [currencyList count];
}

// Return a cell for the ith row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Use re-usable cells to minimize the memory load
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:@"any-cell"] autorelease];
	}
	// Set up the cell's text
    MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
    cell.textLabel.text = [currencyList currencyAtIndex:indexPath.row].longName;
    //cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.imageView.image = [currencyList currencyAtIndex:indexPath.row].image;
	return cell;
}

- (void)popupMenu:(PopupMenu*)popupMenu didItemSelected:(NSInteger)index {
    [self changeCurrency:index];
}

/*
// http://ramin.firoozye.com/2009/09/29/semi-modal-transparent-dialogs-on-the-iphone/
- (void) showModal:(UIView*) modalView {
    UIWindow* mainWindow = (((MyAppDelegate*) [UIApplication sharedApplication].delegate).window);
    CGPoint middleCenter = modalView.center;
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
    modalView.center = offScreenCenter; // we start off-screen
    [mainWindow addSubview:modalView];    // Show it with a transition effect
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.7]; // animation duration in seconds
    modalView.center = middleCenter;
    [UIView commitAnimations];
}

- (void) hideModal:(UIView*) modalView {
    CGSize offSize = [UIScreen mainScreen].bounds.size;
    CGPoint offScreenCenter = CGPointMake(offSize.width / 2.0, offSize.height * 1.5);
    [UIView beginAnimations:nil context:modalView];
    [UIView setAnimationDuration:0.7];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(hideModalEnded:finished:context:)];
    modalView.center = offScreenCenter;
    [UIView commitAnimations];
}

- (void) hideModalEnded:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    UIView* modalView = (UIView *)context;
    [modalView removeFromSuperview];
}
*/
@end

