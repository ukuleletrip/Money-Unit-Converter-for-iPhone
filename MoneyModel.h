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
#define FINANCIAL	(0x01)
#define ENGLISH		(0x02)
#define NATURAL		(0x04)
#define CMAX		(0x08)
#define CMIN		(0x10)

@interface MoneyUnit : NSObject<NSCopying> {
@private
    NSString *name;
    NSString *shortName;
    NSDecimalNumber *value;
    int attribute;
}
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *shortName;
@property (nonatomic, readonly) NSDecimalNumber *value;
@property (nonatomic, readonly) BOOL isFinancial;
@property (nonatomic, readonly) BOOL isNatural;
@property (nonatomic, readonly) BOOL isEnglish;
@property (nonatomic, readonly) BOOL isMin;
@property (nonatomic, readonly) BOOL isMax;
@property (nonatomic, readonly, assign) int attribute;
@end

@interface MoneyUnitList : NSObject {
@private
    NSMutableArray *_list;
}
+ (MoneyUnitList*)sharedManager;
- (MoneyUnit*)unitAtIndex:(NSUInteger)index;
- (NSUInteger)count;
- (MoneyUnit*)searchForShortName:(NSString*)sn;
- (MoneyUnit*)searchForShortName:(NSString*)sn withAttribute:(int)attribute isValue:(int)value;
@end

@interface MoneyCurrency : NSObject<NSCopying> {
@private
    NSString *name;
    NSString *shortName;
    UIImage *image;
    NSString *imageName;
    NSString *updated;
    NSDecimalNumber *rateCache;
}
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *shortName;
@property (nonatomic, readonly) NSDecimalNumber *exchangeForDollar;
@property (nonatomic, readonly) NSString *longName;
@property (nonatomic, readonly) UIImage *image;
@property (nonatomic, copy) NSString *updated;
@end

@interface MoneyCurrencyList : NSObject {
@private
    NSMutableArray *_list;
    NSMutableArray *_enabledList;
}
+ (MoneyCurrencyList*)sharedManager;
- (void)moveCurrency:(NSUInteger)fromIndex to:(NSUInteger)toIndex;
- (MoneyCurrency*)currencyAtAllIndex:(NSUInteger)index;
- (MoneyCurrency*)currencyAtIndex:(NSUInteger)index;
- (NSUInteger)countAll;
- (NSUInteger)count;
- (MoneyCurrency*)searchForName:(NSString*)name;
- (BOOL)isEnabled:(MoneyCurrency*)currency;
- (void)enable:(MoneyCurrency*)currency;
- (void)disable:(MoneyCurrency*)currency;
- (void)saveList;
- (void)update;
@end

@interface MoneyAccount : NSObject {
@private
    NSDecimalNumber *value;
    MoneyUnit *unit;
    MoneyCurrency *currency;
    NSMutableString *buf;
}
@property (nonatomic, retain) NSDecimalNumber *value;
@property (nonatomic, retain) MoneyUnit *unit;
@property (nonatomic, retain) MoneyCurrency *currency;
- (NSString*)text;
- (void)appendText:(NSString*)s;
- (void)clear;
- (NSDecimalNumber*)netValue;
@end
