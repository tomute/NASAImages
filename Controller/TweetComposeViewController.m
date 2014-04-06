//
//  TweetComposeViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TweetComposeViewController.h"

#import "ASIHTTPRequest.h"
#import "JSON.h"
#import "MGTwitterEngine.h"
#import "SFHFKeychainUtils.h"

@implementation TweetComposeViewController

@synthesize tweetTextView, numCharLabel, delegate, spin, link, addText, sendButton;

#define MAX_IMPUT_CHARACTERS 140

- (void)dealloc {
	[queue release];
	[tweetTextView release];
	[numCharLabel release];
	[spin release];
	[link release];
	[addText release];
	[sendButton release];
	[twitterEngine release];
	
    [super dealloc];
}


- (void)changeNumCharLabel {
	numCharLabel.text = [NSString stringWithFormat:@"%d", MAX_IMPUT_CHARACTERS - [tweetTextView.text length]];
	if ([tweetTextView.text length] == 0) {
		[sendButton setEnabled:NO];
	} else {
		[sendButton setEnabled:YES];
	}
	
}


- (void)getShortURL {
	NSString *userName = @"tomutesoft";
	NSString *apiKey = @"SECRET";
	
	NSString *baseURLString = @"http://api.bit.ly/shorten?version=2.0.1&longUrl=%@&login=%@&apiKey=%@";
	NSString *urlString = [NSString stringWithFormat:baseURLString, link, userName, apiKey];
	[spin startAnimating];
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(getShortURLFinished:)];
	[request setDidFailSelector:@selector(getShortURLWentWrong:)];
	[queue addOperation:request];
}


- (void)getShortURLFinished:(ASIHTTPRequest *)request {
	NSDictionary *dic = [[request responseString] JSONValue];
	if ([[dic objectForKey:@"errorCode"] intValue] == 0) {
		tweetTextView.text = [[[[dic objectForKey:@"results"] allValues] objectAtIndex:0] objectForKey:@"shortUrl"];
	} else {
		tweetTextView.text = link;
	}
	
	[self changeNumCharLabel];
	[spin stopAnimating];
	[sendButton setEnabled:YES];
}


- (void)getShortURLWentWrong:(ASIHTTPRequest *)request {
	tweetTextView.text = link;
	[self changeNumCharLabel];
	[spin stopAnimating];
	[sendButton setEnabled:YES];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	[tweetTextView becomeFirstResponder];
	
	queue = [[NSOperationQueue alloc] init];
	if (link != nil) {
		[self getShortURL];
	} else {
		tweetTextView.text = addText;
		[self changeNumCharLabel];
	}
}


- (void)viewDidUnload {
	[queue release]; queue = nil;
}


- (void)textViewDidChange:(UITextView *)textView {
	int numOfCharacters = [textView.text length];
	if (numOfCharacters == 0) {
		[sendButton setEnabled:NO];
	} else {
		[sendButton setEnabled:YES];
	}

	numCharLabel.text = [NSString stringWithFormat:@"%d", MAX_IMPUT_CHARACTERS - numOfCharacters];
}


- (IBAction)sendTweet:(id)sender {
	[spin startAnimating];
	[sendButton setEnabled:NO];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *username = [defaults objectForKey:@"USERNAME"];
	NSError *error;
	NSString *password = [SFHFKeychainUtils getPasswordForUsername:username
													andServiceName:@"com.tomute.NASAImages"
															 error:&error];
	BOOL isHttpsOn = [defaults boolForKey:@"HTTPS_ON"];
	
	NSString *tweet = tweetTextView.text;
	if ([tweet length] > MAX_IMPUT_CHARACTERS) {
		tweet = [tweet substringToIndex:MAX_IMPUT_CHARACTERS];
	}
	
	twitterEngine = [[MGTwitterEngine alloc] initWithDelegate:self];
	[twitterEngine setUsername:username password:password];
	[twitterEngine setUsesSecureConnection:isHttpsOn];
	[twitterEngine sendUpdate:tweet];
}


- (void)requestSucceeded:(NSString *)connectionIdentifier {
	[spin stopAnimating];
	[self.delegate tweetComposeViewControllerDidFinish:self];
}


- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error {
	[spin stopAnimating];
	[sendButton setEnabled:YES];
	
	NSString *title;
	NSString *message;
	if ([error code] == 401) {
		title = @"Not Authorized";
		message = @"Please set the correct username and password.";
	} else {
		title = @"Error";
		message = [error localizedDescription];
	}
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
													message:message
												   delegate:self
										  cancelButtonTitle:nil
										  otherButtonTitles:@"OK", nil];
	[alert show];
	[alert release];
}


- (IBAction)cancel:(id)sender {
	[self.delegate tweetComposeViewControllerDidCancel:self];
}


- (IBAction)erase:(id)sender {
	tweetTextView.text = @"";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
