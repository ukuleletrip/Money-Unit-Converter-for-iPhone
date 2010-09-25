/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyModel

  Copyright (C) 2009-2010 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>

//typedef unsigned long long MoneyInteger;
typedef double MoneyInteger;

@interface MoneyUnit : NSObject<NSCopying> {
    NSString *name;
    NSString *shortName;
    MoneyInteger value;
    bool isFinancial;
}
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *shortName;
@property (nonatomic, readonly) MoneyInteger value;
@property (nonatomic, readonly) bool isFinancial;
@end

@interface MoneyUnitList : NSObject {
@private
    NSMutableArray *_list;
}
+ (MoneyUnitList*)sharedManager;
- (MoneyUnit*)unitAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (MoneyUnit*)searchForShortName:(NSString*)sn;
@end

@interface MoneyCurrency : NSObject<NSCopying> {
    NSString *name;
    NSString *shortName;
@private
    double _exchangeForDollar;
}
@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly, retain) NSString *shortName;
@property (nonatomic, readonly) double exchangeForDollar;
@end

@interface MoneyCurrencyList : NSObject {
@private
    NSMutableArray *_list;
}
+ (MoneyCurrencyList*)sharedManager;
- (MoneyCurrency*)currencyAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (MoneyCurrency*)searchForShortName:(NSString*)sn;
@end

@interface MoneyAccount : NSObject {
    double value;
    MoneyUnit *unit;
    MoneyCurrency *currency;
    NSMutableString *buf;
}
@property (nonatomic, retain) MoneyUnit *unit;
@property (nonatomic, retain) MoneyCurrency *currency;
- (NSString*)text;
- (void)appendText:(NSString*)s;
- (void)clear;
- (double)netValue;
@end
