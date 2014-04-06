//
//  MovieViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemViewController.h"

@interface MovieViewController : ItemViewController {
  @private
	UIWebView *webView;
	UITextView *textView;
	int movieNumber;
	UISegmentedControl *segmented;
}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmented;

- (IBAction)changeMovie:(id)sender;

@end
