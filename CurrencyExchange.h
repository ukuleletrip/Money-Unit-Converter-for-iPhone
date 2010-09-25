/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  CurrencyExchange

  Copyright (C) 2010 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>

@interface CurrencyExchange : NSObject {
@private
    NSURLConnection *loader;
    NSInteger networkingCount;
    NSMutableData *xmlData;
    NSMutableDictionary *table;
}
+ (CurrencyExchange*)sharedManager;
- (void)update;
- (double)convert:(double)value From:(NSString*)from To:(NSString*)to;
@end

