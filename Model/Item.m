//
//  Item.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Item.h"
#import "XPathQuery.h"

@implementation Item

@synthesize title, link, pubDate, mediaType, downloads, creator, description, year, rights, format;
@synthesize itemUrls, thumbItemUrls;

- (void)dealloc {
	[title release];
	[link release];
	[pubDate release];
	[mediaType release];
	[downloads release];
	[creator release];
	[description release];
	[year release];
	[rights release];
	[format release];
	
	[itemUrls release];
	[thumbItemUrls release];
	
    [super dealloc];
}


- (void)setPubDate:(NSString *)stringPubDate {
	if (pubDate != nil) {
		[pubDate release];
	}
	
	if (stringPubDate == nil) {
		pubDate = [[NSString stringWithString:@"No Date"] copy];
		return;
	}
	
	NSDateFormatter *dfin = [[NSDateFormatter alloc] init];
	[dfin setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"US"] autorelease]];
	[dfin setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
	
	NSDateFormatter *dfout = [[NSDateFormatter alloc] init];
	[dfout setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] autorelease]];
	[dfout setTimeZone:[NSTimeZone localTimeZone]];
	[dfout setDateStyle:NSDateFormatterLongStyle];
	[dfout setTimeStyle:NSDateFormatterMediumStyle];
	
	pubDate = [[dfout stringFromDate:[dfin dateFromString:stringPubDate]] copy];
	
	[dfin release];
	[dfout release];
}


- (void)setFileFormat:(NSArray *)formats {
	if ([mediaType isEqualToString:@"movies"]) {
		for (NSString *fileFormat in formats) {
			if ([fileFormat hasSuffix:@"MPEG4"]) {
				self.format = fileFormat;
				break;
			}
		}
	} else {
		for (NSString *fileFormat in formats) {
			if ([fileFormat isEqualToString:@"TIFF"]) {
				self.format = fileFormat;
				break;
			} else if ([fileFormat isEqualToString:@"JPEG"]) {
				self.format = fileFormat;
				break;
			} else if ([fileFormat isEqualToString:@"Unknown"]) {
				self.format = fileFormat;
				break;
			}
		}
	}
}


- (Item *)initWithDictionary:(NSDictionary *)dic {
	if (self = [super init]) {
		itemUrls = [[NSMutableArray alloc] init];
		thumbItemUrls = [[NSMutableArray alloc] init];
		
		self.title = [dic objectForKey:@"title"];
		self.mediaType = [dic objectForKey:@"mediatype"];
		if ([mediaType isEqualToString:@"text"]) {
			return nil;
		}
		
		
		NSArray *array = [dic objectForKey:@"format"];
		[self setFileFormat:array];
		
		self.description = [dic objectForKey:@"description"];
		self.creator = [[dic objectForKey:@"creator"] objectAtIndex:0];
		self.year = [dic objectForKey:@"year"];
		self.rights = [[dic objectForKey:@"rights"] objectAtIndex:0];
		
		NSString *identifier = [dic objectForKey:@"identifier"];
		self.link = [NSString stringWithFormat:@"http://www.archive.org/details/%@", identifier];
		[self setPubDate:[dic objectForKey:@"publicdate"]];
		
		NSDecimalNumber *num_downloads = [dic objectForKey:@"downloads"];
		if (num_downloads == nil) {
			num_downloads = [dic objectForKey:@"week"];
		}
		if (num_downloads == nil) {
			num_downloads = [dic objectForKey:@"month"];
		}
		self.downloads = [num_downloads stringValue];
	}
	
	return self;
}


