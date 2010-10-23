/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  SettingsView

  Copyright (C) 2010 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import "SettingsViewController.h"
#import "MoneyModel.h"

@implementation SettingsViewController
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self != nil) {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        //self.tableView.editing = YES;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)loadView {
    [super loadView];
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark UITableViewDataSource Methods
// Only one section in this table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL answer = YES;
    switch (indexPath.section) {
    case 0:
        break;
    case 1:
        answer = NO;
        break;
    default:
        break;
    }
    return answer;
}

// Return how many rows in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rows = 0;
    switch (section) {
    case 0:
        rows = [[MoneyCurrencyList sharedManager] countAll];
        break;
    case 1:
        rows = 1;
        break;
    default:
        break;
    }
    return rows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    switch (section) {
    case 0:
        title = NSLocalizedString(@"Currencies", nil);
        break;
    case 1:
        break;
    default:
        break;
    }
    return title;
}

// Return a cell for the ith row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *currencyCellID = @"currency-cell";
    static NSString *aboutCellID = @"about-cell";
    UITableViewCell *cell;
	// Use re-usable cells to minimize the memory load
    switch (indexPath.section) {
    case 0:
        cell = [tableView dequeueReusableCellWithIdentifier:currencyCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:currencyCellID] autorelease];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        //cell.showsReorderControl = YES;
        //cell.textLabel.font = [UIFont systemFontOfSize:18];
        cell.textLabel.adjustsFontSizeToFitWidth = YES;

        MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
        MoneyCurrency *currency = [currencyList currencyAtAllIndex:indexPath.row];
        cell.imageView.image = currency.image;
        cell.textLabel.text = currency.longName;
        cell.accessoryType = ([currencyList isEnabled:currency]) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        break;
    case 1:
        cell = [tableView dequeueReusableCellWithIdentifier:aboutCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:aboutCellID] autorelease];
            //cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = NSLocalizedString(@"AboutThisApp", nil);
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            //cell.textLabel.lineBreakMode = ;
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        break;
    default:
        return nil;
    }
	return cell;
}

#pragma mark UITableViewDelegateMethods

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
    BOOL isNeedUpdate = NO;
    switch (newIndexPath.section) {
    case 0:
        {
            MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
            MoneyCurrency *currency = [currencyList currencyAtAllIndex:newIndexPath.row];
            if ([currencyList isEnabled:currency]) {
                if ([currencyList count] == 1) {
                    break;
                }
                [currencyList disable:currency];
            } else {
                [currencyList enable:currency];
            }
            isNeedUpdate = YES;
            [currencyList saveList];
        }
        break;
    case 1:
        break;
    default:
        break;
    }
    [tableView deselectRowAtIndexPath:newIndexPath animated:YES];
    if (isNeedUpdate) {
        [tableView reloadData];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    MoneyCurrencyList *currencyList = [MoneyCurrencyList sharedManager];
    [currencyList moveCurrency:fromIndexPath.row to:toIndexPath.row];
    [currencyList saveList];
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if( sourceIndexPath.section != proposedDestinationIndexPath.section ) {
        return sourceIndexPath;
    } else {
        return proposedDestinationIndexPath;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
    case 0:
        return tableView.rowHeight;
        break;
    case 1:
        return 100;
        break;
    default:
        return 0;
        break;
    }
}


@end

