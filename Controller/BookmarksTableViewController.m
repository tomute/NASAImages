//
//  BookmarksTableViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BookmarksTableViewController.h"
#import "Item.h"

@implementation BookmarksTableViewController

- (void)dealloc {
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.navigationItem.rightBarButtonItem = self.editButtonItem;
	isBookmarkOff = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData* classDataLoad = [defaults dataForKey:@"BOOKMARK_ARRAY"];
	if (classDataLoad != nil) {
		NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:classDataLoad];
		if (itemList != nil) {
			[itemList release];
		}
		itemList = [[NSMutableArray arrayWithArray:array] retain];
	}
	
	for (Item *item in itemList) {
		item.downloads = nil;
	}
	[itemTableView reloadData];
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	[itemTableView setEditing:editing animated:animated];
}


- (void)viewDidUnload {
	[super setEditing:NO animated:NO];
	[super viewDidUnload];
}


#pragma mark Table view methods

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[itemList removeObjectAtIndex:[indexPath row]];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSData* classDataSave = [NSKeyedArchiver archivedDataWithRootObject:itemList];
		[defaults setObject:classDataSave forKey:@"BOOKMARK_ARRAY"];
    }
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	Item *item = [[itemList objectAtIndex:[fromIndexPath row]] retain];
	[itemList removeObjectAtIndex:[fromIndexPath row]];
	[itemList insertObject:item atIndex:[toIndexPath row]];
	[item release];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData* classDataSave = [NSKeyedArchiver archivedDataWithRootObject:itemList];
	[defaults setObject:classDataSave forKey:@"BOOKMARK_ARRAY"];
}

@end
