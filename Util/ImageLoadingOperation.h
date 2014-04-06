//
//  ImageLoadingOperation.h
//  NASAImages
//
//  Created by tomute on 09/11/28.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const ImageResultKey;
extern NSString *const ItemResultKey;

@class Item;

@interface ImageLoadingOperation : NSOperation {
	Item *imageItem;
	id target;
	SEL action;
}

- (id)initWithItem:(Item *)item target:(id)theTarget action:(SEL)theAction;

@end
