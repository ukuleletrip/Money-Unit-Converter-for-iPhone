/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyUnitConverterController

  Copyright (C) 2010 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import "MyUtil.h"
#import "MoneyUnitConverterController.h"
#import "MoneyTypePadView.h"
#import "MoneyModel.h"
#import "SettingsViewController.h"
#import "CurrencyResultsCell.h"
#import "GADBannerView.h"

#define kModePrefKey	@"main.accountmode"
#define kCurrencyPrefKey	@"moneypad.currency"
#define kMoneyDisplayWidth (40)
#define kMoneyDisplayHeight (38)
#define kResultTableHeight (280-kMoneyDisplayHeight)
#define kCurrencyPopupWidth (200)
#define kResultHeaderHeight (18)

#define kResultImgWidth		(40)
#define kResultTxtWidth		(135)

//#define DISABLE_AD	(1)

// header view
@interface ResultHeaderView : UIView {
@private
    bool japaneseFirst_;
    UIImageView *img1;
    UIImageView *img2;
}
@property (nonatomic) bool japaneseFirst;
@end

@implementation ResultHeaderView
- (void)setImages {
    UIImageView *jImg = (japaneseFirst_)? img1 : img2;
    UIImageView *uImg = (japaneseFirst_)? img2 : img1;
    jImg.image = [[UIImage imageNamed:@"JapanHeader.png"]
                     stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    uImg.image = [[UIImage imageNamed:@"United-StatesHeader.png"]
                     stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
}

- (bool)japaneseFirst {
    return japaneseFirst_;
}

- (void)setJapaneseFirst:(bool)v {
    japaneseFirst_ = v;
    [self setImages];
}

- (id)initWithFrame:(CGRect)rect {
    if ((self = [super initWithFrame:rect])) {
        japaneseFirst_ = YES;
        img1 = [[UIImageView alloc] 
                   initWithFrame:CGRectMake(kResultImgWidth+2, 0, 
                                            kResultTxtWidth, CGRectGetHeight(rect))];
        img1.contentMode = UIViewContentModeLeft;
        img2 = [[UIImageView alloc] 
                   initWithFrame:CGRectMake(kResultImgWidth+kResultTxtWidth+4, 0,
                                            kResultTxtWidth, CGRectGetHeight(rect))];
        img2.contentMode = UIViewContentModeLeft;
        [self setImages];
        [self addSubview:img1];
        [self addSubview:img2];
        self.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"UnitCalcBack.png"]] autorelease];
    }
    return self;
}

-(void) dealloc {
    [img1 release];
    [img2 release];
	[super dealloc];
}
@end


@interface CurrencyDataSource : NSObject <UITableViewDataSource> {

}
@end

@implementation CurrencyDataSource
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
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                         reuseIdentifier:@"any-cell"] autorelease];
	}
    MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
    cell.textLabel.text = [currencyList currencyAtIndex:indexPath.row].longName;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.imageView.image = [currencyList currencyAtIndex:indexPath.row].image;
	return cell;
}
@end

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
    NSDictionary *dic= [[[NSDictionary alloc] initWithObjectsAndKeys:@".",@"NSDecimalSeparator",nil] autorelease];
    return [[decimal decimalNumberByRoundingAccordingToBehavior:self] descriptionWithLocale:dic];
}

- (NSString*) valueOfWithComma:(NSDecimalNumber*)decimal {
    NSDictionary *dic= [[[NSDictionary alloc]
                            initWithObjectsAndKeys:
                                @".",@"NSDecimalSeparator",@",",@"NSThousandsSeparator",nil] autorelease];
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
        NSDecimalNumber *result = nil;
        double resultDouble = 0;
        @try {
            NSDecimalNumber *unitRate =
                [currency.exchangeForDollar 
                         decimalNumberByDividingBy:account.currency.exchangeForDollar];
            result = [[[account netValue] decimalNumberByMultiplyingBy:unitRate]
                         decimalNumberByDividingBy:unit.value];
            resultDouble = [result doubleValue];
        } @catch (NSException *e) {
            continue;
        }
        if ((currency != account.currency || unit != account.unit) &&
            resultDouble < 100000 && resultDouble >= 0.1) {
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
                         regionDic.currency.shortName
                ];
    }
	return regionDic.currency.longName;
}

- (NSString*)text1ForRow:(NSInteger)section row:(NSInteger)row {
    MoneyResult *resultDic = [resultList objectAtIndex:section];
    return [resultDic.results objectAtIndex:row];
}

