//
//  ItemTableViewCell.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemTableViewCell.h"
#import "MediaTypeIcon.h"
#import "Item.h"

@implementation ItemTableViewCell

@synthesize height;

- (void)dealloc {
	[itemView release];
	[title release];
	[description release];
	[pubDate release];
	[downloads release];
	[cellItem release];
	
    [super dealloc];
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		itemView = [[UIView alloc] init];
		[self addSubview:itemView];
		
		title = [[UILabel alloc] init];
		title.lineBreakMode = UILineBreakModeWordWrap;
		title.numberOfLines = 0;
		title.backgroundColor = [UIColor clearColor];
		[itemView addSubview:title];
		
		description = [[UILabel alloc] init];
		description.lineBreakMode = UILineBreakModeWordWrap;
		description.numberOfLines = 3;
		description.font = [UIFont systemFontOfSize:14];
		description.textColor = [UIColor grayColor];
		description.backgroundColor = [UIColor clearColor];
		[itemView addSubview:description];
		
		pubDate = [[UILabel alloc] init];
		pubDate.textAlignment = UITextAlignmentRight;
		pubDate.font = [UIFont systemFontOfSize:14];
		pubDate.textColor = [UIColor grayColor];
		pubDate.backgroundColor = [UIColor clearColor];
		[itemView addSubview:pubDate];
		
		downloads = [[UILabel alloc] init];
		downloads.textAlignment = UITextAlignmentRight;
		downloads.font = [UIFont systemFontOfSize:14];
		downloads.textColor = [UIColor grayColor];
		downloads.backgroundColor = [UIColor clearColor];
		[itemView addSubview:downloads];
    }
    return self;
}


- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	
	if (editing == YES) {
		self.imageView.image = nil;
	} else {
		self.imageView.image = [MediaTypeIcon getIconFromCategory:cellItem.mediaType];
	}
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


- (void)setItem:(Item *)item {
	if ([item.title isEqualToString:@"Show more items"]) {
		title.font = [UIFont systemFontOfSize:18];
		self.accessoryType = UITableViewCellAccessoryNone;
	} else {
		title.font = [UIFont systemFontOfSize:16];
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	cellItem = [item retain];
	
	CGFloat padding = 25;
	CGSize bounds = CGSizeMake(260, 1000);
	CGSize size1 = [cellItem.title sizeWithFont:title.font
							  constrainedToSize:bounds
								  lineBreakMode:UILineBreakModeWordWrap];
	CGSize size2 = [cellItem.description sizeWithFont:description.font
									constrainedToSize:bounds
								  lineBreakMode:UILineBreakModeWordWrap];
	if (size2.height > 55) {
		size2.height = 55;
	}
	
	CGFloat totalHeight = size1.height + size2.height + 15;
	
	itemView.frame = CGRectMake(5, 0, 260, totalHeight);
	title.frame = CGRectMake(40, 10, 260, size1.height);
	title.text = cellItem.title;
	
	description.frame = CGRectMake(40, size1.height + 10, 250, size2.height);
	description.text = cellItem.description;
	
	if (cellItem.downloads == nil) {
		downloads.frame = CGRectMake(30, totalHeight, 260, 0);
		downloads.text = nil;
	} else {
		downloads.frame = CGRectMake(30, totalHeight, 260, 20);
		downloads.text = [NSString stringWithFormat:@"%@ downloads", cellItem.downloads];
		totalHeight += 20;
	}
	
	pubDate.frame = CGRectMake(30, totalHeight, 260, 20);
	pubDate.text = cellItem.pubDate;
	
	height = totalHeight + padding;
}

@end
