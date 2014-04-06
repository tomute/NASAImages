//
//  ImageLoadingOperation.m
//  NASAImages
//
//  Created by tomute on 09/11/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageLoadingOperation.h"
#import "Item.h"

NSString *const ImageResultKey = @"image";
NSString *const ItemResultKey = @"item";

@implementation ImageLoadingOperation


- (void)dealloc {
	[imageItem release];
	
	[super dealloc];
}


- (id)initWithItem:(Item *)item target:(id)theTarget action:(SEL)theAction {
	if (self = [super init]) {
		imageItem = [item retain];
		target = theTarget;
		action = theAction;
	}
    return self;
}


- (void)main {
	NSData *data = [NSData dataWithContentsOfURL:[imageItem getFilesXmlUrl]];
	if (data != nil) {
		[imageItem setFileData:data];
	}
	
	data = nil;
	UIImage *image = nil;
	if ([imageItem.thumbItemUrls count] != 0) {
		data = [NSData dataWithContentsOfURL:[imageItem.thumbItemUrls objectAtIndex:0]];
	}
	
	if (data != nil) {
		image = [UIImage imageWithData:data];
	}
	
	// Package it up to send back to our target.
	NSDictionary *result = [NSDictionary dictionaryWithObjectsAndKeys:image, ImageResultKey, imageItem, ItemResultKey, nil];
	[target performSelectorOnMainThread:action withObject:result waitUntilDone:NO];
}


@end
