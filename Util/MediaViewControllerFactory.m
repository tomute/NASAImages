//
//  MediaViewControllerFactory.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MediaViewControllerFactory.h"
#import "ImageViewController.h"
#import "MovieViewController.h"

@implementation MediaViewControllerFactory


+ (ItemViewController *)createMediaViewController:(NSString*)mediaType {
	if ([mediaType isEqualToString:@"image"]) {
		return [[[ImageViewController alloc] initWithNibName:@"ImageViewController" bundle:nil] autorelease];
	} else if ([mediaType isEqualToString:@"movies"]) {
		return [[[MovieViewController alloc] initWithNibName:@"MovieViewController" bundle:nil] autorelease];
	}
	
	return nil;
}


@end
