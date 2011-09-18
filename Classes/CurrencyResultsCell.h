/* -*- ObjC -*- */
//
//  CurrencyResultsCell.h
//  MoneyUnitConverter
//
//  Created by 宮本 哲 on 11/08/20.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CurrencyResultsCell : UITableViewCell {
    IBOutlet UIImageView *flagImage;
    IBOutlet UILabel *l1Result;
    IBOutlet UILabel *l2Result;
    IBOutlet UILabel *rateInfo;
}
@property (nonatomic, retain) UIImageView *flagImage;
@property (nonatomic, retain) UILabel *l1Result;
@property (nonatomic, retain) UILabel *l2Result;
@property (nonatomic, retain) UILabel *rateInfo;
@end
