//
//  main.m
//  MoneyUnitConverter
//
//  Created by Ukulele Trip on 09/12/28.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoneyTypePadView.h"
#import "MoneyModel.h"
#import <QuartzCore/QuartzCore.h>

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
    MoneyCurrency *currentCurrency;
    MoneyUnit *currentUnit;
}
@property(nonatomic, retain) NSMutableArray *resultList;
@property(nonatomic, retain) MoneyAccount *account;
@property(nonatomic, retain) MoneyCurrency *currentCurrency;
@property(nonatomic, retain) MoneyUnit *currentUnit;
- (void)update;
- (void)startCurrency;
- (void)endCurrency;
- (BOOL)shouldCalc;
- (void)setResult:(NSDecimalNumber*)result;
- (NSString*)valueOf:(NSDecimalNumber*)decimal;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSString*)titleForHeaderInSection:(NSInteger)section;
- (NSString*)textForRow:(NSInteger)section row:(NSInteger)row;
@end

@implementation ResultRenderer
@synthesize resultList, account, currentCurrency, currentUnit;
- (id)init {
    if ((self = [super init]) != nil) {

    }
    return self;
}

- (void)dealloc {
    [resultList release];
    [account release];
    [currentCurrency release];
    [currentUnit release];
    [super dealloc];
}

- (void)update {
    [resultList removeAllObjects];
}
- (void)startCurrency {}
- (void)endCurrency {}
- (BOOL)shouldCalc { return NO; }
- (void)setResult:(NSDecimalNumber*)result {}
- (NSInteger)numberOfSections { return 0; }
- (NSInteger)numberOfRowsInSection:(NSInteger)section { return 0; }
- (NSString*)titleForHeaderInSection:(NSInteger)section { return nil; }
- (NSString*)textForRow:(NSInteger)section row:(NSInteger)row { return nil; }

- (NSString*) valueOf:(NSDecimalNumber*)decimal {
    NSDictionary *dic= [[NSDictionary alloc] initWithObjectsAndKeys:@".",@"NSDecimalSeparator",nil];
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
    NSMutableArray *resultInCurrency;
}
@end

@implementation BasicRenderer
- (void)startCurrency {
    resultInCurrency = [[NSMutableArray alloc] init];
}

- (void)endCurrency {
    if ([resultInCurrency count] > 0) {
        MoneyResult *resultDicInCurrency =
            [[MoneyResult alloc] initWithCurrency:currentCurrency resultArray:resultInCurrency];
        [resultList addObject:resultDicInCurrency];
        [resultDicInCurrency release];
    }
    [resultInCurrency release];
}

- (BOOL)shouldCalc {
    return currentUnit.isFinancial;
}

- (void)setResult:(NSDecimalNumber*)result {
    double resultDouble = [result doubleValue];
    if ((currentCurrency != account.currency || currentUnit != account.unit) &&
        resultDouble < 10000 && resultDouble >= 1) {
        NSString *resultText = [[[self valueOf:result] stringByAppendingString:currentUnit.shortName] stringByAppendingString:currentCurrency.shortName];
        [resultInCurrency addObject:resultText];
    }
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

@interface ConvertRenderer : ResultRenderer {
}
@end

@implementation ConvertRenderer
- (BOOL)shouldCalc {
    return currentUnit.isNatural;
}

- (void)setResult:(NSDecimalNumber*)result {
    double resultDouble = [result doubleValue];
    if ((currentCurrency != account.currency || currentUnit != account.unit) &&
        ((currentUnit.isEnglish && resultDouble < 1000) ||
         (!currentUnit.isEnglish && resultDouble < 10000)) && resultDouble >= 1) {
        NSString *resultText = [[[self valueOf:result] stringByAppendingString:currentUnit.shortName] stringByAppendingString:currentCurrency.shortName];
        [resultList addObject:resultText];
    }
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    return [resultList count];
}

- (NSString*)textForRow:(NSInteger)section row:(NSInteger)row {
    return [resultList objectAtIndex:row];
}
@end


@interface MoneyUnitConverterController : UIViewController <UITableViewDataSource, UITableViewDelegate, MoneyTypePadViewDelegate> {
    MoneyDisplay *inputField;
    MoneyAccount *account;
    UITableView *resultTable;
    NSMutableArray *resultList;
    ResultRenderer *renderer;
}
@end

@implementation MoneyUnitConverterController
- (id)init {
	if (self = [super init]) {
        self.title = NSLocalizedString(@"MainTitle", @"");
		//self.title = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
        account = [[MoneyAccount alloc] init];
        resultList = [[NSMutableArray alloc] init];

        //renderer = [[BasicRenderer alloc] init];
        renderer = [[ConvertRenderer alloc] init];
        renderer.account = account;
        renderer.resultList = resultList;
	}
	return self;
}

- (void)updateResultList {
    MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
    MoneyUnitList *unitList = [MoneyUnitList sharedManager];

    [renderer update];

    for (int i=0; i < [currencyList count]; i++) {
        MoneyCurrency *currency = [currencyList currencyAtIndex:i];
        renderer.currentCurrency = currency;
        [renderer startCurrency];
        for (int j=0; j < [unitList count]; j++) {
            MoneyUnit *unit = [unitList unitAtIndex:j];
            renderer.currentUnit = unit;
            if (![renderer shouldCalc]) {
                continue;
            }
            NSDecimalNumber *unitRate =
                [currency.exchangeForDollar 
                         decimalNumberByDividingBy:account.currency.exchangeForDollar];
            NSDecimalNumber *result =
                [[[account netValue] decimalNumberByMultiplyingBy:unitRate]
                    decimalNumberByDividingBy:unit.value];
            [renderer setResult:result];
        }
        [renderer endCurrency];
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
	if (!cell) cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"any-cell"] autorelease];
	// Set up the cell's text
    cell.textLabel.text = [renderer textForRow:indexPath.section row:indexPath.row];
    //cell.textAlignment = UITextAlignmentRight;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
	return cell;
}

#pragma mark UITableViewDelegateMethods

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    gpBoard.string = [renderer textForRow:newIndexPath.section row:newIndexPath.row];
	[resultTable deselectRowAtIndexPath:[resultTable indexPathForSelectedRow] animated:YES];
}

- (void)goSettings {

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
    //resultTable.rowHeight = 24;
    resultTable.rowHeight = 28;
    [resultTable reloadData];
    [contentView addSubview:resultTable];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                                  initWithTitle:NSLocalizedString(@"Settings", nil)
                                                  style:UIBarButtonItemStylePlain
                                                  target:self
                                                  action:@selector(goSettings)] autorelease];
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


@interface MoneyUnitConverterAppDelegate : NSObject <UIApplicationDelegate> {
	UINavigationController *nav;
}
@property (nonatomic, retain)		UINavigationController *nav;
@end

@implementation MoneyUnitConverterAppDelegate
@synthesize nav;
// On launch, create a basic window
- (void)applicationDidFinishLaunching:(UIApplication *)application {	
	UIWindow *window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.nav = [[UINavigationController alloc]
                   initWithRootViewController:[[MoneyUnitConverterController alloc] init]];
	[window addSubview:self.nav.view];
	[window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application  {
	// handle any final state matters here
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {
	[self.nav release];
	[super dealloc];
}

@end

int main(int argc, char *argv[])
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, @"MoneyUnitConverterAppDelegate");
	[pool release];
	return retVal;
}
