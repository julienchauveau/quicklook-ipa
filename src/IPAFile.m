//
//  IPAFile.m
//  Quick Look IPA Plugin
//
//  Created by Julien Chauveau on 24/01/09.
//

#import "IPAFile.h"

@implementation IPAFile

+ (NSData *) dataFromPath:(NSString *) path {
	
	// Create a temporary file for Artwork
	NSString *tmpPath = [NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"jpg"]];
	[[NSFileManager defaultManager] createFileAtPath:tmpPath contents:[NSData alloc] attributes:nil];
	NSFileHandle *writeHandle = [NSFileHandle fileHandleForWritingAtPath:tmpPath];
	
	// Create a task and use 'unzip' to get iTunes Artwork
	NSTask *task = [[NSTask alloc] init];
	[task setLaunchPath: @"/usr/bin/unzip"];
	[task setArguments: [NSArray arrayWithObjects:@"-p", path, @"iTunesArtwork", nil]];
	
	// Launch task and wait for execution
	[task setStandardOutput:writeHandle];
	[task setStandardError:[NSFileHandle fileHandleWithNullDevice]];
	[task launch];
	[task waitUntilExit];
	
	// Read data from Artwork
	NSData *data = [NSData dataWithContentsOfFile:tmpPath];
	
	// Remove temporary file
	[[NSFileManager defaultManager] removeFileAtPath:tmpPath handler:nil];
	
	return data;

}

@end

void CGContextAddRoundRect(CGContextRef context, CGRect rect, float radius)
{
	CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
	CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
	CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius, 
					radius, M_PI / 4, M_PI / 2, 1);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, 
							rect.origin.y + rect.size.height);
	CGContextAddArc(context, rect.origin.x + rect.size.width - radius, 
					rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
	CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
	CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius, 
					radius, 0.0f, -M_PI / 2, 1);
	CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
	CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius, 
					-M_PI / 2, M_PI, 1);
}