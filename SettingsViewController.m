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
	// Use re-usable cells to minimize the memory load
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"any-cell"] autorelease];
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    switch (indexPath.section) {
    case 0:
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
        cell.imageView.image = nil;
        cell.textLabel.text = NSLocalizedString(@"AboutThisApp", nil);
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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

@end

