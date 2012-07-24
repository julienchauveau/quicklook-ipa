//
//  IPAFile.h
//  Quick Look IPA Plugin
//
//  Created by Julien Chauveau on 24/01/09.
//

#import <Cocoa/Cocoa.h>


@interface IPAFile : NSObject {

}

+ (NSData *) dataFromPath:(NSString *) path;

@end

void CGContextAddRoundRect(CGContextRef context, CGRect rect, float radius);