#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>
#include "IPAFile.h"

/* -----------------------------------------------------------------------------
 Generate a thumbnail for file
 
 This function's job is to create thumbnail for designated file as fast as possible
 ----------------------------------------------------------------------------- */

OSStatus GenerateThumbnailForURL(void *thisInterface, QLThumbnailRequestRef thumbnail, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options, CGSize maxSize)
{
	// NSLog(@"GenerateThumbnailForURL %@", url);
	
    @autoreleasepool {
	
        CGSize imageSize;
        NSDictionary *dict;
	
	NSString *path = [(__bridge NSURL *)url path];
	NSData *data = [IPAFile dataFromPath: path];
	
	if(data != nil) {
		
		if([data length] == 0) {
			// Load default icon if iTunesArtwork is not available
			CFBundleRef bundle = QLThumbnailRequestGetGeneratorBundle(thumbnail);
			CFURLRef iconURL = CFBundleCopyResourceURL( bundle,
													   CFSTR("iTunes-ipa"),
													   CFSTR("png"),
													   NULL );
			data = [NSData dataWithContentsOfURL:(__bridge NSURL *) iconURL];
                CFRelease(iconURL);
		}

		dict = @{(id)kQLPreviewPropertyWidthKey: @512,
				(id)kQLPreviewPropertyHeightKey: @512};
		imageSize = CGSizeMake(512, 512);
		
		CGContextRef cgContext;
		cgContext = QLThumbnailRequestCreateContext(thumbnail, imageSize, TRUE, (__bridge CFDictionaryRef)dict);
		if (cgContext) {
			NSGraphicsContext *context;
			context = [NSGraphicsContext graphicsContextWithGraphicsPort:
					   (void *)cgContext flipped:NO];
			if (context) {
				[NSGraphicsContext saveGraphicsState];
				[NSGraphicsContext setCurrentContext:context];
				
				// Clip with a rounded rectangle
				CGRect imageRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
				CGContextBeginPath(cgContext);
				CGContextAddRoundRect(cgContext, imageRect, 100);
				CGContextClip(cgContext);
				
				NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:data];
				[bitmapRep drawInRect:NSRectFromCGRect(imageRect)];
				
				[NSGraphicsContext restoreGraphicsState];
			}
			QLThumbnailRequestFlushContext(thumbnail, cgContext);
			CFRelease(cgContext);
		}
	}
	
	
        return noErr;
    }
}

void CancelThumbnailGeneration(void* thisInterface, QLThumbnailRequestRef thumbnail)
{
    // implement only if supported
}
