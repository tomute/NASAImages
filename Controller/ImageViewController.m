//
//  ImageViewController.m
//  NASAImages
//
//  Created by tomute on 09/10/01.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageViewController.h"
#import "ImageScrollView.h"
#import "Item.h"

#import "ASIHTTPRequest.h"
#import "GTMUIImage+Resize.h"

@implementation ImageViewController

@synthesize imageView, bigImageView, imageScrollView, textView, noImageLabel;

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:UIDeviceOrientationDidChangeNotification
												  object:nil];
	
	[queue cancelAllOperations];
	[imageView release];
	[bigImageView release];
	[imageScrollView release];
	[textView release];
	[noImageLabel release];
	
    [super dealloc];
}


- (void)startGettingItem {
	[super startDataLoading];
	if ([item.thumbItemUrls count] == 0 && [item.itemUrls count] == 0) {
		[self startReadingFilesXml];
	} else {
		[self startGettingImage];
	}
}


- (void)saveImage {
	UIImageWriteToSavedPhotosAlbum(imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
	[indicator startAnimating];
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
	[indicator stopAnimating];
}


- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Image";
	[bigImageView setAlpha:(float)isVisible];
	
	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didRotate:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
	
	if ([super isNetworkConnectionOK] == NO) {
		return;
	}
	
	[self startGettingItem];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *fontSize = [defaults objectForKey:@"Font Size"];
	UIFont *font = nil;
	if ([fontSize isEqualToString:@"Medium"] || fontSize == nil) {
		font = [UIFont systemFontOfSize:14];
	} else if ([fontSize isEqualToString:@"Small"]) {
		font = [UIFont systemFontOfSize:12];
	} else if ([fontSize isEqualToString:@"Large"]) {
		font = [UIFont systemFontOfSize:16];
	}
	textView.font = font;
	textView.text = [item getInfoText];
}


- (void)viewDidUnload {
	[super viewDidUnload];
}


- (void)startReadingFilesXml {
	ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:[item getFilesXmlUrl]] autorelease];
	request.timeOutSeconds = 30;
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(readingFilesXmlDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	[queue addOperation:request];
}


- (void)readingFilesXmlDone:(ASIHTTPRequest *)request {
	[item setFileData:[request responseData]];
	[self startGettingImage];
}


- (void)startGettingImage {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *quality = [defaults stringForKey:@"Image Quality"];
	ASIHTTPRequest *request = nil;
	if ([item.thumbItemUrls count] != 0 && ([quality isEqualToString:@"Low"] || quality == nil)) {
		request = [ASIHTTPRequest requestWithURL:[item.thumbItemUrls objectAtIndex:0]];
	} else if ([item.itemUrls count] != 0 && [quality isEqualToString:@"High"]) {
		request = [ASIHTTPRequest requestWithURL:[item.itemUrls objectAtIndex:0]];
	}
	
	if (request == nil) {
		[super finishDataLoading];
		[imageView setUserInteractionEnabled:NO];
		if ([quality isEqualToString:@"High"]) {
			noImageLabel.text = @"No High Quality Image.";
		} else {
			noImageLabel.text = @"No Low Quality Image.";
		}

		return;
	}
	
	request.timeOutSeconds = 30;
	[request setDelegate:self];
	[request setDidFinishSelector:@selector(gettingImageDone:)];
	[request setDidFailSelector:@selector(requestWentWrong:)];
	[queue addOperation:request];
}


- (void)gettingImageDone:(ASIHTTPRequest *)request {
	UIImage *image = [UIImage imageWithData:[request responseData]];
	imageView.image = [image gtm_imageByResizingToSize:CGSizeMake(280, 210)
								   preserveAspectRatio:YES
											   trimToFit:NO];
	bigImageView.image = [image gtm_imageByResizingToSize:CGSizeMake(320, 367)
									  preserveAspectRatio:YES
												trimToFit:NO];
	
	[super finishDataLoading];
}


- (void)fadeInOutBigImage {
	isVisible = !isVisible;
	[imageScrollView setUserInteractionEnabled:isVisible];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	[UIView beginAnimations:nil context:context];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationDuration:1.0];
	[bigImageView setAlpha:(float)isVisible];
	[UIView commitAnimations];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (isVisible) {
		UITouch *touch = [[event touchesForView:imageScrollView] anyObject];
		if ([touch tapCount] == 2) {
			[self fadeInOutBigImage];
		}
	} else {
		UITouch *touch = [[event touchesForView:imageView] anyObject];
		if ([touch tapCount] == 2) {
			[self fadeInOutBigImage];
			[self.view bringSubviewToFront:imageScrollView];
		}
	}
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return bigImageView;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self startGettingItem];
	}
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)rotateImage:(CGFloat)angle {
	//CGContextRef context = UIGraphicsGetCurrentContext();
	//[UIView beginAnimations:nil context:context];
	//[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	//[UIView setAnimationDuration:0.2];
	imageScrollView.zoomScale = 1.0;
	[bigImageView setTransform:CGAffineTransformMakeRotation(angle)];
	bigImageView.frame = self.view.frame;
	//[UIView commitAnimations];	
}


- (void)didRotate:(NSNotification *)notification {
    UIDeviceOrientation orientation = [[notification object] orientation];
	
	if (orientation == UIDeviceOrientationLandscapeLeft) {
		[self rotateImage:M_PI / 2.0];
    } else if (orientation == UIDeviceOrientationLandscapeRight) {
		[self rotateImage:M_PI / -2.0];
    } else if (orientation == UIDeviceOrientationPortraitUpsideDown) {
		[self rotateImage:M_PI];
    } else if (orientation == UIDeviceOrientationPortrait) {
		[self rotateImage:0.0];
    }
}

@end
