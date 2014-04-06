//
//  MediaTypeIcon.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MediaTypeIcon.h"

@implementation MediaTypeIcon


+ (UIImage *)getIconFromCategory:(NSString *)mediatype {
	UIImage *iconImage;
	
	if ([mediatype isEqualToString:@"image"]) {
		iconImage = [UIImage imageNamed:@"mediatype_image.gif"];
	} else if ([mediatype isEqualToString:@"movies"]) {
		iconImage = [UIImage imageNamed:@"mediatype_movies.gif"];
	} else {
		iconImage = nil;
	}
	
	return iconImage;
}


@end
