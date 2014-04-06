/*
 *  TweetComposeViewDelegate.h
 *  NASAImages
 *
 *  Created by tomute on 09/10/26.
 *  Copyright 2009 __MyCompanyName__. All rights reserved.
 *
 */

@class TweetComposeViewController;

@protocol TweetComposeViewDelegate <NSObject>
@optional
- (void)tweetComposeViewControllerDidFinish:(TweetComposeViewController *)controller;
- (void)tweetComposeViewControllerDidCancel:(TweetComposeViewController *)controller;
@end