- (NSURL *)getXmlUrl:(NSString *)baseUrl {
	NSString *strXmlUrl = [NSString stringWithFormat:baseUrl, [link lastPathComponent], [link lastPathComponent]];
	return [NSURL URLWithString:[strXmlUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


- (NSURL *)getMetaXmlUrl {
	return [self getXmlUrl:@"http://www.archive.org/download/%@/%@_meta.xml"];
}


- (NSURL *)getFilesXmlUrl {
	return [self getXmlUrl:@"http://www.archive.org/download/%@/%@_files.xml"];
}


- (NSURL *)getUrl:(NSString *)fileName {
	NSString *strUrl = [NSString stringWithFormat:@"http://www.archive.org/download/%@/%@", [link lastPathComponent], fileName];
	return [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}


- (void)setThumbFileName:(NSString *)fileName {
	[thumbItemUrls addObject:[self getUrl:fileName]];
}


- (void)setFileName:(NSString *)fileName {
	[itemUrls addObject:[self getUrl:fileName]];
}


- (void)setImageFileData:(NSData *)fileData {
	NSString *thumbSuffix = @"thumb.jpg";
	NSString *suffix1 = nil;
	NSString *suffix2 = nil;
	NSString *suffix3 = nil;
	if ([format isEqualToString:@"TIFF"]) {
		suffix1 = @".tif";
		suffix2 = @".TIF";
		suffix3 = @".tiff";
	} else if ([format isEqualToString:@"JPEG"]) {
		suffix1 = @".jpg";
		suffix2 = @".JPG";
		suffix3 = @".jpeg";
	} else {
		suffix1 = @".png";
		suffix2 = @".PNG";
		suffix3 = @".png";
	}
	
	NSArray *filenames = PerformXMLXPathQuery(fileData, @"/files/file/@name");
	for (NSDictionary *dic in filenames) {
		NSString *filename = [dic objectForKey:@"nodeContent"];
		if ([filename hasSuffix:thumbSuffix]) {
			[self setThumbFileName:filename];
			if ([itemUrls count] != 0) {
				break;
			}
		} else if ([filename hasSuffix:suffix1] || [filename hasSuffix:suffix2] || [filename hasSuffix:suffix3]) {
			[self setFileName:filename];
			if ([thumbItemUrls count] != 0) {
				break;
			}
		}
	}
}


- (void)setMovieFileData:(NSData *)fileData {
	NSString *thumbSuffix = nil;
	NSString *suffix = nil;
	
	thumbSuffix = @".jpg";
	suffix = @"512kb.mp4";
	
	NSArray *filenames = PerformXMLXPathQuery(fileData, @"/files/file/@name");
	for (NSDictionary *dic in filenames) {
		NSString *filename = [dic objectForKey:@"nodeContent"];
		if ([filename hasSuffix:thumbSuffix]) {
			[self setThumbFileName:filename];
		} else if ([filename hasSuffix:suffix]) {
			[self setFileName:filename];
		}
	}
	
	if ([itemUrls count] == 0) {
		suffix = @".mp4";
		for (NSDictionary *dic in filenames) {
			NSString *filename = [dic objectForKey:@"nodeContent"];
			if ([filename hasSuffix:suffix]) {
				[self setFileName:filename];
			}
		}
	}
}


- (void)setFileData:(NSData *)fileData {
	if ([mediaType isEqualToString:@"image"]) {
		[self setImageFileData:fileData];
	} else {
		[self setMovieFileData:fileData];
	}
}


- (NSString *)getInfoText {
	NSMutableString *infoText = [NSMutableString stringWithCapacity:1];
	[infoText appendFormat:@"Title: %@", title];
	if (description != nil) {
		[infoText appendFormat:@"\nDescription: %@", description];
	}
	if (rights != nil) {
		[infoText appendFormat:@"\nRights: %@", rights];
	}
	if (creator != nil) {
		[infoText appendFormat:@"\nCreator: %@", creator];
	}
	if (year != nil) {
		[infoText appendFormat:@"\nYear: %@", year];
	}
	[infoText appendFormat:@"\nPublicdate: %@", pubDate];
	
	return infoText;
}


- (void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeObject:title forKey:@"TITLE"];
	[coder encodeObject:link forKey:@"LINK"];
	[coder encodeObject:pubDate forKey:@"PUBDATE"];
	[coder encodeObject:mediaType forKey:@"MEDIATYPE"];
	[coder encodeObject:downloads forKey:@"DOWNLOADS"];
	[coder encodeObject:creator forKey:@"CREATOR"];
	[coder encodeObject:description forKey:@"DESCRIPTION"];
	[coder encodeObject:year forKey:@"YEAR"];
	[coder encodeObject:rights forKey:@"RIGHTS"];
	[coder encodeObject:format forKey:@"FORMAT"];
	
	[coder encodeObject:itemUrls forKey:@"ITEMURLS"];
	[coder encodeObject:thumbItemUrls forKey:@"THUMBITEMURLS"];
}


- (id)initWithCoder:(NSCoder *)coder {
	title = [[coder decodeObjectForKey:@"TITLE"] retain];
	link = [[coder decodeObjectForKey:@"LINK"] retain];
	pubDate = [[coder decodeObjectForKey:@"PUBDATE"] retain];
	mediaType = [[coder decodeObjectForKey:@"MEDIATYPE"] retain];
	downloads = [[coder decodeObjectForKey:@"DOWNLOADS"] retain];
	creator = [[coder decodeObjectForKey:@"CREATOR"] retain];
	description = [[coder decodeObjectForKey:@"DESCRIPTION"] retain];
	year = [[coder decodeObjectForKey:@"YEAR"] retain];
	rights = [[coder decodeObjectForKey:@"RIGHTS"] retain];
	format = [[coder decodeObjectForKey:@"FORMAT"] retain];
	
	itemUrls = [[coder decodeObjectForKey:@"ITEMURLS"] retain];
	thumbItemUrls = [[coder decodeObjectForKey:@"THUMBITEMURLS"] retain];
	
	return self;
}

@end
