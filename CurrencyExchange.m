/***********************************************************************
 $Id$

  CurrencyExchange

  Copyright (C) 2010 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import "CurrencyExchange.h"
#import "MyUtil.h"

@implementation CurrencyExchange
static CurrencyExchange *sharedCurrencyExchange = nil; // for singleton
+ (CurrencyExchange*)sharedManager {
    if (sharedCurrencyExchange == nil) {
        sharedCurrencyExchange = [[super allocWithZone:NULL] init];
    }
    return sharedCurrencyExchange;
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

- (void)didStartNetworking {
    networkingCount += 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didStopNetworking {
    networkingCount -= 1;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (networkingCount != 0);
}

- (void)startLoadingXML {
    [self didStartNetworking];
    NSURLRequest *request =
        // [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml"]];
        [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://ukllcurrencies.appspot.com/currency.xml"]];
    loader = [[NSURLConnection alloc] initWithRequest:request delegate:self];
}

- (void)stopLoadingXMLWithResult:(BOOL)result {
    [self didStopNetworking];
    if (loader != nil) {
        [loader cancel];
        [loader release];
        loader = nil;
    }
    if (result == YES) {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:xmlData];
        parser.delegate = self;
        [parser parse];
        [parser release];

        [lastUpdate release];
        lastUpdate = [[NSDate date] retain];
    }
    [xmlData release];
    xmlData = nil;
}

- (void)connection:(NSURLConnection*)theConnection didReceiveResponse:(NSURLResponse*)response {
#pragma unused(theConnection)
    NSHTTPURLResponse* httpResponse;
    httpResponse = (NSHTTPURLResponse*)response;
    if ((httpResponse.statusCode/100) != 2) {
        [self stopLoadingXMLWithResult:NO];
    } else {
        xmlData = [[NSMutableData alloc] initWithData:0];
    }
}

- (void)connection:(NSURLConnection*)theConnection didReceiveData:(NSData*)data {
#pragma unused(theConnection)
    [xmlData appendData:data];
}

- (void)connection:(NSURLConnection*)theConnection didFailWithError:(NSError*)error {
#pragma unused(theConnection)
#pragma unused(error)
    [self stopLoadingXMLWithResult:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
#pragma unused(theConnection)
    [self stopLoadingXMLWithResult:YES];
}

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    // it begins parsing a document
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ([elementName isEqualToString:@"Cube"] && [attributeDict count] >= 2) {
        NSString *currency = [attributeDict valueForKey:@"currency"];
        NSString *rate = [attributeDict valueForKey:@"rate"];
        NSString *updated = [attributeDict valueForKey:@"updated"];
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                           rate, @"rate",
                                           updated, @"updated",
                                           nil];
        @synchronized(table) {
            [table setValue:data forKey:currency];
        }
        NSLOG(@"this is it! %@ %@ %@", currency, rate, updated);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    //NSLOG(@"endelement %@, %@, %@", elementName, namespaceURI, qName);
}

- (id)init {
    if ((self = [super init])) {
        networkingCount = 0;
        table = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)update {
    if ([table count] > 0 && lastUpdate != nil) {
        NSTimeInterval interval = -[lastUpdate timeIntervalSinceNow];	// seconds
        if (interval < 60*5) {
            // 5 mins
            return;
        }
    }
    [table removeAllObjects];
    [self startLoadingXML];
}

- (NSDecimalNumber*)convert:(NSDecimalNumber*)value From:(NSString*)from To:(NSString*)to {
    NSString *fromValue;
    NSString *toValue;
    @synchronized(table) {
        NSDictionary *fromData = (NSDictionary*)[table valueForKey:from];
        NSDictionary *toData = (NSDictionary*)[table valueForKey:to];
        fromValue = (NSString*)[fromData valueForKey:@"rate"];
        toValue = (NSString*)[toData valueForKey:@"rate"];
    }
    if (fromValue != nil && toValue != nil) {
        return [[value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:toValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:fromValue]];
    } else {
        return nil;
    }
}

- (NSString*)updated:(NSString*)name {
    NSString *updated;
    @synchronized(table) {
        NSDictionary *data = (NSDictionary*)[table valueForKey:name];
        updated = (NSString*)[data valueForKey:@"updated"];
    }
    return updated;
}

- (void)dealloc {
    [lastUpdate release];
    [table release];
    [super dealloc];
}

@end
