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
        [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.ecb.int/stats/eurofxref/eurofxref-daily.xml"]];
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
        [table setValue:rate forKey:currency];
        NSLOG(@"this is it! %@ %@", currency, rate);
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {     
    NSLOG(@"endelement %@, %@, %@", elementName, namespaceURI, qName);
}

- (id)init {
    if ((self = [super init])) {
        networkingCount = 0;
        table = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)update {
    [self startLoadingXML];
}

- (NSDecimalNumber*)convert:(NSDecimalNumber*)value From:(NSString*)from To:(NSString*)to {
    NSString *fromValue = (NSString*)[table valueForKey:from];
    NSString *toValue = (NSString*)[table valueForKey:to];
    if (fromValue != nil && toValue != nil) {
        return [[value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:toValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:fromValue]];
    } else {
        return nil;
    }
}

- (void)dealloc {
    [table release];
    [super dealloc];
}

@end
