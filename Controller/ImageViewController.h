//
//  ImageViewController.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemViewController.h"

@class ImageScrollView;

@interface ImageViewController : ItemViewController <UIScrollViewDelegate> {
  @private
	UIImageView *imageView;
	UIImageView *bigImageView;
	ImageScrollView *imageScrollView;
	BOOL isVisible;
	UITextView *textView;
	UILabel *noImageLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIImageView *bigImageView;
@property (nonatomic, retain) IBOutlet ImageScrollView *imageScrollView;
@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UILabel *noImageLabel;

- (void)startReadingFilesXml;
- (void)startGettingImage;

@end
