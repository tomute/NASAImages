//
//  ImageGalleryViewController.h
//  NASAImages
//
//  Created by tomute on 09/11/26.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageScrollView;

@interface ImageGalleryViewController : UIViewController {
  @private
	ImageScrollView *thumbnailView;
	UIActivityIndicatorView *indicator;
	NSMutableArray *itemList;
	NSOperationQueue *queue;
	BOOL isViewDisappear;
	int page;
	int maxPage;
	NSString *currentType;
	UISegmentedControl *segmentedControl;
	UILabel *pageLabel;
	BOOL isDataLoading;
}

@property (nonatomic, retain) IBOutlet ImageScrollView *thumbnailView;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, retain) NSMutableArray *itemList;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedControl;
@property (nonatomic, retain) IBOutlet UILabel *pageLabel;

- (IBAction)segmentAction:(id)sender;
- (void)startGettingItems;

@end