- (NSString*)textForRow:(NSInteger)section row:(NSInteger)row {
    return [self text1ForRow:section row:row];
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

// ConverterRenderer is main renderer
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
    NSDecimalNumber *unitRate = nil;
    @try {
        unitRate = [currency.exchangeForDollar decimalNumberByDividingBy:account.currency.exchangeForDollar];
    } @catch (NSException *e) {
        return;
    }
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
        NSDecimalNumber *result = nil;
        double resultDouble = 0;
        @try {
            result = [[[account netValue] decimalNumberByMultiplyingBy:unitRate]
                         decimalNumberByDividingBy:unit.value];
            resultDouble = [result doubleValue];
        } @catch (NSException *e) {
            continue;
        }
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
        renderResult.text3 = [NSString stringWithFormat:@"%@ (%@%@ %@%@)", 
                                       currency.longName,
                                       [self valueOf:unitRate],
                                       currency.shortName,
                                       (currency.updated != nil)?
                                       currency.updated : account.currency.updated,
                                       (currency.updated != nil && [currency.updated length] > 0)?
                                       NSLocalizedString(@"Updated", @"") : @""
                              ];
        renderResult.image = currency.image;
        [resultList addObject:renderResult];
    }
    [renderResult release];
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

@interface MoneyUnitConverterController()
- (void)exchangeUpdated:(NSNotification*)notification;
@end

@implementation MoneyUnitConverterController
- (id)init {
	if (self = [super init]) {
        self.title = NSLocalizedString(@"MainTitle", @"");
        account = [[MoneyAccount alloc] init];
        resultList = [[NSMutableArray alloc] init];
#if defined(DISABLE_AD)
        adHeight = 0;
#else
        adHeight = GAD_SIZE_320x50.height;
#endif
        [[NSNotificationCenter defaultCenter]
            addObserver:self selector:@selector(exchangeUpdated:)
            name:kCurrencyListUpdated object:nil];
	}
	return self;
}

- (CGRect)getTypePadRect {
    return CGRectMake(0, kResultTableHeight+kMoneyDisplayHeight-adHeight,
                      320, 200-64);
}

- (CGRect)getResultTableRect {
    CGFloat headerHeight = (isAccountMode)? 0 : kResultHeaderHeight;
    return CGRectMake(0, kMoneyDisplayHeight+headerHeight,
                      320, kResultTableHeight-adHeight-headerHeight);
}

- (void)adjustAdSpace:(BOOL)isAdd {
    adHeight = (isAdd)? GAD_SIZE_320x50.height : 0;

    CGRect frame;
    frame = resultTable.frame;
    resultTable.frame = [self getResultTableRect];

    frame = typePad.frame;
    typePad.frame = [self getTypePadRect];
}

- (void)requestNewAd {
    adView = [[GADBannerView alloc]
                 initWithFrame:CGRectMake(0.0, 0.0,
                                          GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
    adView.delegate = self;
    adView.adUnitID = @"a14cb910f223f6a";
    adView.rootViewController = self;
    [adView loadRequest:[GADRequest request]];
}

- (void)refreshAd {
    if (adView != nil) {
        // now adview will be updated automatically..
        NSLOG(@"requestFreshAd");
        //[adView requestFreshAd];
        // for AdMob SDK bug? we reuse adview.
        [adView loadRequest:[GADRequest request]];
    } else {
        NSLOG(@"requestNewAd");
        [self requestNewAd];
    }
}

- (void)update {
    [self refreshAd];
    [[MoneyCurrencyList sharedManager] update];
}

#pragma mark UINavigationControllerDelegate Methods
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLOG(@"didShowViewController");
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    NSLOG(@"willShowViewController");

}

#pragma mark GADBannerViewDelegate Methods
/*
#ifdef DEBUG
- (NSArray*)testDevices {
    return [NSArray arrayWithObjects:ADMOB_SIMULATOR_ID,                             // Simulator
                    @"85ba7295761afdc470f8f572b74a9fea293a5c71",
                    nil];
}
#endif
*/

// Sent when an ad request loaded an ad; this is a good opportunity to attach
// the ad view to the hierachy.
- (void)adViewDidReceiveAd:(GADBannerView *)_adView {
    NSLOG(@"GADBannerView: Did receive ad");

    if (adHeight == 0) {
        [self adjustAdSpace:YES];
    }
    CGRect frame = self.view.frame;
    adView.frame = CGRectMake(0.0, frame.size.height-GAD_SIZE_320x50.height,
                              GAD_SIZE_320x50.width, GAD_SIZE_320x50.height);
    [self.view addSubview:adView];
}

// Sent when an ad request failed to load an ad
- (void)adView:(GADBannerView*)_adView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLOG(@"GADBannerView: Did fail to receive ad");
    // see http://goo.gl/zFSoo
    [adView removeFromSuperview];  // Not necessary since never added to a view, but doesn't hurt and is good practice
    //[adView release];
    //adView = nil;
    if (adHeight == 0) {
        return;
    }
    [self adjustAdSpace:NO];
}


