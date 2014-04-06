//
//  ItemTableViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemTableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
  @private
	NSString *strUrl;
	NSOperationQueue *queue;
	UIActivityIndicatorView *indicator;
	BOOL isViewDisappear;
	
	int oldItemNumber;
	int incNumber;

  @protected
	UITableView *itemTableView;
	NSMutableArray *itemList;
	BOOL isBookmarkOff;
	
	int itemNumber;
}

@property (nonatomic, copy) NSString *strUrl;
@property (nonatomic, retain) IBOutlet UITableView *itemTableView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) NSMutableArray *itemList;

- (void)startGettingItems;

@end
