/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyTypePadView

  Copyright (C) 2009 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>

@protocol MoneyTypePadViewDelegate;
@class MoneyUnit;
@class MoneyCurrency;

@interface MoneyTypePadView : UIView {
    UIImage *buttonBackground;
    UIImage *buttonBackgroundPressed;
    id <MoneyTypePadViewDelegate> delegate;
@private
    UISegmentedControl *languageSelector;
    UISegmentedControl *currencySelector;
    UISegmentedControl *jUnit1Selector;
    UISegmentedControl *jUnit2Selector;
    UISegmentedControl *eUnitSelector;
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
