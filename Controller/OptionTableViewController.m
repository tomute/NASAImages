//
//  OptionTableViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OptionTableViewController.h"

@implementation OptionTableViewController

@synthesize options, storedKey, selected, oldIndexPath;

- (void)dealloc {
	[options release];
	[storedKey release];
	[oldIndexPath release];
	
    [super dealloc];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.tableView.scrollEnabled = NO;
}


- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [options count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	cell.textLabel.text = [options objectAtIndex:[indexPath row]];
	if ([indexPath row] == selected) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		self.oldIndexPath = indexPath;
	}
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[tableView cellForRowAtIndexPath:self.oldIndexPath] setAccessoryType:UITableViewCellAccessoryNone];
    [[tableView cellForRowAtIndexPath:indexPath] setAccessoryType:UITableViewCellAccessoryCheckmark];
	self.oldIndexPath = indexPath;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:[options objectAtIndex:[indexPath row]] forKey:storedKey];
	[defaults synchronize];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