- (void)updateResultList {
    header.japaneseFirst = account.unit.isEnglish;

    MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
    [renderer update];
    for (int i=0; i < [currencyList count]; i++) {
        MoneyCurrency *currency = [currencyList currencyAtIndex:i];
        [renderer setResultForCurrency:currency];
    }
    [resultTable reloadData];
}

- (void)exchangeUpdated:(NSNotification*)notification {
    [self updateResultList];
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
#if 1
    static NSString *cellIdentifier = @"CurrencyResultsCell";
	CurrencyResultsCell *cell = (CurrencyResultsCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        UIViewController *dummyUC = [[UIViewController alloc]
                                        initWithNibName:cellIdentifier
                                        bundle: nil];
        cell = (CurrencyResultsCell*)dummyUC.view;
        [dummyUC release];
    }
    //cell.l1Result.font = [UIFont systemFontOfSize:18];
    cell.l1Result.text = [renderer text1ForRow:indexPath.section row:indexPath.row];
    //cell.l2Result.font = [UIFont systemFontOfSize:18];
    cell.l2Result.text = [renderer text2ForRow:indexPath.section row:indexPath.row];
    cell.rateInfo.text = [renderer detailTextForRow:indexPath.section row:indexPath.row];
    cell.flagImage.image = [renderer imageForRow:indexPath.section row:indexPath.row];
#else
	// Use re-usable cells to minimize the memory load
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"] autorelease];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    cell.textLabel.text = [renderer textForRow:indexPath.section row:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.detailTextLabel.text = [renderer detailTextForRow:indexPath.section row:indexPath.row];
    cell.imageView.image = [renderer imageForRow:indexPath.section row:indexPath.row];
#endif
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
    UIBarButtonItem *newBackButton = 
        [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil)
                                  style:UIBarButtonItemStyleBordered
                                  target:nil action:nil] autorelease];
    self.navigationItem.backBarButtonItem = newBackButton;

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
        resultTable.frame = [self getResultTableRect];
    } else {
        renderer = [[ConvertRenderer alloc] init];
        resultTable.rowHeight = 44;
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Account",nil);
        resultTable.frame = [self getResultTableRect];
    }
    renderer.account = account;
    renderer.resultList = resultList;
}

- (void)toggleResultMode {
    [renderer release];
    [self setResultMode:!isAccountMode];
    [self updateResultList];
}

- (MoneyCurrency*)currency {
    NSLOG(@"self.currency %d",currencyIndex);
    return [[MoneyCurrencyList sharedManager] currencyAtIndex:currencyIndex];
}

- (void)updateCurrencySelector {
    self.title = account.currency.longName;
    currencyLabel.text = account.currency.longName;
    [currencySelector setImage:account.currency.image forState:UIControlStateNormal];
    [currencySelector setTitle:@"▼" forState:UIControlStateNormal];
}

