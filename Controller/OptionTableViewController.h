//
//  OptionTableViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionTableViewController : UITableViewController {
  @private
	NSArray *options;
	NSString *storedKey;
	int selected;
	NSIndexPath *oldIndexPath;
}

@property (nonatomic, retain) NSArray *options;
@property (nonatomic, retain) NSString *storedKey;
@property (nonatomic, retain) NSIndexPath *oldIndexPath;
@property int selected;

@end
