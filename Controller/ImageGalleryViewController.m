//
//  ImageGalleryViewController.m
//  NASAImages
//
//  Created by tomute on 09/11/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageGalleryViewController.h"
#import "Item.h"
#import "ImageScrollView.h";
#import "ImageViewController.h"
#import "ImageLoadingOperation.h"

#import "ASIHTTPRequest.h"
#import "JSON.h"

@implementation ImageGalleryViewController

@synthesize thumbnailView, indicator, itemList, segmentedControl, pageLabel;

#define NUMBER_OF_ITEMS 40

- (void)dealloc {
	[thumbnailView release];
	[indicator release];
	[itemList release];
	[queue cancelAllOperations];
	[queue release];
	[segmentedControl release];
	[pageLabel release];
	[currentType release];
	
    [super dealloc];
}


- (void)updateSegmentedControl {
	if (page == 0) {
		[segmentedControl setEnabled:NO forSegmentAtIndex:0];
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	} else if (page == maxPage - 1) {
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
		[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	} else {
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
}


- (void)showImage {
	[queue cancelAllOperations];
	
	for (int i = 0; i < NUMBER_OF_ITEMS; i++) {
		UIImageView *imageView = (UIImageView *)[thumbnailView viewWithTag:i];
		imageView.image = nil;
		imageView.userInteractionEnabled = NO;
	}
	
	int index = NUMBER_OF_ITEMS * page;
	for (int i = index; i < index + NUMBER_OF_ITEMS; i++) {
		if (i < [itemList count]) {
			ImageLoadingOperation *operation =
				[[ImageLoadingOperation alloc] initWithItem:[itemList objectAtIndex:i]
													 target:self
													 action:@selector(didFinishLoadingImageWithResult:)];
			[queue addOperation:operation];
			[operation release];
		}
	}
	
	[self updateSegmentedControl];
}


- (void)setPageCount {
	/*
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *pageCount = [defaults objectForKey:@"Page Count"];
	if (pageCount == nil) {
		pageCount = @"4";
	}
	maxPage = [pageCount intValue];
	*/
	maxPage = 4;
	pageLabel.text = [NSString stringWithFormat:@"%d of %d", page + 1, maxPage];
}


- (IBAction)segmentAction:(id)sender {
	switch([sender selectedSegmentIndex]) {
		case 0:
			page--;
			break;
		case 1:
			page++;
			break;
		default:
			break;
	}
	
	[self setPageCount];
	
	[self showImage];
}


- (void)didFinishLoadingImageWithResult:(NSDictionary *)result {
	UIImage *image = [result objectForKey:ImageResultKey];
	Item *item = [result objectForKey:ItemResultKey];
	
	int index = [itemList indexOfObject:item] - (NUMBER_OF_ITEMS * page);
	UIImageView *imageView = (UIImageView *)[thumbnailView viewWithTag:index];
	imageView.image = image;
	imageView.userInteractionEnabled = YES;
}


- (void)startGettingItems {
	[indicator startAnimating];
	isDataLoading = YES;
	page = 0;
	[self setPageCount];
	
	[segmentedControl setEnabled:NO forSegmentAtIndex:0];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
	
	NSString *searchUrl;
	if (currentType == nil || [currentType isEqualToString:@"Recently Added"]) {
		searchUrl = @"http://www.archive.org/advancedsearch.php?q=((collection:nasa+OR+mediatype:nasa)+AND+-mediatype:collection)+AND+mediatype:image&fl[]=creator&fl[]=description&fl[]=format&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&sort[]=publicdate+desc&sort[]=&sort[]=&rows=%d&fmt=json&xmlsearch=Search";
	} else {
		searchUrl = @"http://www.archive.org/advancedsearch.php?q=((collection:nasa+OR+mediatype:nasa)+AND+-mediatype:collection)+AND+mediatype:image&fl[]=creator&fl[]=description&fl[]=format&fl[]=downloads&fl[]=identifier&fl[]=mediatype&fl[]=publicdate&fl[]=title&fl[]=year&fl[]=rights&sort[]=downloads+desc&sort[]=&sort[]=&rows=%d&fmt=json&xmlsearch=Search";
	}
	
	NSString *tmpUrl = [NSString stringWithFormat:searchUrl, NUMBER_OF_ITEMS * maxPage];
	NSURL *url = [NSURL URLWithString:[tmpUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
	request.timeOutSeconds = 30;
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(gettingItemsResultsDone:)];
	[request setDidFailSelector:@selector(gettingItemsWentWrong:)];
	[queue addOperation:request];
}


- (void)gettingItemsResultsDone:(ASIHTTPRequest *)request {
	NSString *response = [request responseString];
	NSDictionary *results = [response JSONValue];
	
	[indicator stopAnimating];
	
	if (results == nil) {
		return;
	}
	
	NSArray *docs = [[results objectForKey:@"response"] objectForKey:@"docs"];
	int i = 0;
	for (NSDictionary *doc in docs) {
		Item *item = [[Item alloc] initWithDictionary:doc];
		if (item != nil) {
			[itemList addObject:item];
			if (i < NUMBER_OF_ITEMS) {
				ImageLoadingOperation *operation =
					[[ImageLoadingOperation alloc] initWithItem:item
														 target:self
														 action:@selector(didFinishLoadingImageWithResult:)];
				[queue addOperation:operation];
				[operation release];
			}
			[item release];
		}
		i++;
	}
	
	isDataLoading = NO;
	[self updateSegmentedControl];
}


- (void)gettingItemsWentWrong:(ASIHTTPRequest *)request {
	[indicator stopAnimating];
	isDataLoading = NO;
	
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


- (void)viewDidLoad {
    [super viewDidLoad];
	
	pageLabel.font = [UIFont boldSystemFontOfSize:17];
	[self setPageCount];
	
	queue = [[NSOperationQueue alloc] init];
	if (itemList == nil) {
		itemList = [[NSMutableArray alloc] init];
	}
	
	int w = 75;
	int mgnx = 4;
	int mgny = 4;
	int basex = mgnx;
	int basey = mgny;
	
	for (int i = 0; i < NUMBER_OF_ITEMS; i++) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(basex, basey, w, w)];
		imageView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.2];
		imageView.tag = i;
		[thumbnailView addSubview:imageView];
		[imageView release];
		
		basex += w + mgnx;
		if ((i + 1) % 4 == 0) {
			basex = mgnx;
			basey += w + mgny;
		}
	}
	
	[thumbnailView setContentSize:CGSizeMake(320, basey + mgny)];
}


- (void)viewDidUnload {
	[queue release]; queue = nil;
	[itemList release]; itemList = nil;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [[event allTouches] anyObject];
	if ([touch.view isKindOfClass:[UIImageView class]]) {
		UIImageView *imageView = (UIImageView *)touch.view;
		int index = imageView.tag + (page * NUMBER_OF_ITEMS);
		if (index < [itemList count]) {
			ImageViewController *ivc = [[ImageViewController alloc] init];
			[ivc setItem:[itemList objectAtIndex:index]];
			ivc.isBookmarkOff = NO;
			[self.navigationController pushViewController:ivc animated:YES];
			[ivc release];
		}
	}
}


- (void)viewWillAppear:(BOOL)animated {
	isViewDisappear = NO;
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *type = [defaults objectForKey:@"Type"];
	if (type == nil) {
		type = @"Recently Added";
	}
	
	if (isDataLoading == NO && [itemList count] == 0) {
		[currentType release];
		currentType = [type copy];
		[self startGettingItems];
		return;
	}
	
	if ([currentType isEqualToString:type]) {
		return;
	}
	
	[queue cancelAllOperations];
	[currentType release];
	currentType = [type copy];
	[itemList removeAllObjects];
	
	for (int i = 0; i < NUMBER_OF_ITEMS; i++) {
		UIImageView *imageView = (UIImageView *)[thumbnailView viewWithTag:i];
		imageView.image = nil;
		imageView.userInteractionEnabled = NO;
	}
	
	[self startGettingItems];
	
	/*
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *pageCount = [defaults objectForKey:@"Page Count"];
	if (pageCount == nil) {
		pageCount = @"4";
	}
	
	if (maxPage != [pageCount intValue]) {
		[queue cancelAllOperations];
		
		page = 0;
		maxPage = [pageCount intValue];
		pageLabel.text = [NSString stringWithFormat:@"%d of %d", page + 1, maxPage];
		
		for (int i = 0; i < NUMBER_OF_ITEMS; i++) {
			UIImageView *imageView = (UIImageView *)[thumbnailView viewWithTag:i];
			imageView.image = nil;
			imageView.userInteractionEnabled = NO;
		}
		
		[self startGettingItems];
	}
	*/
}


- (void)viewWillDisappear:(BOOL)animated {
	isViewDisappear = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
