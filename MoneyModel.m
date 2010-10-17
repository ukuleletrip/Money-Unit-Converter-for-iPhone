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

#define kExchangePrefKey		@"moneymodel.exchange.nsstring.%@"
#define kCurAllListPrefKey		@"moneymodel.currency.all.array"
#define kCurEnabledListPrefKey	@"moneymodel.currency.enabled.array"

@implementation MoneyUnit
@synthesize name,shortName,value,attribute;
- (id)initWithName:(NSString*)n shortName:(NSString*)sn value:(NSString*)v attribute:(int)a {
    if ((self = [super init]) != nil) {
        name = n;
        shortName = sn;
        value = [[NSDecimalNumber decimalNumberWithString:v] retain];
        attribute = a;
    }
    return self;
}

- (id)initWithName:(NSString*)n shortName:(NSString*)sn decimal:(NSDecimalNumber*)v attribute:(int)a {
    if ((self = [super init]) != nil) {
        name = n;
        shortName = sn;
        value = [v retain];
        attribute = a;
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
    id newInstance = [[[self class] allocWithZone:zone] initWithName:name shortName:shortName decimal:value attribute:attribute];
    return newInstance;
}

- (BOOL)isFinancial {
    return (attribute&FINANCIAL) != 0;
}

- (BOOL)isNatural {
    return (attribute&NATURAL) != 0;
}

- (BOOL)isEnglish {
    return (attribute&ENGLISH) != 0;
}

- (BOOL)isMin {
    return (attribute&CMIN) != 0;
}

- (BOOL)isMax {
    return (attribute&CMAX) != 0;
}

@end

@implementation MoneyUnitList
static MoneyUnitList *sharedMoneyUnitList = nil; // for singleton
typedef struct {
    NSString *name;
    NSString *shortName;
    int attribute;
    NSString *value;
} MoneyUnitInit;
const MoneyUnitInit units[] = {
    { @"", @"", FINANCIAL|NATURAL|CMIN,		@"1" },
    { @"十", @"十", 0,		@"10" },
    { @"百", @"百", 0,		@"100" },
    { @"千", @"千", FINANCIAL,	@"1000" },
    { @"万", @"万", FINANCIAL|NATURAL,	@"10000" },
    { @"十万", @"十万", 0,	@"100000" },
    { @"百万", @"百万", FINANCIAL,	@"1000000" },
    { @"千万", @"千万", 0,	@"10000000" },
    { @"億", @"億", FINANCIAL|NATURAL,	@"100000000" },
    { @"十億", @"十億", FINANCIAL,	@"1000000000" },
    { @"百億", @"百億", 0,	@"10000000000" },
    { @"千億", @"千億", 0,	@"100000000000" },
    { @"兆", @"兆", FINANCIAL|NATURAL,	@"1000000000000" },
    { @"十兆", @"十兆", 0,	@"10000000000000" },
    { @"百兆", @"百兆", 0,	@"100000000000000" },
    { @"千兆", @"千兆", FINANCIAL,	@"1000000000000000" },
    { @"京", @"京", FINANCIAL|NATURAL|CMAX,	@"10000000000000000" },
    { @"", @"", NATURAL|ENGLISH|CMIN,		@"1" },
    { @"Hundred", @"h", ENGLISH,		@"100" },
    { @"Thousand", @"K", ENGLISH|NATURAL,	@"1000" },
    { @"Million", @"M", ENGLISH|NATURAL,	@"1000000" },
    { @"Hundred Million", @"hM", ENGLISH,	@"100000000" },
    { @"Billion", @"B", ENGLISH|NATURAL,	@"1000000000" },
    { @"Hundred Billion", @"hB", ENGLISH,	@"100000000000" },
    { @"Trillion", @"T", ENGLISH|NATURAL,	@"1000000000000" },
    { @"Hundred Trillion", @"hT", ENGLISH,	@"100000000000000" },
    { @"Quadrillion", @"Q", ENGLISH|NATURAL|CMAX, @"1000000000000000" },
};

- (id)init {
    if ((self = [super init]) != nil) {
        _list = [[NSMutableArray alloc] init];
        for (int i=0; i < sizeof(units)/sizeof(units[0]); i++) {
            MoneyUnit *unit = [[MoneyUnit alloc] initWithName:units[i].name
                                                 shortName:units[i].shortName 
                                                 value:units[i].value
                                                 attribute:units[i].attribute];
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

- (MoneyUnit*)searchForShortName:(NSString*)sn withAttribute:(int)attribute isValue:(int)value {
    for (int i=0; i < _list.count; i++) {
        MoneyUnit *unit = [_list objectAtIndex:i];
        if ((unit.attribute&attribute) == value &&
            [unit.shortName compare:sn] == NSOrderedSame) {
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
@synthesize name,shortName,image;
@dynamic longName;
- (id)initWithName:(NSString*)n shortName:(NSString*)sn imageName:(NSString*)imgName  {
    if ((self = [super init]) != nil) {
        name = n;
        shortName = sn;
        imageName = imgName;
    }
    return self;
}

- (void)dealloc {
    [name release];
    [shortName release];
    [imageName release];
    [image release];
    [super dealloc];
}

- (UIImage*)image {
    if (image == nil) {
        image = [[UIImage imageNamed:imageName] retain];
    }
    return image;
}

- (id)copyWithZone:(NSZone *)zone {
    id newInstance = [[[self class] allocWithZone:zone] initWithName:name shortName:shortName imageName:imageName];
    return newInstance;
}

- (NSDecimalNumber*)exchangeForDollar {
    NSDecimalNumber *v = [[CurrencyExchange sharedManager] convert:[NSDecimalNumber decimalNumberWithString:@"1"] From:@"USD" To:name];
    if (v == nil) {
        NSString *s = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:kExchangePrefKey,name]];
        if (s == nil || (v = [NSDecimalNumber decimalNumberWithString:s]) == nil) {
            v = [NSDecimalNumber decimalNumberWithString:@"0"];
        }
    } else {
        NSDictionary *dic= [[NSDictionary alloc] initWithObjectsAndKeys:@".",@"NSDecimalSeparator",nil];
        NSString *s = [v descriptionWithLocale:dic];
        [[NSUserDefaults standardUserDefaults] setObject:s
                                               forKey:[NSString stringWithFormat:kExchangePrefKey,name]];
    }
    return v;
}

- (NSString*)longName {
    return NSLocalizedString(name, nil);
}

@end

@implementation MoneyCurrencyList
static MoneyCurrencyList *sharedMoneyCurrencyList = nil; // for singleton
typedef struct {
    NSString *name;
    NSString *shortName;
    NSString *imageName;
} MoneyCurrencyInit;
const MoneyCurrencyInit currencies[] = {
    { @"JPY", @"円", 	@"Japan"			},
    { @"USD", @"$", 	@"United-States"	},
    { @"EUR", @"€", 	@"European-Union"	},
    { @"AUD", @"$", 	@"Australia"		},
    { @"GBP", @"£", 	@"United-Kindom"	},
    { @"NZD", @"$", 	@"New-Zealand"		},
    { @"CAD", @"$", 	@"Canada"			},
    { @"CHF", @"CHF", 	@"Switzerland"		},
    { @"HKD", @"$", 	@"Hong-Kong"		},
    { @"INR", @"₨", 	@"India"			},
    { @"KRW", @"￦", 	@"South-Korea"		},
    { @"CNY", @"元", 	@"China"			},
    { @"BGN", @"лв",	@"Bulgaria"			},
    { @"CZK", @"Kč",	@"Czech-Republic"	},
    { @"DKK", @"kr",	@"Denmark"			},
    { @"EEK", @"krooni",@"Estonia"			},
    { @"HUF", @"Ft",	@"Hungary"			},
    { @"LTL", @"Lt",	@"Lithuania"		},
    { @"LVL", @"Ls",	@"Latvia"			},
    { @"PLN", @"zł",	@"Poland"			},
    { @"RON", @"lei",	@"Romania"			},
    { @"SEK", @"kr",	@"Sweden"			},
    { @"NOK", @"kr",	@"Norway"			},
    { @"HRK", @"kn",	@"Croatia"			},
    { @"RUB", @"руб", @"Russia"			},
	{ @"TRY", @"TL",	@"Turkey"			},
    { @"BRL", @"R$",	@"Brazil"			},
    { @"IDR", @"Rp",	@"Indonesia"		},
    { @"MXN", @"$",		@"Mexico"			},
    { @"MYR", @"RM",	@"Malaysia"			},
    { @"PHP", @"₱",		@"Philippines"		},
    { @"SGD", @"S$",	@"Singapore"		},
    { @"THB", @"฿",		@"Thailand"			},
    { @"ZAR", @"R",		@"South-Africa"		},
};

- (MoneyCurrency*)createCurrencyFromTable:(int)i {
    return [[MoneyCurrency alloc] initWithName:currencies[i].name
                                  shortName:currencies[i].shortName
                                  imageName:currencies[i].imageName];
}

- (id)init {
    if ((self = [super init]) != nil) {
        [[CurrencyExchange sharedManager] update];

        _list = [[NSMutableArray alloc] init];
        _enabledList = [[NSMutableArray alloc] init];

        NSArray *all = [[NSUserDefaults standardUserDefaults] objectForKey:kCurAllListPrefKey];
        NSArray *en = [[NSUserDefaults standardUserDefaults] objectForKey:kCurEnabledListPrefKey];
        //NSLog(@"readConf %@\n%@", [all description], [en description]);
        for (NSString *key in all) {
            for (int i=0; i < sizeof(currencies)/sizeof(currencies[0]); i++) {
                if ([key compare:currencies[i].name] == NSOrderedSame) {
                    MoneyCurrency *currency = [self createCurrencyFromTable:i];
                    [_list addObject:currency];
                    [currency release];
                }
            }
        }
        for (NSString *key in en) {
            MoneyCurrency *c = [self searchForName:key];
            if (c != nil) {
                [_enabledList addObject:c];
            }
        }
        for (int i=0; i < sizeof(currencies)/sizeof(currencies[0]); i++) {
            if ([self searchForName:currencies[i].name] == nil) {
                MoneyCurrency *currency = [self createCurrencyFromTable:i];
                [_list addObject:currency];
                [_enabledList addObject:currency];
                [currency release];
            }
        }
    }
    return self;
}

- (void)dealloc {
    [_list release];
    [_enabledList release];
    [super dealloc];
}

- (void)moveCurrency:(NSUInteger)fromIndex to:(NSUInteger)toIndex {
    MoneyCurrency *currency = [[_list objectAtIndex:fromIndex] retain];
    [_list removeObject:currency];
    [_list insertObject:currency atIndex:toIndex];
    [currency release];

    NSMutableArray *newEnabledList = [[NSMutableArray alloc] init];
    for (id c in _list) {
        if ([self isEnabled:c]) {
            [newEnabledList addObject:c];
        }
    }
    [_enabledList release];
    _enabledList = newEnabledList;
}

- (void)saveList {
    NSMutableArray *all = [[NSMutableArray alloc] init];
    for (MoneyCurrency *c in _list) {
        [all addObject:c.name];
    }
    //NSLog(@"allList %@", [all description]);
    [[NSUserDefaults standardUserDefaults] setObject:all forKey:kCurAllListPrefKey];
    [all release];

    NSMutableArray *en = [[NSMutableArray alloc] init];
    for (MoneyCurrency *c in _enabledList) {
        [en addObject:c.name];
    }
    //NSLog(@"enList %@", [en description]);
    [[NSUserDefaults standardUserDefaults] setObject:en forKey:kCurEnabledListPrefKey];
    [en release];
}

- (MoneyCurrency*)currencyAtAllIndex:(NSUInteger)index {
    return [_list objectAtIndex:index];
}

- (MoneyCurrency*)currencyAtIndex:(NSUInteger)index {
    return [_enabledList objectAtIndex:index];
}

- (NSUInteger)countAll {
    return _list.count;
}

- (NSUInteger)count {
    return _enabledList.count;
}

- (MoneyCurrency*)searchForName:(NSString*)name {
    for (MoneyCurrency *currency in _list) {
        if ([currency.name compare:name] == NSOrderedSame) {
            return currency;
        }
    }
    return nil;
}

- (BOOL)isEnabled:(MoneyCurrency*)currency {
    return ([_enabledList indexOfObject:currency] != NSNotFound);
}

- (void)enable:(MoneyCurrency*)currency {
    [_enabledList addObject:currency];
}

- (void)disable:(MoneyCurrency*)currency {
    [_enabledList removeObject:currency];
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
}

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
