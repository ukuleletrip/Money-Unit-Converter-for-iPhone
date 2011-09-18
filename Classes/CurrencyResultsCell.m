//
//  CurrencyResultsCell.m
//  MoneyUnitConverter
//
//  Created by 宮本 哲 on 11/08/20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "CurrencyResultsCell.h"

@implementation CurrencyResultsCell
@synthesize l1Result, l2Result, rateInfo, flagImage;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) dealloc {
    [flagImage release];
    [l1Result release];
    [l2Result release];
    [rateInfo release];
	[super dealloc];
}

@end
