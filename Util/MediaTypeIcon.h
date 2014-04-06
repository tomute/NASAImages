//
//  MediaTypeIcon.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaTypeIcon : NSObject {
	
}

+ (UIImage *)getIconFromCategory:(NSString *)mediatype;

@end
