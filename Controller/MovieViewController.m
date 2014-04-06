//
//  MovieViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MovieViewController.h"
#import "Item.h"

#import "ASIHTTPRequest.h"

@implementation MovieViewController

@synthesize webView, textView, segmented;

- (void)dealloc {
	[queue cancelAllOperations];
	[webView release];
	[textView release];
	[segmented release];
	
    [super dealloc];
}


- (void)showMovie {
	NSString *htmlString = nil;
	
	if ([item.itemUrls count] == 0) {
		htmlString = @"This video format is not supported by iPhone.";
	} else if ([item.itemUrls count] == 1) {
		htmlString = [NSString stringWithFormat:@"<video width=\"270\" height=\"160\" src=\"%@\" poster=\"%@\"></video>", [[item.itemUrls objectAtIndex:0] absoluteString], [[item.thumbItemUrls lastObject] absoluteString]];
	} else {
		[segmented setHidden:NO];
		[segmented setEnabled:YES];
		
		if (movieNumber == 0) {
			[segmented setEnabled:NO forSegmentAtIndex:0];
		} else {
			[segmented setEnabled:YES forSegmentAtIndex:0];
		}
		
		if (movieNumber == [item.itemUrls count] - 1) {
			[segmented setEnabled:NO forSegmentAtIndex:1];
		} else {
			[segmented setEnabled:YES forSegmentAtIndex:1];
		}

		NSString *strItemUrl = [[item.itemUrls objectAtIndex:movieNumber] absoluteString];
		NSString *itemFilename = nil;
		if ([strItemUrl hasSuffix:@"512kb.mp4"]) {
			itemFilename = [strItemUrl substringToIndex:[strItemUrl length] - 10];
		} else {
			itemFilename = [strItemUrl substringToIndex:[strItemUrl length] - 4];
		}
		
		NSURL *thumbItemUrl = nil;
		for (thumbItemUrl in item.thumbItemUrls) {
			NSRange range = [[thumbItemUrl absoluteString] rangeOfString:itemFilename];
			if (range.location != NSNotFound) {
				break;
			}
		}
		if (thumbItemUrl == nil) {
			thumbItemUrl = [item.thumbItemUrls lastObject];
		}
		
		htmlString = [NSString stringWithFormat:@"<video width=\"270\" height=\"160\" src=\"%@\" poster=\"%@\"></video>", strItemUrl, thumbItemUrl];
	}
	
	[webView loadHTMLString:htmlString baseURL:nil];
}


- (IBAction)changeMovie:(id)sender {
	if ([segmented selectedSegmentIndex] == 0) {
		movieNumber--;
	} else if ([segmented selectedSegmentIndex] == 1) {
		movieNumber++;
	}
	[self showMovie];
}


- (void)startReadingFilesXml {
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[item getFilesXmlUrl]] autorelease];
	request.timeOutSeconds = 30;
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(readingFilesXmlDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	[queue addOperation:request];
}


- (void)readingFilesXmlDone:(ASIHTTPRequest *)request {
	[item setFileData:[request responseData]];
	[self showMovie];
	[super finishDataLoading];
}


- (void)startGettingItem {
	[self startDataLoading];
	if ([item.thumbItemUrls count] == 0 && [item.itemUrls count] == 0) {
		[self startReadingFilesXml];
	} else {
		[self showMovie];
		[super finishDataLoading];
	}	
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Movie";
	
	if ([super isNetworkConnectionOK] == NO) {
		return;
	}
	
	[self startGettingItem];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *fontSize = [defaults objectForKey:@"Font Size"];
	UIFont *font = nil;
	if ([fontSize isEqualToString:@"Medium"] || fontSize == nil) {
		font = [UIFont systemFontOfSize:14];
	} else if ([fontSize isEqualToString:@"Small"]) {
		font = [UIFont systemFontOfSize:12];
	} else if ([fontSize isEqualToString:@"Large"]) {
		font = [UIFont systemFontOfSize:16];
	}
	textView.font = font;
	textView.text = [item getInfoText];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self startGettingItem];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	[super viewDidUnload];
}

@end
