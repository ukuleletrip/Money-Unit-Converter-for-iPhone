/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  CurrencyExchange

  Copyright (C) 2010 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>

@interface CurrencyExchange : NSObject <NSXMLParserDelegate> {
@private
    NSURLConnection *loader;
    NSInteger networkingCount;
    NSMutableData *xmlData;
    NSMutableDictionary *table;
    NSDate *lastUpdate;
}
+ (CurrencyExchange*)sharedManager;
- (void)update;
- (NSDecimalNumber*)convert:(NSDecimalNumber*)value From:(NSString*)from To:(NSString*)to;
- (NSString*)updated:(NSString*)name;
@end

#define kCurrencyExchangeUpdated @"currency.exchange.update"
