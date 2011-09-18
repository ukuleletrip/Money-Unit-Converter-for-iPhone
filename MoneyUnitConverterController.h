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
@class ResultHeaderView;

@interface MoneyUnitConverterController : UIViewController <UITableViewDataSource, UITableViewDelegate, MoneyTypePadViewDelegate, GADBannerViewDelegate, UINavigationControllerDelegate, UkllPopupMenuDelegate> {
@private
    MoneyDisplay *inputField;
    MoneyAccount *account;
    UITableView *resultTable;
    MoneyTypePadView *typePad;
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
    // for Ad
    GADBannerView *adView;
    CGFloat adHeight;
    // header
    ResultHeaderView *header;
}
@property (nonatomic, readonly) MoneyCurrency *currency;
- (void)update;
@end
