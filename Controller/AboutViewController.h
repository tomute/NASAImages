//
//  AboutViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/02.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController <UIWebViewDelegate> {
  @private
	UIWebView *aboutWebView;
	NSString *rangeUrl;
	UIActivityIndicatorView *indicator;
	UISegmentedControl *segmentedControl;
}

@property (nonatomic, retain) IBOutlet UIWebView *aboutWebView;
@property (nonatomic, copy) NSString *rangeUrl;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;

@end
