//
//  PickupItemTableViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PickupItemTableViewController.h"

@implementation PickupItemTableViewController

- (void)dealloc {
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	if ([itemList count] == 0) {
		[super startGettingItems];
	} else {
		itemNumber = [itemList count] - 1;
		[itemTableView reloadData];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	[super viewDidUnload];
}

@end
