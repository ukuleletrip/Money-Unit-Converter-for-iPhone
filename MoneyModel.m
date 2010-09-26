/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  MoneyModel

  Copyright (C) 2009 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import "MoneyModel.h"
#import "CurrencyExchange.h"

#define kOnlyFinancialUnit
#define kMaxDigits	(12)

#define kExchangePrefKey	@"moneymodel.exchange.decimal.%@"

@implementation MoneyUnit
@synthesize name,shortName,value,isFinancial;
- (id)initWithName:(NSString*)n shortName:(NSString*)sn value:(NSString*)v isFinancial:(bool)f {
    if ((self = [super init]) != nil) {
        name = n;
        shortName = sn;
        value = [[NSDecimalNumber decimalNumberWithString:v] retain];
        isFinancial = f;
    }
    return self;
}

- (id)initWithName:(NSString*)n shortName:(NSString*)sn decimal:(NSDecimalNumber*)v isFinancial:(bool)f {
    if ((self = [super init]) != nil) {
        name = n;
        shortName = sn;
        value = [v retain];
        isFinancial = f;
    }
    return self;
}

- (void)dealloc {
    [value release];
    [name release];
    [shortName release];
    [super dealloc];
}

// this method is required for copy attribute of property.
- (id)copyWithZone:(NSZone *)zone {
    id newInstance = [[[self class] allocWithZone:zone] initWithName:name shortName:shortName decimal:value isFinancial:isFinancial];
    return newInstance;
}

@end

@implementation MoneyUnitList
static MoneyUnitList *sharedMoneyUnitList = nil; // for singleton
typedef struct {
    NSString *name;
    NSString *shortName;
    bool isFinancial;
    NSString *value;
} MoneyUnitInit;
const MoneyUnitInit units[] = {
    { @"", @"", YES,		@"1" },
    { @"十", @"十", NO,		@"10" },
    { @"百", @"百", NO,		@"100" },
    { @"千", @"千", YES,	@"1000" },
    { @"万", @"万", YES,	@"10000" },
    { @"十万", @"十万", NO,	@"100000" },
    { @"百万", @"百万", YES,	@"1000000" },
    { @"千万", @"千万", NO,	@"10000000" },
    { @"億", @"億", YES,	@"100000000" },
    { @"十億", @"十億", YES,	@"1000000000" },
    { @"百億", @"百億", NO,	@"10000000000" },
    { @"千億", @"千億", NO,	@"100000000000" },
    { @"兆", @"兆", YES,	@"1000000000000" },
    { @"十兆", @"十兆", NO,	@"10000000000000" },
    { @"百兆", @"百兆", NO,	@"100000000000000" },
    { @"千兆", @"千兆", YES,	@"1000000000000000" },
    { @"Million", @"M", YES,	@"1000000" },
    { @"Billion", @"B", YES,	@"1000000000" },
    { @"Trillion", @"T", YES,	@"1000000000000" }
};

- (id)init {
    if ((self = [super init]) != nil) {
        _list = [[NSMutableArray alloc] init];
        for (int i=0; i < sizeof(units)/sizeof(units[0]); i++) {
            MoneyUnit *unit = [[MoneyUnit alloc] initWithName:units[i].name
                                                 shortName:units[i].shortName 
                                                 value:units[i].value
                                                 isFinancial:units[i].isFinancial];
            [_list addObject:unit];
            [unit release];
        }
    }
    return self;
}

- (void)dealloc {
    [_list release];
    [super dealloc];
}

- (MoneyUnit*)unitAtIndex:(NSUInteger)index {
    return [_list objectAtIndex:index];
}

- (NSUInteger)count {
    return _list.count;
}

- (MoneyUnit*)searchForShortName:(NSString*)sn {
    for (int i=0; i < _list.count; i++) {
        MoneyUnit *unit = [_list objectAtIndex:i];
        if ([unit.shortName compare:sn] == NSOrderedSame) {
            return unit;
        }
    }
    return nil;
}

+ (MoneyUnitList*)sharedManager {
    if (sharedMoneyUnitList == nil) {
        sharedMoneyUnitList = [[super allocWithZone:NULL] init];
    }
    return sharedMoneyUnitList;
}
 
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedManager] retain];
}
 
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
 
- (id)retain {
    return self;
}
 
- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}
 
- (void)release {
    //do nothing
}
 
- (id)autorelease {
    return self;
}

@end

@implementation MoneyCurrency
@synthesize name,shortName;
- (id)initWithName:(NSString*)n shortName:(NSString*)sn exchangeForDollar:(NSDecimalNumber*)ex  {
    if ((self = [super init]) != nil) {
        name = n;
        shortName = sn;
        _exchangeForDollar = [ex retain];
    }
    return self;
}

