//
//  Item.h
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject <NSCoding> {
  @private
	NSString *title;
	NSString *link;
	NSString *pubDate;
	NSString *mediaType;
	NSString *downloads;
	NSString *creator;
	NSString *description;
	NSString *year;
	NSString *rights;
	NSString *format;
	
	NSMutableArray *itemUrls;
	NSMutableArray *thumbItemUrls;
}

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, readonly) NSString *pubDate;
@property (nonatomic, copy) NSString *mediaType;
@property (nonatomic, copy) NSString *downloads;
@property (nonatomic, copy) NSString *creator;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *year;
@property (nonatomic, copy) NSString *rights;
@property (nonatomic, copy) NSString *format;

@property (nonatomic, readonly) NSMutableArray *itemUrls;
@property (nonatomic, readonly) NSMutableArray *thumbItemUrls;

- (void)setFileData:(NSData *)fileData;
- (NSURL *)getFilesXmlUrl;
- (NSURL *)getMetaXmlUrl;
- (NSString *)getInfoText;

@end
