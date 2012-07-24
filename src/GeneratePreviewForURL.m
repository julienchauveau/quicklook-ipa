#include <CoreFoundation/CoreFoundation.h>
#include <CoreServices/CoreServices.h>
#include <QuickLook/QuickLook.h>
#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>
#include "IPAFile.h"

/* -----------------------------------------------------------------------------
 Generate a preview for file
 
 This function's job is to create preview for designated file
 ----------------------------------------------------------------------------- */

OSStatus GeneratePreviewForURL(void *thisInterface, QLPreviewRequestRef preview, CFURLRef url, CFStringRef contentTypeUTI, CFDictionaryRef options)
{
	//	NSLog(@"GeneratePreviewForURL %@", url);
	
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	
    CGSize imageSize;
    NSDictionary *dict;
	
	NSString *path = [(NSURL *)url path];
	NSData *data = [IPAFile dataFromPath: path];
	
	if(data != nil) {
		
		if([data length] == 0) {
			// Load default icon if iTunesArtwork is not available
			CFBundleRef bundle = QLPreviewRequestGetGeneratorBundle(preview);
			CFURLRef iconURL = CFBundleCopyResourceURL( bundle,
													   CFSTR("iTunes-ipa"),
													   CFSTR("png"),
													   NULL );
			data = [NSData dataWithContentsOfURL:(NSURL *) iconURL];
		}
		
		dict = [NSDictionary dictionaryWithObjectsAndKeys:
				[NSNumber numberWithInt:512],kQLPreviewPropertyWidthKey,
				[NSNumber numberWithInt:512],kQLPreviewPropertyHeightKey,
				nil];
		imageSize = CGSizeMake(512, 512);
		
		CGContextRef cgContext;
		cgContext = QLPreviewRequestCreateContext(preview, imageSize, TRUE, (CFDictionaryRef)dict);
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
			
			QLPreviewRequestFlushContext(preview, cgContext);
			CFRelease(cgContext);
		}
	}
	
	[pool release];
	
    return noErr;
}

void CancelPreviewGeneration(void* thisInterface, QLPreviewRequestRef preview)
{
    // implement only if supported
}
