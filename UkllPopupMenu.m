/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  Ukulele Lib Popup Menu

  Copyright (C) 2011 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>
#import "UkllPopupMenu.h"
#import "MyUtil.h"

@implementation UkllPopupMenu
@synthesize delegate;
- (id)initWithFrame:(CGRect)rect {
    self = [super initWithFrame:rect];
    if (self != nil) {
        //table = [[UITableView alloc] initWithFrame:rect style:UITableViewStylePlain];
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 160, 200) style:UITableViewStylePlain];
        table.delegate = self;
        table.rowHeight = kPopupItemHeight;
        table.backgroundColor = [UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:142.0/255.0 alpha:1.0];
        //table.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
        table.separatorColor = [UIColor darkGrayColor];
        [self addSubview:table];
        [table release];

        [self setClipsToBounds:YES];
        //[self layer].cornerRadius = 10.0;
        //[self layer].borderColor = [[UIColor lightGrayColor] CGColor];
        //[self layer].borderWidth = 1.0;
        //[self layer].shadowOpacity = 0.5;
        //[self layer].shadowOffset = CGSizeMake(-10,10);
    }
    return self;
}

- (void)dealloc {
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLOG(@"touches");
    self.hidden = YES;
}

- (void)setMenuRect:(CGRect)rect {
    NSLOG(@"set table rect");
    table.frame = rect;
}

- (CGRect)menuRect {
    NSLOG(@"read table rect");
    return table.frame;
}

- (void)update {
    [table reloadData];
}

- (id <UITableViewDataSource>)dataSource {
    return table.dataSource;
}

- (void)setDataSource:(id <UITableViewDataSource>)s {
    table.dataSource = s;
    [table reloadData];
}

#pragma mark UITableViewDelegateMethods

// Respond to user selection
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
    if ([delegate respondsToSelector:@selector(popupMenu:didItemSelected:)]) {
        [delegate popupMenu:self didItemSelected:newIndexPath.row];
    }
    self.hidden = YES;
}
@end
