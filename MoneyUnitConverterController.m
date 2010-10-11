/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyUnitConverterController

  Copyright (C) 2010 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import "MoneyUnitConverterController.h"
#import "MoneyTypePadView.h"
#import "MoneyModel.h"
#import "SettingsViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kModePrefKey	@"main.accountmode"

@interface MoneyResult : NSObject {
    MoneyCurrency *currency;
    NSArray *results;
}
@property (nonatomic, retain) MoneyCurrency *currency;
@property (nonatomic, retain) NSArray *results;
- (id)initWithCurrency:(MoneyCurrency*)c resultArray:(NSArray*)array;
@end

@implementation MoneyResult
@synthesize currency, results;
- (id)initWithCurrency:(MoneyCurrency*)c resultArray:(NSArray*)array {
    if ((self = [super init]) != nil) {
        self.currency = c;
        self.results = array;
    }
    return self;
}
- (void)dealloc {
    [currency release];
    [results release];
    [super dealloc];
}
@end

@interface MoneyDisplay : UILabel {
}
@end

@implementation MoneyDisplay
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (![self becomeFirstResponder]) {
        return;
    }

    UIMenuController *theMenu = [UIMenuController sharedMenuController];
    CGRect selectionRect = self.bounds;
    [theMenu setTargetRect:selectionRect inView:self];
    [theMenu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender{
    BOOL retValue = NO;

    if (action == @selector(paste:)) {
        //retValue = ([[UIPasteboard generalPasteboard].string length] > 0)? YES : NO;
        retValue = NO;
    } else if (action == @selector(copy:)) {
        retValue = YES;
    }
    return retValue;
}

- (void)copy:(id)sender {
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    gpBoard.string = self.text;
}

-(void)paste:(id)sender {
    //UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
}
@end

@interface ResultRenderer : NSObject <NSDecimalNumberBehaviors> {
    NSMutableArray *resultList;
    MoneyAccount *account;
}
@property(nonatomic, retain) NSMutableArray *resultList;
@property(nonatomic, retain) MoneyAccount *account;
- (void)update;
- (void)setResultForCurrency:(MoneyCurrency*)currency;
- (NSString*)valueOf:(NSDecimalNumber*)decimal;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString*)titleForHeaderInSection:(NSInteger)section;
- (NSString*)textForRow:(NSInteger)section row:(NSInteger)row;
- (NSString*)text1ForRow:(NSInteger)section row:(NSInteger)row;
- (NSString*)text2ForRow:(NSInteger)section row:(NSInteger)row;
- (NSString*)detailTextForRow:(NSInteger)section row:(NSInteger)row;
- (UIImage*)imageForRow:(NSInteger)section row:(NSInteger)row;
@end

@implementation ResultRenderer
@synthesize resultList, account;
- (id)init {
    if ((self = [super init]) != nil) {

    }
    return self;
}

- (void)dealloc {
    [resultList release];
    [account release];
    [super dealloc];
}

- (void)update {
    [resultList removeAllObjects];
}
- (void)setResultForCurrency:(MoneyCurrency*)currency {}
- (NSInteger)numberOfSections { return 0; }
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return 0; }
- (NSString*)titleForHeaderInSection:(NSInteger)section { return nil; }
- (NSString*)textForRow:(NSInteger)section row:(NSInteger)row { return nil; }
- (NSString*)text1ForRow:(NSInteger)section row:(NSInteger)row { return nil; }
- (NSString*)text2ForRow:(NSInteger)section row:(NSInteger)row { return nil; }
- (NSString*)detailTextForRow:(NSInteger)section row:(NSInteger)row { return nil; }
- (UIImage*)imageForRow:(NSInteger)section row:(NSInteger)row { return nil; }

- (NSString*) valueOf:(NSDecimalNumber*)decimal {
    NSDictionary *dic= [[NSDictionary alloc] initWithObjectsAndKeys:@".",@"NSDecimalSeparator",nil];
    return [[decimal decimalNumberByRoundingAccordingToBehavior:self] descriptionWithLocale:dic];
}

- (NSString*) valueOfWithComma:(NSDecimalNumber*)decimal {
    NSDictionary *dic= [[NSDictionary alloc]
                           initWithObjectsAndKeys:
                               @".",@"NSDecimalSeparator",@",",@"NSThousandsSeparator",nil];
    return [[decimal decimalNumberByRoundingAccordingToBehavior:self] descriptionWithLocale:dic];
}

- (NSRoundingMode)roundingMode {
    return NSRoundPlain;
}

- (short)scale {
    return 2;
}

