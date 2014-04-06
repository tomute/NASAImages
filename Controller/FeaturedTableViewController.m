//
//  FeaturedTableViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FeaturedTableViewController.h"
#import "PickupItemTableViewController.h"

@implementation FeaturedTableViewController

- (void)dealloc {
	[featuredList release];
	[itemListArray release];
	
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView.scrollEnabled = NO;
	featuredList = [[NSArray alloc] initWithObjects:@"Recently Added",
					@"Most Downloaded",
					@"Most Downloaded Last Week",
					@"Most Downloaded Last Month",
					nil];
	itemListArray = [[NSArray alloc] initWithObjects:[NSMutableArray array],
					 [NSMutableArray array],
					 [NSMutableArray array],
					 [NSMutableArray array],
					 nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	[featuredList release]; featuredList = nil;
	[itemListArray release]; itemListArray = nil;
	[super viewDidUnload];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [featuredList count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:18];
    }
    
    // Set up the cell...
	cell.textLabel.text = [featuredList objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *itemMediaType = [defaults stringForKey:@"Item Media Type"];
	NSString *format;
	if ([itemMediaType isEqualToString:@"All"] || itemMediaType == nil) {
		format = @"http://www.archive.org/advancedsearch.php?q=(collection:nasa+OR+mediatype:nasa)+AND+-mediatype:collection%@";
	} else if ([itemMediaType isEqualToString:@"Movie"]) {
		format = @"http://www.archive.org/advancedsearch.php?q=((collection:nasa+OR+mediatype:nasa)+AND+-mediatype:collection)+AND+mediatype:movies%@";
	} else {
		format = @"http://www.archive.org/advancedsearch.php?q=((collection:nasa+OR+mediatype:nasa)+AND+-mediatype:collection)+AND+mediatype:image%@";
	}
	
	NSString *urlFormat;
	switch (indexPath.row) {
		case 0:
			urlFormat = [NSString stringWithFormat:format, @"&fl[]=creator&fl[]=description&fl[]=format&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&sort[]=publicdate+desc&sort[]=&sort[]=&rows=%d&fmt=json&xmlsearch=Search"];
			break;
		case 1:
			urlFormat = [NSString stringWithFormat:format, @"&fl[]=creator&fl[]=description&fl[]=format&fl[]=downloads&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&sort[]=downloads+desc&sort[]=&sort[]=&rows=%d&fmt=json&xmlsearch=Search"];
			break;
		case 2:
			urlFormat = [NSString stringWithFormat:format, @"&sort=-week&fl[]=creator&fl[]=description&fl[]=format&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&fl[]=week&sort[]=week+desc&sort[]=&sort[]=&rows=%d&fmt=json&xmlsearch=Search"];
			break;
		case 3:
			urlFormat = [NSString stringWithFormat:format, @"&sort=-month&fl[]=creator&fl[]=description&fl[]=format&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&fl[]=month&sort[]=month+desc&sort[]=&sort[]=&rows=%d&fmt=json&xmlsearch=Search"];
			break;
		default:
			urlFormat = nil;
			break;
	}
	PickupItemTableViewController *pitvc = [[PickupItemTableViewController alloc] initWithNibName:@"PickupItemTableViewController" bundle:nil];
	pitvc.title = [featuredList objectAtIndex:indexPath.row];
	pitvc.strUrl = urlFormat;
	
	NSMutableArray *itemList = [itemListArray objectAtIndex:indexPath.row];
	if (![currentMediaType isEqualToString:itemMediaType]) {
		[itemList removeAllObjects];
	}
	
	[currentMediaType release];
	currentMediaType = [itemMediaType copy];
	
	pitvc.itemList = itemList;
	[self.navigationController pushViewController:pitvc animated:YES];
	[pitvc release];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

