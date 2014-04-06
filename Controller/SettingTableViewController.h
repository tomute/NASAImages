//
//  SettingTableViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingTableViewController : UITableViewController <UITextFieldDelegate> {
  @private
	NSArray *titleArray;
	NSArray *keyArray;
	NSArray *defaultArray;
	UITextField *usernameField;
	UITextField *passwordField;
}

@end