- (NSDecimalNumber *)exceptionDuringOperation:(SEL)method error:(NSCalculationError)error leftOperand:(NSDecimalNumber *)leftOperand rightOperand:(NSDecimalNumber *)rightOperand {
    return nil;
}
@end

@interface BasicRenderer : ResultRenderer {
@private
}
@end

@implementation BasicRenderer
- (void)setResultForCurrency:(MoneyCurrency*)currency {
    MoneyUnitList *unitList = [MoneyUnitList sharedManager];
    NSMutableArray *resultInCurrency = [[NSMutableArray alloc] init];
    for (int j=0; j < [unitList count]; j++) {
        MoneyUnit *unit = [unitList unitAtIndex:j];
        if (!unit.isFinancial) {
            continue;
        }
        NSDecimalNumber *unitRate =
            [currency.exchangeForDollar 
                     decimalNumberByDividingBy:account.currency.exchangeForDollar];
        NSDecimalNumber *result =
            [[[account netValue] decimalNumberByMultiplyingBy:unitRate]
                decimalNumberByDividingBy:unit.value];
        double resultDouble = [result doubleValue];
        if ((currency != account.currency || unit != account.unit) &&
            /*resultDouble < 10000 && */ resultDouble >= 0.1) {
            NSString *resultText = [[[self valueOfWithComma:result] stringByAppendingString:unit.shortName] stringByAppendingString:currency.shortName];
            [resultInCurrency addObject:resultText];
        }
    }
    if ([resultInCurrency count] > 0) {
        MoneyResult *resultDicInCurrency =
            [[MoneyResult alloc] initWithCurrency:currency resultArray:resultInCurrency];
        [resultList addObject:resultDicInCurrency];
        [resultDicInCurrency release];
    }
    [resultInCurrency release];
}

- (NSInteger)numberOfSections {
    return [resultList count];
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [((MoneyResult*)[resultList objectAtIndex:section]).results count];
}

- (NSString*)titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the dictionary at the section index
	MoneyResult *regionDic = [resultList objectAtIndex:section];
    if ([regionDic.currency.name compare:account.currency.name] != NSOrderedSame) {
        NSDecimalNumber *unitRate = [regionDic.currency.exchangeForDollar decimalNumberByDividingBy:account.currency.exchangeForDollar];
        return [NSString stringWithFormat:@"%@ (%@%@)", 
                         regionDic.currency.longName,
                         [self valueOf:unitRate],
                         account.currency.shortName
                ];
    }
	return regionDic.currency.longName;
}

- (NSString*)textForRow:(NSInteger)section row:(NSInteger)row {
    MoneyResult *resultDic = [resultList objectAtIndex:section];
    return [resultDic.results objectAtIndex:row];
}
@end

@interface ConvertRendererResult : NSObject {
    NSString *text1;
    NSString *text2;
    NSString *text3;
    UIImage *image;
}
@property (nonatomic, retain) NSString *text1;
@property (nonatomic, retain) NSString *text2;
@property (nonatomic, retain) NSString *text3;
@property (nonatomic, retain) UIImage *image;
@end

@implementation ConvertRendererResult
@synthesize text1, text2, text3, image;
- (void)dealloc {
    [text1 release];
    [text2 release];
    [text3 release];
    [image release];
    [super dealloc];
}
@end

@interface ConvertRenderer : ResultRenderer {
@private
}
@end

@implementation ConvertRenderer
- (void)dealloc {
    [super dealloc];
}

typedef struct {

} Unit;

- (void)setResultForCurrency:(MoneyCurrency*)currency {
    ConvertRendererResult *renderResult = [[ConvertRendererResult alloc] init];
    MoneyUnitList *unitList = [MoneyUnitList sharedManager];
    NSDecimalNumber *unitRate =
        [currency.exchangeForDollar decimalNumberByDividingBy:account.currency.exchangeForDollar];
    for (int i=0; i < [unitList count]; i++) {
        MoneyUnit *unit = [unitList unitAtIndex:i];
        if (!unit.isNatural) {
            continue;
        }
        /*
        if (currency == account.currency && unit == account.unit) {
            continue;
        }
        */
        NSDecimalNumber *result =
            [[[account netValue] decimalNumberByMultiplyingBy:unitRate]
                decimalNumberByDividingBy:unit.value];
        double resultDouble = [result doubleValue];
        NSString *resultText = nil;
        if (unit.isEnglish) {
            if ((unit.isMax || resultDouble < 1000) && (unit.isMin || resultDouble >= 1)) {
                resultText = [[[self valueOf:result] stringByAppendingString:unit.shortName] stringByAppendingString:currency.shortName];
            }
        } else {
            if ((unit.isMax || resultDouble < 10000) && (unit.isMin || resultDouble >= 1)) {
                resultText = [[[self valueOf:result] stringByAppendingString:unit.shortName] stringByAppendingString:currency.shortName];
            }
        }
        if (resultText == nil) {
            continue;
        }
        if (account.unit.isEnglish == unit.isEnglish) {
            // same language
            renderResult.text2 = resultText;
        } else {
            // opposite language
            renderResult.text1 = resultText;
        }
    }
    if (renderResult.text1 != nil || renderResult.text2 != nil) {
        renderResult.text3 = [NSString stringWithFormat:@"%@ (%@%@)", 
                                       currency.longName,
                                       [self valueOf:unitRate],
                                       account.currency.shortName];
        renderResult.image = currency.image;
        [resultList addObject:renderResult];
        [renderResult release];
    }
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [resultList count];
}