- (void)dealloc {
    [_exchangeForDollar release];
    [name release];
    [shortName release];
    [super dealloc];
}

- (id)copyWithZone:(NSZone *)zone {
    id newInstance = [[[self class] allocWithZone:zone] initWithName:name shortName:shortName exchangeForDollar:_exchangeForDollar];
    return newInstance;
}

- (void)setExchangeForDollar:(NSDecimalNumber *)v {
    [_exchangeForDollar release];
    _exchangeForDollar = [v retain];
}

- (NSDecimalNumber*)exchangeForDollar {
    NSDecimalNumber *v = [[CurrencyExchange sharedManager] convert:[NSDecimalNumber decimalNumberWithString:@"1"] From:@"USD" To:name];
    if (v == nil) {
        v = (NSDecimalNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kExchangePrefKey,name]];
        if (v == nil) {
            v = _exchangeForDollar;
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:v
                                  forKey:[NSString stringWithFormat:kExchangePrefKey,name]];
    }
    return v;
}

@end

@implementation MoneyCurrencyList
static MoneyCurrencyList *sharedMoneyCurrencyList = nil; // for singleton
typedef struct {
    NSString *name;
    NSString *shortName;
    NSString *exchangeForDollar;
} MoneyCurrencyInit;
const MoneyCurrencyInit currencies[] = {
    { @"JPY", @"円", 	@"100" },
    { @"USD", @"＄", 	@"1" },
};

- (id)init {
    if ((self = [super init]) != nil) {
        _list = [[NSMutableArray alloc] init];
        [[CurrencyExchange sharedManager] update];
        for (int i=0; i < sizeof(currencies)/sizeof(currencies[0]); i++) {
            MoneyCurrency *currency = [[MoneyCurrency alloc] initWithName:currencies[i].name
                                                             shortName:currencies[i].shortName
                                                             exchangeForDollar:[NSDecimalNumber decimalNumberWithString:currencies[i].exchangeForDollar]];
            [_list addObject:currency];
            [currency release];
        }
    }
    return self;
}

- (void)dealloc {
    [_list release];
    [super dealloc];
}

- (MoneyCurrency*)currencyAtIndex:(NSUInteger)index {
    return [_list objectAtIndex:index];
}

- (NSUInteger)count {
    return _list.count;
}

- (MoneyCurrency*)searchForShortName:(NSString*)sn {
    for (int i=0; i < _list.count; i++) {
        MoneyCurrency *currency = [_list objectAtIndex:i];
        if ([currency.shortName compare:sn] == NSOrderedSame) {
            return currency;
        }
    }
    return nil;
}

+ (MoneyCurrencyList*)sharedManager {
    if (sharedMoneyCurrencyList == nil) {
        sharedMoneyCurrencyList = [[super allocWithZone:NULL] init];
    }
    return sharedMoneyCurrencyList;
}
 
+ (id)allocWithZone:(NSZone *)zone {
    return [[self sharedManager] retain];
}
 
- (id)copyWithZone:(NSZone *)zone {
    return self;
}
 
- (id)retain {
    return self;
}
 
- (NSUInteger)retainCount {
    return NSUIntegerMax;  //denotes an object that cannot be released
}
 
- (void)release {
    //do nothing
}
 
- (id)autorelease {
    return self;
}

@end

@implementation MoneyAccount
@synthesize unit,currency;
- (id)init {
    if ((self = [super init]) != nil) {
        buf = [[NSMutableString alloc] initWithCapacity:kMaxDigits];
        [self clear];
    }
    return self;
}

- (NSString*)text {
    return [[buf stringByAppendingString:(unit == nil)? @"" : unit.shortName] stringByAppendingString:(currency == nil)? @"" : currency.shortName];
}

- (void)clear {
    [buf setString:@"0"];
    value = nil;
}

- (void)appendText:(NSString*)s {
    BOOL isComma = ([s compare:@"."] == 0);
    BOOL isZero = ([s intValue] == 0);
    if (value == nil && isZero && !isComma) {
        return;
    }
    if ([buf length]+[s length] > kMaxDigits) {
        return;
    }
    if (isComma && [buf rangeOfString:@"."].location != NSNotFound) {
        return;
    }
    if(!isComma && value == nil && buf.length == 1){
        [buf setString:s];
    }else{
        [buf appendString:s];
    }
    [value release];
    value = [[NSDecimalNumber decimalNumberWithString:buf] retain];
    //value = [buf doubleValue];
    //NSLog(@"value: %0.16f",value);
}

//- (void)setValue:(double)v {
//    value = v;
//}

- (NSDecimalNumber*)netValue {
    if (unit != nil) {
        return [value decimalNumberByMultiplyingBy:unit.value];
    } else {
        return value;
    }
}

- (void)dealloc {
    [unit release];
    [super dealloc];
}

@end
