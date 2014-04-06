//
//  FeaturedTableViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FeaturedTableViewController : UITableViewController {
  @private
	NSArray *featuredList;
	NSArray *itemListArray;
	NSString *currentMediaType;
}

@end
