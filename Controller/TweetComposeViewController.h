//
//  TweetComposeViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TweetComposeViewDelegate.h"

@class MGTwitterEngine;

@interface TweetComposeViewController : UIViewController <UITextViewDelegate> {
  @private
	NSOperationQueue *queue;
	UITextView *tweetTextView;
	UILabel *numCharLabel;
	id <TweetComposeViewDelegate> delegate;
	UIActivityIndicatorView *spin;
	NSString *link;
	NSString *addText;
	UIBarButtonItem *sendButton;
	MGTwitterEngine *twitterEngine;
}

@property (nonatomic, retain) IBOutlet UITextView *tweetTextView;
@property (nonatomic, retain) IBOutlet UILabel *numCharLabel;
@property (nonatomic, assign) id <TweetComposeViewDelegate> delegate;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spin;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *addText;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *sendButton;

- (IBAction)sendTweet:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)erase:(id)sender;

@end
