//
//  DetailInfoViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailInfoViewController : UIViewController {
  @private
	NSOperationQueue *queue;
	NSURL *metaXmlUrl; 
	UITextView *textView;
	UIActivityIndicatorView *indicator;
	BOOL isViewDisappear;
}

@property (nonatomic, retain) NSURL *metaXmlUrl;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;

@end
