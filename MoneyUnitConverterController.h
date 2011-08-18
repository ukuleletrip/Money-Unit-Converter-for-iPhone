/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyUnitConverterController

  Copyright (C) 2010 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import "MoneyTypePadView.h"
#import "MoneyModel.h"
#import "UkllPopupMenu.h"
#import "GADBannerViewDelegate.h"

@class MoneyDisplay;
@class ResultRenderer;
@class GADBannerView;
@class MoneyTypePadView;
@class CurrencyDataSource;

@interface MoneyUnitConverterController : UIViewController <UITableViewDataSource, UITableViewDelegate, MoneyTypePadViewDelegate, GADBannerViewDelegate, UINavigationControllerDelegate, UkllPopupMenuDelegate> {
@private
    MoneyDisplay *inputField;
    MoneyAccount *account;
    UITableView *resultTable;
    MoneyTypePadView *typePad;
    GADBannerView *adView;
    NSMutableArray *resultList;
    ResultRenderer *renderer;
    BOOL isAccountMode;
    // for currency selector popup
    UIButton *currencySelector;
    UkllPopupMenu *currencySelectMenu;
    NSInteger currencyIndex;
    NSTimer *timer;
    CurrencyDataSource *currencyDs;
    UILabel *currencyLabel;
}
@property (nonatomic, readonly) MoneyCurrency *currency;
- (void)update;
@end
