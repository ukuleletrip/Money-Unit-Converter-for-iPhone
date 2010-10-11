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

@implementation SettingsViewController
- (id)init {
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self != nil) {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

#pragma mark UITableViewDataSource Methods
// Only one section in this table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Return how many rows in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return 0;
}

// Return a cell for the ith row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// Use re-usable cells to minimize the memory load
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"any-cell"];
	if (cell == nil) {
        //cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"any-cell"] autorelease];
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"any-cell"] autorelease];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:18];
    //cell.textLabel.text = [renderer textForRow:indexPath.section row:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    //cell.detailTextLabel.text = [renderer detailTextForRow:indexPath.section row:indexPath.row];
    //cell.imageView.image = [renderer imageForRow:indexPath.section row:indexPath.row];
	return cell;
}

#pragma mark UITableViewDelegateMethods

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

@end

