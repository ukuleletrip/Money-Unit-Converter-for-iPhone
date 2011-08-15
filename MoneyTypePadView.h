/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyTypePadView

  Copyright (C) 2009 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import "UkllPopupMenu.h"

@protocol MoneyTypePadViewDelegate;
@class MoneyUnit;
@class MoneyCurrency;

@interface MoneyTypePadView : UIView <UIPickerViewDelegate, UITableViewDataSource, UkllPopupMenuDelegate> {
    UIImage *buttonBackground;
    UIImage *buttonBackgroundPressed;
    id <MoneyTypePadViewDelegate> delegate;
@private
    UISegmentedControl *languageSelector;
    UIButton *currencySelector;
    UISegmentedControl *jUnit1Selector;
    UISegmentedControl *jUnit2Selector;
    UISegmentedControl *eUnit1Selector;
    UISegmentedControl *eUnit2Selector;
    UkllPopupMenu *currencySelectMenu;
    NSInteger currencyIndex;
    NSTimer *timer;
}
@property (nonatomic, assign) id <MoneyTypePadViewDelegate> delegate;
@property (nonatomic, readonly) MoneyCurrency *currency;
@property (nonatomic, readonly) MoneyUnit *unit;
@end

@protocol MoneyTypePadViewDelegate <NSObject>
@optional
- (void)moneyTypePadView:(MoneyTypePadView*)view shouldAppendText:(NSString*)text;
- (void)moneyTypePadView:(MoneyTypePadView*)view shouldChangeUnit:(MoneyUnit*)unit;
- (void)moneyTypePadView:(MoneyTypePadView*)view shouldChangeCurrency:(MoneyCurrency*)currency;
- (void)moneyTypePadShouldClear:(MoneyTypePadView*)view;
- (void)moneyTypePadShouldReturn:(MoneyTypePadView*)view;
@end
