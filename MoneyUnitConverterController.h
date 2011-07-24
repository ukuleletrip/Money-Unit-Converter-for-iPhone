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
#import "GADBannerViewDelegate.h"

@class MoneyDisplay;
@class ResultRenderer;
@class GADBannerView;
@class MoneyTypePadView;

@interface MoneyUnitConverterController : UIViewController <UITableViewDataSource, UITableViewDelegate, MoneyTypePadViewDelegate, GADBannerViewDelegate, UINavigationControllerDelegate> {
@private
    MoneyDisplay *inputField;
    MoneyAccount *account;
    UITableView *resultTable;
    MoneyTypePadView *typePad;
    GADBannerView *adView;
    NSMutableArray *resultList;
    ResultRenderer *renderer;
    BOOL isAccountMode;
}
- (void)update;
@end
