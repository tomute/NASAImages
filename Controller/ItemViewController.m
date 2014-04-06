//
//  ItemViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemViewController.h"
#import "Item.h"
#import "DetailInfoViewController.h"

#import "ASIHTTPRequest.h"
#import "Reachability.h"

@implementation ItemViewController

@synthesize item, isBookmarkOff, indicator, infoButton, bkmItemList;


- (void)dealloc {
	[queue cancelAllOperations];
	[queue release]; queue = nil;
	[item release];
	[indicator release];
	[infoButton release];
	[bkmItemList release];
	
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
	backButton.title = @"Back";
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
	
	self.navigationItem.rightBarButtonItem =
		[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
													  target:self
													  action:@selector(itemAction)];
	if (isBookmarkOff == NO) {
		[self.navigationItem.rightBarButtonItem setEnabled:NO];
		[infoButton setEnabled:NO];
	}
	
	queue = [[NSOperationQueue alloc] init];
}


- (void)viewWillAppear:(BOOL)animated {
	isViewDisappear = NO;
}


- (void)viewWillDisappear:(BOOL)animated {
	isViewDisappear = YES;
}


- (BOOL)isNetworkConnectionOK {
	if ([[Reachability sharedReachability] internetConnectionStatus] == NotReachable) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error"
														message:@"Failed to load data."
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return NO;
	}
	
	return YES;
}


- (IBAction)showMetaInfo:(id)sender {
	DetailInfoViewController *divc = [[DetailInfoViewController alloc] initWithNibName:@"DetailInfoViewController" bundle:nil];
	divc.metaXmlUrl = [item getMetaXmlUrl];
	[self.navigationController pushViewController:divc animated:YES];
	[divc release];
}


- (void)addItemToTheBookmarkArray {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData* classDataLoad = [defaults dataForKey:@"BOOKMARK_ARRAY"];
	if (classDataLoad == nil) {
		self.bkmItemList = [NSMutableArray array];
	} else {
		NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:classDataLoad];
		self.bkmItemList = [NSMutableArray arrayWithArray:array];
	}
	
	if ([bkmItemList count] == 100) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"
														message:@"You can't bookmark more than 100 items"
													   delegate:self
											  cancelButtonTitle:nil
											  otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
	} else {
		for (Item *savedItem in bkmItemList) {
			if ([savedItem.link isEqualToString:item.link]) {
				return;
			}
		}
		
		[bkmItemList addObject:item];
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSData* classDataSave = [NSKeyedArchiver archivedDataWithRootObject:bkmItemList];
		[defaults setObject:classDataSave forKey:@"BOOKMARK_ARRAY"];
		[defaults synchronize];
	}

}


- (void)itemAction {
	UIActionSheet *menu;
	if (isBookmarkOff == YES) {
		if ([item.mediaType isEqualToString:@"image"]) {
			menu = [[UIActionSheet alloc] initWithTitle:@"Action"
											   delegate:self
									  cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
									  otherButtonTitles:@"Send Email", @"Send Tweet", @"Save to Camera Roll", nil];
		} else {
			menu = [[UIActionSheet alloc] initWithTitle:@"Action"
											   delegate:self
									  cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
									  otherButtonTitles:@"Send Email", @"Send Tweet", nil];
		}
	} else {
		if ([item.mediaType isEqualToString:@"image"]) {
			menu = [[UIActionSheet alloc] initWithTitle:@"Action"
											   delegate:self
									  cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
									  otherButtonTitles:@"Bookmark", @"Send Email", @"Send Tweet", @"Save to Camera Roll", nil];
		} else {
			menu = [[UIActionSheet alloc] initWithTitle:@"Action"
											   delegate:self
									  cancelButtonTitle:@"Cancel"
								 destructiveButtonTitle:nil
									  otherButtonTitles:@"Bookmark", @"Send Email", @"Send Tweet", nil];
		}
	}

	[menu showFromToolbar:self.navigationController.toolbar];
	[menu release];
}


- (void)sendEmail {
	MFMailComposeViewController *mmcvc = [[MFMailComposeViewController alloc] init];
	mmcvc.navigationBar.tintColor = [UIColor colorWithRed:0.0
													green:0.4
													 blue:0.8
													alpha:1.0];
	mmcvc.mailComposeDelegate = self;
	[mmcvc setSubject:item.title];
	[mmcvc setMessageBody:item.link isHTML:NO];
	[self presentModalViewController:mmcvc animated:YES];
	[mmcvc release];
}


- (void)mailComposeController:(MFMailComposeViewController*)controller
		  didFinishWithResult:(MFMailComposeResult)result
						error:(NSError*)error {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)sendTweet {
	TweetComposeViewController *tcvc = [[TweetComposeViewController alloc] init];
	tcvc.link = item.link;
	tcvc.addText = item.title;
	tcvc.delegate = self;
	[self presentModalViewController:tcvc animated:YES];
	[tcvc release];
}


- (void)tweetComposeViewControllerDidFinish:(TweetComposeViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)tweetComposeViewControllerDidCancel:(TweetComposeViewController *)controller {
	[self dismissModalViewControllerAnimated:YES];
}


- (void)saveImage {
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (isBookmarkOff) {
		switch (buttonIndex) {
			case 0:
				[self sendEmail];
				break;
			case 1:
				[self sendTweet];
				break;
			case 2:
				[self saveImage];
				break;
			default:
				break;
		}
	} else {
		switch (buttonIndex) {
			case 0:
				[self addItemToTheBookmarkArray];
				break;
			case 1:
				[self sendEmail];
				break;
			case 2:
				[self sendTweet];
				break;
			case 3:
				[self saveImage];
				break;
			default:
				break;
		}
	}
}


- (void)startDataLoading {
	[indicator startAnimating];
	[self.navigationItem.rightBarButtonItem setEnabled:NO];
	[infoButton setEnabled:NO];
}


- (void)finishDataLoading {
	[indicator stopAnimating];
	[self.navigationItem.rightBarButtonItem setEnabled:YES];
	[infoButton setEnabled:YES];
}


- (void)requestWentWrong:(ASIHTTPRequest *)request {
	[queue cancelAllOperations];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload {
	[queue release]; queue = nil;
	[super viewDidUnload];
}


@end
