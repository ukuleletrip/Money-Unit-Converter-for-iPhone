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

@class MoneyDisplay;
@class ResultRenderer;

@interface MoneyUnitConverterController : UIViewController <UITableViewDataSource, UITableViewDelegate, MoneyTypePadViewDelegate> {
@private
    MoneyDisplay *inputField;
    MoneyAccount *account;
    UITableView *resultTable;
    NSMutableArray *resultList;
    ResultRenderer *renderer;
    BOOL isAccountMode;
}
@end
