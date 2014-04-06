//
//  ItemViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TweetComposeViewController.h"

@class Item;
@class ASIHTTPRequest;

@interface ItemViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, TweetComposeViewDelegate> {
  @private
	BOOL isBookmarkOff;
	UIButton *infoButton;
	BOOL isViewDisappear;
	NSMutableArray *bkmItemList;

  @protected
	NSOperationQueue *queue;
	UIActivityIndicatorView *indicator;
	Item *item;
}

@property (nonatomic, retain) Item *item;
@property BOOL isBookmarkOff;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) NSMutableArray *bkmItemList;

- (IBAction)showMetaInfo:(id)sender;
- (BOOL)isNetworkConnectionOK;
- (void)startDataLoading;
- (void)finishDataLoading;
- (void)requestWentWrong:(ASIHTTPRequest *)request;

@end