- (NSString*)textForRow:(NSInteger)section row:(NSInteger)row {
    return [NSString stringWithFormat:@"%@ (%@)", 
                     ((ConvertRendererResult*)[resultList objectAtIndex:row]).text1,
                     ((ConvertRendererResult*)[resultList objectAtIndex:row]).text2];
}

- (NSString*)text1ForRow:(NSInteger)section row:(NSInteger)row {
    return ((ConvertRendererResult*)[resultList objectAtIndex:row]).text1;
}

- (NSString*)text2ForRow:(NSInteger)section row:(NSInteger)row {
    return ((ConvertRendererResult*)[resultList objectAtIndex:row]).text2;
}

- (NSString*)detailTextForRow:(NSInteger)section row:(NSInteger)row {
    return ((ConvertRendererResult*)[resultList objectAtIndex:row]).text3;
}

- (UIImage*)imageForRow:(NSInteger)section row:(NSInteger)row {
    return ((ConvertRendererResult*)[resultList objectAtIndex:row]).image;
}
@end

@implementation MoneyUnitConverterController
- (id)init {
	if (self = [super init]) {
        self.title = NSLocalizedString(@"MainTitle", @"");
		//self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        account = [[MoneyAccount alloc] init];
        resultList = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)updateResultList {
    MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
    [renderer update];
    for (int i=0; i < [currencyList count]; i++) {
        MoneyCurrency *currency = [currencyList currencyAtIndex:i];
        [renderer setResultForCurrency:currency];
    }
    [resultTable reloadData];
}

#pragma mark MoneyTypePadViewDelegate Methods
- (void)moneyTypePadView:(MoneyTypePadView*)view shouldAppendText:(NSString*)text {
    //inputField.text = [inputField.text stringByAppendingString:text];
    [account appendText:text];
    inputField.text = [account text];
    [self updateResultList];
}

- (void)moneyTypePadView:(MoneyTypePadView*)view shouldChangeUnit:(MoneyUnit*)unit {
    account.unit = unit;
    inputField.text = [account text];
    [self updateResultList];
}

- (void)moneyTypePadView:(MoneyTypePadView*)view shouldChangeCurrency:(MoneyCurrency*)currency {
    account.currency = currency;
    inputField.text = [account text];
    [self updateResultList];
}

- (void)moneyTypePadShouldClear:(MoneyTypePadView*)view {
    [account clear];
    inputField.text = [account text];
    [self updateResultList];
}

#pragma mark UITableViewDataSource Methods

// Only one section in this table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [renderer numberOfSections];
}

// Return how many rows in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [renderer numberOfRowsInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [renderer titleForHeaderInSection:section];
}

