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
#import "AdMobDelegateProtocol.h"

@class MoneyDisplay;
@class ResultRenderer;
@class AdMobView;
@class MoneyTypePadView;

@interface MoneyUnitConverterController : UIViewController <UITableViewDataSource, UITableViewDelegate, MoneyTypePadViewDelegate, AdMobDelegate> {
@private
    MoneyDisplay *inputField;
    MoneyAccount *account;
    UITableView *resultTable;
    MoneyTypePadView *typePad;
    AdMobView *adView;
    NSMutableArray *resultList;
    ResultRenderer *renderer;
    BOOL isAccountMode;
}
@end
