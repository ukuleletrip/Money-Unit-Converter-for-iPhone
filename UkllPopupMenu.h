/* -*- ObjC -*- */
/***********************************************************************
 $Id$

  Ukulele Lib Popup Menu

  Copyright (C) 2011 Ukulele Trip
  All rights reserved

  @author Ukulele Trip

***********************************************************************/
#import <UIKit/UIKit.h>

#define kPopupItemHeight (28)

@class UkllPopupMenu;
@protocol UkllPopupMenuDelegate <NSObject>
@optional
- (void)popupMenu:(UkllPopupMenu*)popupMenu didItemSelected:(NSInteger)index;
@end

@interface UkllPopupMenu : UIView <UITableViewDelegate> {
@private
    UITableView *table;
    id <UkllPopupMenuDelegate> delegate;
}
@property (nonatomic, assign) id <UITableViewDataSource> dataSource;
@property (nonatomic, assign) id <UkllPopupMenuDelegate> delegate;
@property (nonatomic) CGRect menuRect;
- (void)update;
@end
