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

@interface MoneyTypePadView : UIView <UIPickerViewDelegate> {
    UIImage *buttonBackground;
    UIImage *buttonBackgroundPressed;
    id <MoneyTypePadViewDelegate> delegate;
@private
    UISegmentedControl *languageSelector;
    UISegmentedControl *jUnit1Selector;
    UISegmentedControl *jUnit2Selector;
    UISegmentedControl *eUnit1Selector;
    UISegmentedControl *eUnit2Selector;
}
@property (nonatomic, assign) id <MoneyTypePadViewDelegate> delegate;
@property (nonatomic, readonly) MoneyUnit *unit;
@end

@protocol MoneyTypePadViewDelegate <NSObject>
@optional
- (void)moneyTypePadView:(MoneyTypePadView*)view shouldAppendText:(NSString*)text;
- (void)moneyTypePadView:(MoneyTypePadView*)view shouldChangeUnit:(MoneyUnit*)unit;
- (void)moneyTypePadShouldClear:(MoneyTypePadView*)view;
- (void)moneyTypePadShouldReturn:(MoneyTypePadView*)view;
@end
