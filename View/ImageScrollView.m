//
//  ImageScrollView.m
//  NASAImages
//
//  Created by tomute on 09/10/25.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageScrollView.h"

@implementation ImageScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.nextResponder touchesBegan:touches withEvent:event];
}

@end
