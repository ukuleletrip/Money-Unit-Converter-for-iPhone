//
//  main.m
//  MoneyUnitConverter
//
//  Created by 宮本 哲 on 09/12/28.
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

@interface MoneyUnitConverterController : UIViewController <UITableViewDataSource, UITableViewDelegate, MoneyTypePadViewDelegate> {
    MoneyDisplay *inputField;
    MoneyAccount *account;
    UITableView *resultTable;
    NSMutableArray *resultList;
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
    MoneyUnitList *unitList = [MoneyUnitList sharedManager];

    [resultList removeAllObjects];

    for (int i=0; i < [currencyList count]; i++) {
        MoneyCurrency *currency = [currencyList currencyAtIndex:i];
        NSMutableArray *resultInCurrency = [[NSMutableArray alloc] init];
        for (int j=0; j < [unitList count]; j++) {
            MoneyUnit *unit = [unitList unitAtIndex:j];
            if (!unit.isFinancial) {
                continue;
            }
            //double result = [account netValue]/unit.value*(currency.exchangeForDollar/account.currency.exchangeForDollar);
            double result = [account netValue]*(currency.exchangeForDollar/account.currency.exchangeForDollar)/unit.value;
            //result = floor(result*100)/100;
            //result = floor(result);
            if (unit != [account unit] && result < 10000 && result >= 1) {
                //NSString *resultText = [[[[NSNumber numberWithDouble:result] stringValue] stringByAppendingString:unit.shortName] stringByAppendingString:currency.shortName];
                NSString *resultText = [[[NSString stringWithFormat:(result == (long)result)? @"%.0f" : @"%.2f",result] stringByAppendingString:unit.shortName] stringByAppendingString:currency.shortName];
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
    return [resultList count];
}

// Return how many rows in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [((MoneyResult*)[resultList objectAtIndex:section]).results count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the dictionary at the section index
	MoneyResult *regionDic = [resultList objectAtIndex:section];
    if ([regionDic.currency.name compare:@"USD"] != NSOrderedSame) {
        return [NSString stringWithFormat:@"%@ (%0.2fUSD)", 
                         regionDic.currency.name, regionDic.currency.exchangeForDollar];
    }
	return regionDic.currency.name;
}

// Return a cell for the ith row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Use re-usable cells to minimize the memory load
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (!cell) cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"any-cell"] autorelease];
	
	// Set up the cell's text
    MoneyResult *resultDic = [resultList objectAtIndex:indexPath.section];
    // [P]
    cell.textLabel.text = [resultDic.results objectAtIndex:indexPath.row];
    //cell.textAlignment = UITextAlignmentRight;
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    //cell.textLabel.font = [UIFont systemFontOfSize:16];
	return cell;
}

#pragma mark UITableViewDelegateMethods

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    UIPasteboard *gpBoard = [UIPasteboard generalPasteboard];
    MoneyResult *resultDic = [resultList objectAtIndex:newIndexPath.section];
    gpBoard.string = [resultDic.results objectAtIndex:newIndexPath.row];
	[resultTable deselectRowAtIndexPath:[resultTable indexPathForSelectedRow] animated:YES];
}

- (void)loadView {
	CGRect apprect = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:apprect];
	contentView.backgroundColor = [UIColor whiteColor];
	self.view = contentView;
    [contentView release];

    NSLog(@"sizeof long %d, sizeof long long %d\n", sizeof(long), sizeof(long long));

    MoneyTypePadView *typePad = [[MoneyTypePadView alloc] initWithFrame:CGRectMake(0,280,320,200)];
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
}

// Allow the view to respond to iPhone Orientation changes
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

-(void) dealloc {
	// add any further clean-up here
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
