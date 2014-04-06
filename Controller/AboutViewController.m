//
//  AboutViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

@synthesize aboutWebView, rangeUrl, indicator;

- (void)dealloc {
	[aboutWebView release];
	[rangeUrl release];
	[indicator release];
	[segmentedControl release];
	
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"About";
	
	NSArray *buttonImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"back.png"], [UIImage imageNamed:@"forward.png"], nil];
	segmentedControl = [[UISegmentedControl alloc] initWithItems:buttonImages];
	segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
	segmentedControl.momentary = YES;
	segmentedControl.frame = CGRectMake(0, 0, 70, 30);
	[segmentedControl setTintColor:[UIColor colorWithRed:0.0f green:0.4f blue:0.8f alpha:1.0f]];
	[segmentedControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
	UIBarButtonItem *segmentedButton = [[UIBarButtonItem alloc] initWithCustomView:segmentedControl];
	self.navigationItem.rightBarButtonItem = segmentedButton;
	[segmentedButton release];
	
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL fileURLWithPath:filePath]];
	[aboutWebView loadRequest:request];
}


- (void)viewDidUnload {
	[segmentedControl release];
	[super viewDidUnload];
}


- (void)segmentAction:(id)sender {
	switch([sender selectedSegmentIndex]) {
		case 0:
			[aboutWebView goBack];
			break;
		case 1:
			[aboutWebView goForward];
			break;
		default:
			break;
	}
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
	[indicator startAnimating];
	[segmentedControl setEnabled:NO forSegmentAtIndex:0];
	[segmentedControl setEnabled:NO forSegmentAtIndex:1];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[indicator stopAnimating];
	if ([webView canGoBack]) {
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
	} else {
		[rangeUrl release]; rangeUrl = nil;
	}
	
	if ([webView canGoForward]) {
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	[indicator stopAnimating];
	if ([webView canGoBack]) {
		[segmentedControl setEnabled:YES forSegmentAtIndex:0];
	} else {
		[rangeUrl release]; rangeUrl = nil;
	}
	
	if ([webView canGoForward]) {
		[segmentedControl setEnabled:YES forSegmentAtIndex:1];
	}
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
													message:@"Failed to load a web page."
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		if (rangeUrl == nil) {
			self.rangeUrl = [[request URL] host];
			return YES;
		}
		
		NSRange range = [[[request URL] absoluteString] rangeOfString:rangeUrl options:NSCaseInsensitiveSearch];
		if (range.location == NSNotFound) {
			NSString *error = [NSString stringWithFormat:@"You can't go out from %@.", rangeUrl];
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
															message:error
														   delegate:self
												  cancelButtonTitle:nil
												  otherButtonTitles:@"OK", nil];
			[alert show];
			[alert release];
			return NO;
		}
	}
	return YES;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