- (void)changeCurrency:(NSInteger)newCurrencyIndex {
    currencyIndex = newCurrencyIndex;
    MoneyCurrency *newCurrency = self.currency;
    account.currency = newCurrency;
    inputField.text = [account text];
    [self updateResultList];
    [self updateCurrencySelector];
    if (newCurrency != nil) {
        [[NSUserDefaults standardUserDefaults] setInteger:currencyIndex forKey:kCurrencyPrefKey];
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
    CGPoint pos = [self.view convertPoint:CGPointMake(currencySelector.frame.origin.x, currencySelector.frame.origin.y) toView:currencySelectMenu];
    CGRect appFrame = [[UIScreen mainScreen] applicationFrame];
    int numOfItem = MIN(appFrame.size.height/kPopupItemHeight,
                        [[MoneyCurrencyList sharedManager] count]);
    pos.y -= MAX(0, (pos.y+numOfItem*kPopupItemHeight)-currencySelectMenu.frame.size.height);
    currencySelectMenu.menuRect =
        CGRectMake(pos.x, pos.y, 
                   kCurrencyPopupWidth, numOfItem*kPopupItemHeight);

    currencySelectMenu.hidden = NO;
    [currencySelector cancelTrackingWithEvent:nil];
}

- (void)currencySelectorPressed:(id)sender {
    timer = [[NSTimer scheduledTimerWithTimeInterval:0.3
                      target:self
                      selector:@selector(handleTimer:)
                      userInfo:nil
                      repeats:NO] retain];
}

- (void)currencySelectorCanceled:(id)sender {
    [timer invalidate];
    [timer release];
}

- (void)popupMenu:(UkllPopupMenu*)popupMenu didItemSelected:(NSInteger)index {
    [self changeCurrency:index];
}

//- (void)loadView {
- (void)viewDidLoad {
    [super viewDidLoad];
	CGRect apprect = [[UIScreen mainScreen] applicationFrame];
	UIView *contentView = [[UIView alloc] initWithFrame:apprect];
	contentView.backgroundColor = [UIColor darkGrayColor];
	self.view = contentView;
    [contentView release];

    currencyIndex =  [[NSUserDefaults standardUserDefaults] integerForKey:kCurrencyPrefKey];

    typePad = [[MoneyTypePadView alloc] initWithFrame:[self getTypePadRect]];
    typePad.delegate = self;
    account.currency = [[MoneyCurrencyList sharedManager] currencyAtIndex:currencyIndex];
    account.unit = typePad.unit;
    [contentView addSubview:typePad];

    currencySelector = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
                                                                  kMoneyDisplayWidth,
                                                                  kMoneyDisplayHeight)];
    currencySelector.titleLabel.font = [UIFont systemFontOfSize:8];
    currencySelector.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    currencySelector.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    UIImage *bimg = [[UIImage imageNamed:@"whiteButton.png"]
                        stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    UIImage *bpimg = [[UIImage imageNamed:@"blueButton.png"]
                         stretchableImageWithLeftCapWidth:0.0 topCapHeight:0.0];
    [currencySelector setBackgroundImage:bimg forState:UIControlStateNormal];
    [currencySelector setBackgroundImage:bpimg forState:UIControlStateHighlighted];
    [currencySelector setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [currencySelector addTarget:self action:@selector(currencySelectorClicked:)
                      forControlEvents:UIControlEventTouchUpInside];
    [currencySelector addTarget:self action:@selector(currencySelectorPressed:)
                      forControlEvents:UIControlEventTouchDown];
    [currencySelector addTarget:self action:@selector(currencySelectorCanceled:)
                      forControlEvents:UIControlEventTouchUpOutside|UIControlEventTouchCancel];
    [contentView addSubview:currencySelector];

    inputField = [[MoneyDisplay alloc] initWithFrame:CGRectMake(kMoneyDisplayWidth, 0,
                                                                320-kMoneyDisplayWidth,
                                                                kMoneyDisplayHeight)];
    inputField.textColor = [UIColor blackColor];
    inputField.font = [UIFont systemFontOfSize:30.0];
    inputField.text = [account text];
    inputField.userInteractionEnabled = YES;
    inputField.textAlignment = UITextAlignmentRight;
    inputField.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
    inputField.adjustsFontSizeToFitWidth = YES;
    inputField.backgroundColor = [[[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"UnitCalcBack.png"]] autorelease];
    [contentView addSubview:inputField];

    currencyLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 45)];
    currencyLabel.textColor = [UIColor whiteColor];
    currencyLabel.font = [UIFont boldSystemFontOfSize:20.0];
    currencyLabel.adjustsFontSizeToFitWidth = YES;
    currencyLabel.textAlignment = UITextAlignmentCenter;
    currencyLabel.backgroundColor = [UIColor clearColor];
    [self navigationController].navigationBar.topItem.titleView = currencyLabel;

    header = [[ResultHeaderView alloc] initWithFrame:CGRectMake(0, kMoneyDisplayHeight,
                                                                320, kResultHeaderHeight)];
    [contentView addSubview:header];

    resultTable = [[UITableView alloc] initWithFrame:[self getResultTableRect]
                                       style:UITableViewStylePlain];
    resultTable.backgroundColor = [UIColor whiteColor];
    resultTable.delegate = self;
    resultTable.dataSource = self;
    resultTable.rowHeight = (isAccountMode)? 24 : 44;
    [resultTable reloadData];
    [contentView addSubview:resultTable];
#if !defined(DISABLE_AD)
    [self requestNewAd];
#endif
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

    currencyDs = [[CurrencyDataSource alloc] init];
    currencySelectMenu = [[UkllPopupMenu alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    currencySelectMenu.opaque = NO;
    currencySelectMenu.dataSource = currencyDs;
    currencySelectMenu.delegate = self;
    currencySelectMenu.hidden = YES;
    [[UIApplication sharedApplication].keyWindow addSubview:currencySelectMenu];

    [self updateCurrencySelector];
}

// Allow the view to respond to iPhone Orientation changes
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return NO;
}

-(void) dealloc {
	// add any further clean-up here
    [header release];
    [currencyLabel release];
    [currencySelectMenu release];
    [currencySelector release];
    [currencyDs release];
    [adView release];
    [renderer release];
    [typePad release];
    [resultList release];
    [resultTable release];
    [account release];
    [inputField release];
	[super dealloc];
}
@end