// Return a cell for the ith row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Use re-usable cells to minimize the memory load
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"any-cell"] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"] autorelease];
    }
    /*
    CGRect imageFrame = CGRectMake(0, 0, 30, 44);
    CGRect label1Frame = CGRectMake(30, 0, 145, 24);
    CGRect label2Frame = CGRectMake(175, 0, 145, 24);
    CGRect label3Frame = CGRectMake(30, 24, 290, 20);

    UIImageView *tmpImg = [[UIImageView alloc] initWithImage:[renderer imageForRow:indexPath.section row:indexPath.row]];
    [cell.contentView addSubview:tmpImg];
    tmpImg.center = CGPointMake(10, 10);
    [tmpImg release];

    UILabel *tmpLabel = [[UILabel alloc] initWithFrame:label1Frame];
    tmpLabel.font = [UIFont systemFontOfSize:18];
    tmpLabel.adjustsFontSizeToFitWidth = YES;
    tmpLabel.text = [renderer text1ForRow:indexPath.section row:indexPath.row];
    [cell.contentView addSubview:tmpLabel];
    [tmpLabel release];

    tmpLabel = [[UILabel alloc] initWithFrame:label2Frame];
    tmpLabel.font = [UIFont systemFontOfSize:18];
    tmpLabel.adjustsFontSizeToFitWidth = YES;
    tmpLabel.text = [renderer text2ForRow:indexPath.section row:indexPath.row];
    [cell.contentView addSubview:tmpLabel];
    [tmpLabel release];

    tmpLabel = [[UILabel alloc] initWithFrame:label3Frame];
    tmpLabel.font = [UIFont systemFontOfSize:16];
    tmpLabel.textColor = [UIColor grayColor];
    tmpLabel.adjustsFontSizeToFitWidth = YES;
    tmpLabel.text = [renderer detailTextForRow:indexPath.section row:indexPath.row];
    [cell.contentView addSubview:tmpLabel];
    [tmpLabel release];
    */
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = [renderer textForRow:indexPath.section row:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = [renderer detailTextForRow:indexPath.section row:indexPath.row];
    cell.imageView.image = [renderer imageForRow:indexPath.section row:indexPath.row];
	return cell;
}

#pragma mark UITableViewDelegateMethods

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    gpBoard.string = [renderer text1ForRow:newIndexPath.section row:newIndexPath.row];
	[resultTable deselectRowAtIndexPath:[resultTable indexPathForSelectedRow] animated:YES];
}

- (void)goSettings {
    SettingsViewController *settingsViewController = [[SettingsViewController alloc] init];
    [[self navigationController] pushViewController:settingsViewController animated:YES];
    [settingsViewController release];
}

- (void)setResultMode:(BOOL)mode {
    isAccountMode = mode;
    [[NSUserDefaults standardUserDefaults] setBool:mode forKey:kModePrefKey];
    if (isAccountMode) {
        renderer = [[BasicRenderer alloc] init];
        resultTable.rowHeight = 24;
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Currency",nil);
    } else {
        renderer = [[ConvertRenderer alloc] init];
        resultTable.rowHeight = 44;
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Account",nil);
    }
    renderer.account = account;
    renderer.resultList = resultList;
}

- (void)toggleResultMode {
    [renderer release];
    [self setResultMode:!isAccountMode];
    [self updateResultList];
}

- (void)loadView {
	CGRect apprect = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:apprect];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
    [contentView release];

    MoneyTypePadView *typePad = [[MoneyTypePadView alloc] initWithFrame:CGRectMake(0,280,320,200-64)];
    typePad.delegate = self;
    account.currency = typePad.currency;
    account.unit = typePad.unit;
    [contentView addSubview:typePad];
    [typePad release];

    inputField = [[MoneyDisplay alloc] initWithFrame:CGRectMake(0,0,320.0,50.0)];
    inputField.textColor = [UIColor blackColor];
    inputField.font = [UIFont systemFontOfSize:30.0];
    inputField.text = [account text];
    inputField.userInteractionEnabled = YES;
    inputField.textAlignment = UITextAlignmentRight;
    //inputField.backgroundColor = [UIColor colorWithRed:241/255.0 green:250/255.0 blue:202/255.0 alpha:1.0];
    inputField.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"UnitCalcBack.png"]] autorelease];
    //inputField.backgroundColor = [UIColor whiteColor];
    //inputField.layer.cornerRadius = 10;
    //inputField.clipsToBounds = true;
    [contentView addSubview:inputField];

    resultTable = [[UITableView alloc]
                    initWithFrame:CGRectMake(0,50.0,320.0,230)
                    style:UITableViewStylePlain];
    resultTable.backgroundColor = [UIColor whiteColor];
    resultTable.delegate = self;
    resultTable.dataSource = self;
    resultTable.rowHeight = (isAccountMode)? 24 : 44;
    [resultTable reloadData];
    [contentView addSubview:resultTable];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithTitle:NSLocalizedString(@"Settings", nil)
                                                  style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(goSettings)] autorelease];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc]
                                                 initWithTitle:NSLocalizedString(@"Account", nil)
                                                 style:UIBarButtonItemStylePlain
                                                 target:self
                                                 action:@selector(toggleResultMode)] autorelease];
    [self setResultMode:[[NSUserDefaults standardUserDefaults] boolForKey:kModePrefKey]];
}

// Allow the view to respond to iPhone Orientation changes
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(void) dealloc {
	// add any further clean-up here
    [renderer release];
    [resultList release];
    [resultTable release];
    [account release];
    [inputField release];
	[super dealloc];
}
@end
