//
//  SearchTableViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SearchTableViewController.h"

@implementation SearchTableViewController

- (void)dealloc {
    [super dealloc];
}


- (void)beginGettingSearchResults:(NSString *)queryString {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *searchMediaType = [defaults stringForKey:@"Search Media Type"];
	NSString *format;
	if ([searchMediaType isEqualToString:@"All"] || searchMediaType == nil) {
		format = @"http://www.archive.org/advancedsearch.php?q=collection:nasa+%@&fl[]=creator&fl[]=description&fl[]=format&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&%@&sort[]=&sort[]=%@";
	} else if ([searchMediaType isEqualToString:@"Movie"]) {
		format = @"http://www.archive.org/advancedsearch.php?q=%@+((collection:nasa+OR+mediatype:nasa)+AND+-mediatype:collection)+AND+mediatype:movies&fl[]=creator&fl[]=description&fl[]=format&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&%@&sort[]=&sort[]=%@";
	} else {
		format = @"http://www.archive.org/advancedsearch.php?q=%@+((collection:nasa+OR+mediatype:nasa)+AND+-mediatype:collection)+AND+mediatype:image&fl[]=creator&fl[]=description&fl[]=format&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&%@&sort[]=&sort[]=%@";
	}
	
	NSString *sortType = [defaults stringForKey:@"Sort Type"];
	NSString *sort;
	if ([sortType isEqualToString:@"No Sort"] || sortType == nil) {
		sort = @"sort[]=";
	} else if ([sortType isEqualToString:@"From New"] || sortType == nil) {
		sort = @"sort[]=publicdate+desc";
	} else {
		sort = @"sort[]=publicdate+asc";
	}
	
	NSString *appendFormat = @"&rows=%d&fmt=json&xmlsearch=Search";
	
	self.strUrl = [NSString stringWithFormat:format, queryString, sort, appendFormat];
	
	[super startGettingItems];
}


- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
	
	[itemList removeAllObjects];
	[itemTableView reloadData];
	[self beginGettingSearchResults:[searchBar text]];
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
	[searchBar resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	[super viewDidUnload];
}

@end
