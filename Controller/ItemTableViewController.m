//
//  ItemTableViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemTableViewController.h"
#import "ItemTableViewCell.h"
#import "Item.h"
#import "ItemViewController.h"
#import "MediaViewControllerFactory.h"

#import "ASIHTTPRequest.h"
#import "JSON.h"

@implementation ItemTableViewController

@synthesize strUrl, itemTableView, indicator, itemList;

- (void)dealloc {
	[queue cancelAllOperations];
	[queue release];
	[strUrl release];
	[itemTableView release];
	[itemList release];
	[indicator release];
	
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	incNumber = 50;
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
	backButton.title = @"Back";
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	queue = [[NSOperationQueue alloc] init];
	if (itemList == nil) {
		itemList = [[NSMutableArray alloc] init];
	}
}


- (void)viewWillAppear:(BOOL)animated {
	isViewDisappear = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
	isViewDisappear = YES;
}


- (void)startGettingItems {
	[indicator startAnimating];
	itemTableView.allowsSelection = NO;
	itemTableView.scrollEnabled = NO;
	
	itemNumber = [itemList count];
	if ([[[itemList lastObject] title] isEqualToString:@"Show more items"]) {
		itemNumber--;
	}
	oldItemNumber = itemNumber;
	itemNumber += incNumber;
	
	NSString *tmpUrl = [NSString stringWithFormat:strUrl, itemNumber];
	NSURL *url = [NSURL URLWithString:[tmpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	request.timeOutSeconds = 30;
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(gettingResultsDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	[queue addOperation:request];
}


- (void)gettingResultsDone:(ASIHTTPRequest *)request {
	NSString *response = [request responseString];
	NSDictionary *results = [response JSONValue];
	
	[itemList removeAllObjects];
	
	if (results != nil) {
		NSArray *docs = [[results objectForKey:@"response"] objectForKey:@"docs"];
		for (NSDictionary *doc in docs) {
			Item *item = [[Item alloc] initWithDictionary:doc];
			if (item != nil) {
				[itemList addObject:item];
				[item release];
			}
		}
	}
	
	if (isBookmarkOff == NO && [itemList count] != oldItemNumber && [itemList count] != 0) {
		Item *item = [[Item alloc] init];
		item.title = @"Show more items";
		[itemList addObject:item];
		[item release];
	}
	
	[itemTableView reloadData];
	[indicator stopAnimating];
	itemTableView.allowsSelection = YES;
	itemTableView.scrollEnabled = YES;
}


- (void)requestWentWrong:(ASIHTTPRequest *)request {
	[indicator stopAnimating];
	[itemTableView reloadData];
	itemTableView.allowsSelection = YES;
	itemTableView.scrollEnabled = YES;
	
	NSString *errorTitle = nil;
	NSString *cancelTitle = nil;
	NSString *okTitle = nil;
	NSError *error = [request error];
	switch (error.code) {
		case ASIConnectionFailureErrorType:
		{
			errorTitle = @"Network Error";
			okTitle = @"OK";
			break;
		}
		case ASIRequestTimedOutErrorType:
		{
			errorTitle = @"Timeout";
			cancelTitle = @"Cancel";
			okTitle = @"Retry";
			break;
		}
		default:
		{
			errorTitle = @"Unknown Error";
			okTitle = @"OK";
			break;
		}
	}
	
	if (isViewDisappear == NO) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle
														message:@"Failed to load data."
													   delegate:self
											  cancelButtonTitle:cancelTitle
											  otherButtonTitles:okTitle, nil];
		[alert show];
		[alert release];		
	}
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self startGettingItems];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	[queue release]; queue = nil;
	[itemList release]; itemList = nil;
	[super viewDidUnload];
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [itemList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    ItemTableViewCell *cell = (ItemTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	[cell setItem:[itemList objectAtIndex:indexPath.row]];
	
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	ItemTableViewCell *cell = (ItemTableViewCell *)[self tableView:tableView cellForRowAtIndexPath:indexPath];
	return cell.height;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Item *item = [itemList objectAtIndex:indexPath.row];
	if ([item.title isEqualToString:@"Show more items"]) {
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		[itemList removeLastObject];
		[self startGettingItems];
		return;
	}
	ItemViewController *ivc = [MediaViewControllerFactory createMediaViewController:item.mediaType];
	[ivc setItem:item];
	ivc.isBookmarkOff = isBookmarkOff;
	[self.navigationController pushViewController:ivc animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
