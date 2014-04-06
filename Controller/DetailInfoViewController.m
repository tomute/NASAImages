//
//  DetailInfoViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailInfoViewController.h"

#import "ASIHTTPRequest.h"
#import "Reachability.h"
#import "GTMNSString+HTML.h"

@implementation DetailInfoViewController

@synthesize metaXmlUrl, textView, indicator;

- (void)dealloc {
	[queue cancelAllOperations];
	[queue release];
	[metaXmlUrl release];
	[textView release];
	[indicator release];
	
    [super dealloc];
}


- (void)startReadingMetaXml {
	[indicator startAnimating];
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:metaXmlUrl] autorelease];
	request.timeOutSeconds = 30;
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(readingMetaXmlDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	[queue addOperation:request];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Detail Infomation";
	
	if ([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
														message:@"Failed to load data."
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return;
	}
	
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
	
	queue = [[NSOperationQueue alloc] init];
	
	[self startReadingMetaXml];
}


- (void)readingMetaXmlDone:(ASIHTTPRequest *)request {
	[indicator stopAnimating];
	textView.text = [[request responseString] gtm_stringByUnescapingFromHTML];
}


- (void)requestWentWrong:(ASIHTTPRequest *)request {
	[indicator stopAnimating];
	
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
		[self startReadingMetaXml];
	}
}


- (void)viewWillAppear:(BOOL)animated {
	isViewDisappear = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
	isViewDisappear = YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	[queue release]; queue = nil;
	[super viewDidUnload];
}

@end
