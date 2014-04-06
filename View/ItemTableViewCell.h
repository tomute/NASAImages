//
//  ItemTableViewCell.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Item;

@interface ItemTableViewCell : UITableViewCell {
  @private
	UIView *itemView;
	UILabel *title;
	UILabel *description;
	UILabel *pubDate;
	UILabel *downloads;
	CGFloat height;
	Item *cellItem;
}

@property (readonly) CGFloat height;

- (void)setItem:(Item *)item;

@end
